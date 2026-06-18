# Padrão ADVPR — Smart View

## Quando Usar

Smart View é a ferramenta de visualização e análise de dados transacionais do Protheus, com três recursos:

- **Relatórios** — relatórios gerados a partir do Objeto de Negócio + arquivo de design `.trp` compilados
- **Tabelas Dinâmicas** — análise multidimensional via schema do Objeto de Negócio
- **Visões de Dados** — consulta estruturada via data do Objeto de Negócio

A versão usada na esteira é sempre a **Staging**, o que antecipa problemas antes da produção. Nomes de TestSuite/TestCase devem ter no máximo 25 caracteres (sem o sufixo).

### Tipos de automação e configuração no appserver.ini

| Tipo | Método principal | Chave no `[ADVPR]` do appserver.ini | Observação |
|---|---|---|---|
| **Relatório** | `UTGenerateSmartView` | `URL_SMARTVIEW=http://localhost:7017` | `cReport` = nome do fonte `.trp` sem extensão; saída em `csv` na pasta `spool` |
| **Schema** | `UTSchemaSmartView` | `REST=http://localhost:9903/rest/` | JSON validado por comparação de arquivo baseline |
| **Data** | `UTGetDataSmartView` | `REST=http://localhost:9903/rest/` | Parâmetros via `UTParamSmartView`; JSON validado por baseline |
| **Campos Personalizáveis** | `UTCustomSmartView` / `UTRemoveCustomSmartView` | `REST=http://localhost:9903/rest/` | Tag interna `FW_SV_CUSTOM` |

## Exemplo de Script

### Relatório Smart View — GPER040SV

```advpl
//--------------------------------------------------------------
/*/{Protheus.doc} GPR040SV_001()
@author advpr.sp
@version 1.0
/*/
//--------------------------------------------------------------
METHOD GPR040SV_001() CLASS GPER040SVTestCase

Local oHelper     := FwTestHelper():New()
Local cReport     := "RELATORIO_FOLHA_FECHADA"
Local cFileName   := "GPER040SV_ct001"
Local aReplace    := {}
Local aReplaceX   := {}
Local lUpdateFile := .T.

// Ativação da classe do robô
oHelper:Activate()

// Configuração dos parâmetros do relatório
oHelper:UTParamSmartView("processo", "01817")
oHelper:UTParamSmartView("roteiro", "FOL"  )
oHelper:UTParamSmartView("periodo", "202305")
oHelper:UTParamSmartView("numeroPagto", "01")
oHelper:UTParamSmartView("filialDe", "D MG 01")
oHelper:UTParamSmartView("filialAte", "D MG 01")
oHelper:UTParamSmartView("centroDe", "")
oHelper:UTParamSmartView("centroAte", "Z")
oHelper:UTParamSmartView("matriculaDe", "926199")
oHelper:UTParamSmartView("matriculaAte", "926199")

// Gera o relatório
oHelper:UTGenerateSmartView(cReport,cFileName)

// Substitui uma string por outra para comparação do arquivo
aadd(aReplace,{"01/05/2023 até 31/05/2023","01/01/2015 até 31/01/2015"})

// Substitui o conteúdo entre duas strings para comparação do arquivo
aadd(aReplaceX,{";Data de referência:;;;;;;;",";;Página","01/01/2015 | 01:01:01"})

// Compara relatório com Baseline
oHelper:UTCompareSmartView(cFileName,aReplace,aReplaceX,lUpdateFile)

oHelper:AssertTrue(oHelper:lOk,'')

Return oHelper
```

### Schema do Objeto de Negócio — OBJEST_001

```advpl
METHOD OBJEST_001() CLASS ObjEstTestCase

Local oHelper         := FwTestHelper():New()
Local cNameSpace      := "totvs.estoque.inflowsandoutflows.integratedprovider"
Local cBusinessObject := "inflowsandoutflowstreportsbusinessobject"
Local cFile           := "OBJEST_001"

oHelper:Activate()

oHelper:UTSchemaSmartView(cNameSpace,cBusinessObject,cFile)

oHelper:AssertTrue(oHelper:lOk)

Return oHelper
```

### Data do Objeto de Negócio — OBJEST_002

```advpl
METHOD OBJEST_002() CLASS ObjEstTestCase

Local oHelper         := FwTestHelper():New()
Local cNamespace      := "totvs.estoque.inflowsandoutflows.integratedprovider"
Local cBusinessObject := "inflowsandoutflowstreportsbusinessobject"
Local cFile           := "OBJEST_002"

oHelper:Activate()

oHelper:UTParamSmartView("MV_PAR01", {""})
oHelper:UTParamSmartView("MV_PAR02", {"ZZ"})
oHelper:UTParamSmartView("MV_PAR03", {""})
oHelper:UTParamSmartView("MV_PAR04", {"ZZ"})
oHelper:UTParamSmartView("MV_PAR05", {"ESTSE0000000000000000000001291"})
oHelper:UTParamSmartView("MV_PAR06", {"ESTSE0000000000000000000001293"})
oHelper:UTParamSmartView("MV_PAR07", totvs.framework.treports.date.stringToTimeStamp("20220401"))
oHelper:UTParamSmartView("MV_PAR08", totvs.framework.treports.date.stringToTimeStamp("20220430"))
oHelper:UTParamSmartView("MV_PAR09", {1})
oHelper:UTParamSmartView("MV_PAR10", {1})
oHelper:UTParamSmartView("MV_PAR11", {1})
oHelper:UTParamSmartView("MV_PAR12", {1})

oHelper:UTGetDataSmartView(cNameSpace,cBusinessObject,cFile)

oHelper:AssertTrue(oHelper:lOk)

Return oHelper
```

### Comparação de arquivos: fluxo AUTO → BASE

Na primeira execução, os testes falham pois o arquivo BASE ainda não existe. O fluxo correto é:

1. Executar o teste para gerar o arquivo `"NomeTeste"+"_NumeroCT"+"AUTO"`
2. Abrir e conferir o conteúdo do arquivo AUTO
3. Renomear para `BASE` quando o conteúdo estiver correto
4. Inserir os arquivos BASE em `\\10.171.80.90\Arquivos_Base_Congelada$\` na pasta do país e release correspondentes

## Métodos Relevantes

Detalhes de assinatura e parâmetros completos estão documentados em `api-fwtesthelper.md`.

| Método | Descrição |
|---|---|
| `UTParamSmartView(cKey, xValue)` | Define parâmetros de entrada do relatório ou data. Chamado antes de `UTGenerateSmartView` ou `UTGetDataSmartView`. |
| `UTGenerateSmartView(cReport, cFileName)` | Gera o relatório Smart View. `cReport` é o nome do fonte `.trp` sem extensão; a saída é gravada em `csv` na pasta `spool`. Requer `URL_SMARTVIEW` no appserver.ini. |
| `UTCompareSmartView(cFileName, aReplace, aReplaceX, lUpdateFile)` | Compara o arquivo gerado com o arquivo baseline. `aReplace` substitui strings literais; `aReplaceX` substitui conteúdo entre dois marcadores. |
| `UTSchemaSmartView(cNameSpace, cBusinessObject, cFile [, lIgnoreNewProperty])` | Consome as APIs do Framework para obter o schema do Objeto de Negócio e valida por comparação de baseline. O parâmetro opcional `lIgnoreNewProperty` ignora propriedades novas adicionadas pelo Framework sem quebrar o teste. |
| `UTGetDataSmartView(cNameSpace, cBusinessObject, cFile)` | Consome as APIs do Framework para obter o data do Objeto de Negócio e valida por comparação de baseline. |
| `UTCustomSmartView(cNameSpace, cBusinessObject, cTable, cField, cName, cDescri, cType)` | Adiciona um campo personalizável (`FW_SV_CUSTOM`) ao Objeto de Negócio. |
| `UTRemoveCustomSmartView(cNameSpace, cBusinessObject, cTable, cField, cName, cDescri, cType)` | Remove o campo personalizável adicionado por `UTCustomSmartView`. |
| `AssertTrue(lCondicao [, cMensagem])` | Valida o resultado do teste. Normalmente chamado com `oHelper:lOk` ao final do método. |

## Boas Práticas Específicas

Para orientações gerais de automação ADVPR, consulte `best-practices.md`. As práticas abaixo são específicas ao Smart View.

**Comparação de arquivo baseline**
- Sempre gerar o arquivo AUTO na primeira execução e validar o conteúdo manualmente antes de promovê-lo para BASE
- Armazenar os arquivos BASE no compartilhamento centralizado (`\\10.171.80.90\Arquivos_Base_Congelada$\`) organizados por país e release

**Configuração do appserver.ini**
- Relatórios exigem a chave `URL_SMARTVIEW` na seção `[ADVPR]` apontando para a instância do Smart View (ex.: `URL_SMARTVIEW=http://localhost:7017`)
- Schema e Data exigem a chave `REST` na seção `[ADVPR]` apontando para a API REST do Protheus (ex.: `REST=http://localhost:9903/rest/`)
- Sem essas configurações, os testes não conseguem se comunicar com os serviços e falham imediatamente

**Normalização de datas**
- Datas dinâmicas presentes no relatório (períodos, datas de referência) devem ser normalizadas antes da comparação com o baseline
- Use `aReplace` para substituir intervalos de data completos (ex.: `"01/05/2023 até 31/05/2023"` → `"01/01/2015 até 31/01/2015"`)
- Use `aReplaceX` para substituir o conteúdo entre dois marcadores (útil quando a data aparece dentro de uma sequência de campos delimitados por `;`)
- Padronize sempre para `01/01/2015` como data de referência neutra

**Propriedades novas no Schema**
- O Framework pode adicionar propriedades novas ao schema entre releases
- Se a Squad confirmar que a mudança é esperada e não deve quebrar o teste, use o parâmetro `lIgnoreNewProperty := .T.` em `UTSchemaSmartView`
- Do contrário, atualize o arquivo BASE para refletir o novo schema

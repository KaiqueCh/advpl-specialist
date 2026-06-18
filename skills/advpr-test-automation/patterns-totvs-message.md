# Padrão ADVPR — Mensagem Única (TOTVS Message)

## Quando Usar

Use este padrão para testar integrações EAI (Enterprise Application Integration) via Mensagem Única TOTVS. Há dois fluxos distintos:

**Envio (tabela XX4)**

O Adapter deve estar configurado no SIGACFG (tabela XX4). O script usa `UTEAIActivate` para habilitar o envio durante o teste e, após executar a rotina padrão via `UTCommitData`, chama `UTVldEAI` para comparar o XML gerado com o arquivo base (baseline armazenado em `\\10.171.80.90\Arquivos_Base_Congelada$`). O campo `XX4_SENDER` (Envia?) deve permanecer como `2-Não` em ambiente de produção — o próprio `UTEAIActivate` altera o valor para `1-Sim` apenas durante a execução do teste.

**Recebimento (tabela XX3 / campo X3_UUID)**

A fila de execução deve estar cadastrada na tabela XX3. O script usa `UTExecEAI`, passando o código `X3_UUID` do cadastro. Após a execução, valida-se o resultado via `UTQueryDB` + `AssertTrue`.

**Nota de ambiente**

Após cadastrar localmente as tabelas XX3 e XX4, abra uma task no Ryver (fórum Automação de Testes Protheus) com o arquivo `.DTC` contendo somente o dado da mensagem a testar, para que o time importe o registro à Base Congelada. Sem isso o baseline de envio não existirá e `UTVldEAI` falhará.

## Exemplo de Script

### Envio — FINA010

```advpl
//-------------------------------------------------------------------
/*/{Protheus.doc} FIN010_001
Exemplo de script de mensagem única de envio
@author Automação.protheus
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD FIN010_001() CLASS FINA010TestCase

Local oHelper    := FWTestHelper():New()
Local cTable     := ""
Local cQuery     := ""
Local cED_Codigo := "FINN000001"
Local cED_Tipo   := "2"
Local cED_Uso    := "0"

// Variáveis de controle de erro da rotina automática
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

oHelper:Activate()

// Preenchimento dos campos
oHelper:UTSetValue("aCab","ED_CODIGO" , cED_Codigo)
oHelper:UTSetValue("aCab","ED_DESCRIC","SEM IMPOSTOS")
oHelper:UTSetValue("aCab","ED_TIPO"   , cED_Tipo)
oHelper:UTSetValue("aCab","ED_USO"    , cED_Uso)
oHelper:UTSetValue("aCab","ED_COND"   , "D")

// Habilita a utilização de Envio de mensagem através do EAI
oHelper:UTEAIActivate( 'FINA010' )

// Confirma a inclusão
oHelper:UTCommitData({|x,y| FINA010(x,y)},oHelper:GetaCab(),3)

// Valida o xml gerado no envio
oHelper:UTVldEAI( 'FINA010', 'FIN010_001' )
oHelper:AssertTrue(oHelper:lOk,"")

Return oHelper
```

### Recebimento — EAI

```advpl
//-------------------------------------------------------------------
/*/{Protheus.doc} EAI_001
Exemplo de teste case de recebimento
@author Automação
@since 11/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD EAI_001() CLASS EAITestCase

Local oHelper := FWTestHelper():New()
Local cTable  := ""
Local cQuery  := ""
Local cNome   := "CVC BRASIL OPERADORA E AGENCIA DE VIAGEM"

// Controle de erro
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

// Ativação da classe do robô
oHelper:Activate()

// Executa a mensagem única conforme cadastro na tabela XX3 (Fila de Integrações do EAI).
// X3_UUID: código que deve ser informado para a correta execução do EAI.
oHelper:UTExecEAI( "9000000000000000000037785" )

// Ponto de verificação
cTable := "SA3"
cQuery := "SA3.A3_NOME = '" + cNome + "'"

oHelper:UTQueryDB(cTable,"A3_NOME",cQuery,cNome)
oHelper:AssertTrue(oHelper:lOk,"")

Return( oHelper )
```

## Métodos Relevantes

| Método / Propriedade | Fluxo | Descrição |
|---|---|---|
| `FWTestHelper():New()` | Ambos | Instancia o helper de testes |
| `:Activate()` | Ambos | Ativa a classe do robô de testes |
| `:UTSetValue(cArray, cCampo, xValor)` | Envio | Preenche campo em array de cabeçalho/item antes do commit |
| `:UTEAIActivate(cRotina)` | Envio | Habilita o envio EAI para a rotina informada, ajustando `XX4_SENDER` temporariamente para `1-Sim` |
| `:UTCommitData(bBloco, aCab, nOpcao)` | Envio | Executa a rotina padrão (inclusão/alteração/exclusão) |
| `:UTVldEAI(cRotina, cTestCase)` | Envio | Valida o XML gerado comparando com o arquivo base no baseline |
| `:UTExecEAI(cUUID)` | Recebimento | Executa a mensagem única conforme cadastro XX3 identificado pelo `X3_UUID` |
| `:UTQueryDB(cTabela, cCampo, cWhere, xEsperado)` | Recebimento | Consulta o banco após a execução e verifica o valor esperado |
| `:AssertTrue(lCondicao, cMensagem)` | Ambos | Ponto de asserção; falha o test case se a condição for falsa |
| `.lOk` (propriedade) | Ambos | Indica se a última operação foi bem-sucedida |

Para assinatura completa de parâmetros e demais métodos do helper, consulte `api-fwtesthelper.md`.

## Boas Práticas Específicas

- **`lMsErroAuto` e `lAutoErrNoFile` como `Private` são uma exceção legítima** neste padrão. A rotina automática do Protheus exige que essas variáveis existam no escopo global durante a execução do MsExecAuto/bloco de commit. Nunca as declare como `Local` nesses scripts — a rotina padrão não as encontraria.
- **Envio depende do arquivo BASE no baseline.** Antes de rodar o script de envio em ambiente de CI, certifique-se de que o arquivo `.DTC` correspondente já foi importado à Base Congelada. Sem o baseline, `UTVldEAI` sempre retornará falha, independentemente do XML gerado.
- **Recebimento depende do cadastro XX3 e do `X3_UUID`.** O código passado a `UTExecEAI` deve existir exatamente na tabela XX3 do ambiente de teste. Qualquer divergência (UUID errado, cadastro ausente) causará falha silenciosa na execução da fila.
- **`XX4_SENDER` deve permanecer `2-Não` fora dos testes.** O método `UTEAIActivate` alterna o valor automaticamente durante o teste; não altere o cadastro manualmente para `1-Sim`, pois isso afetaria rotinas que não possuem integração.
- **Valide sempre com `AssertTrue` ao final.** Tanto em envio (`UTVldEAI` + `AssertTrue`) quanto em recebimento (`UTQueryDB` + `AssertTrue`), a asserção explícita é o ponto formal de falha do test case. Omiti-la faz o robô registrar o caso como "passou" mesmo com dados incorretos.
- Para boas práticas gerais de scripts ADVPR (nomenclatura, estrutura de classe, organização de test cases), consulte `best-practices.md`.

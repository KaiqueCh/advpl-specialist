# Padrão ADVPR — Rotinas de Processamento

## Quando Usar

Rotinas de processamento são rotinas que executam alterações em massa ou em grande escala utilizando informações contidas no banco de dados. Use este padrão quando o teste cobrir:

- Apurações contábeis, fiscais ou financeiras (ex.: CTBA211, FINA140)
- Rotinas de geração em lote (lotes contábeis, remessas, retornos)
- Processos batch que lêem diversas tabelas e geram registros derivados

A sequência obrigatória no script ADVPR é:

1. Declarar as privates da rotina de origem e de controle de erro (`lMsErroAuto`, `lAutoErrNoFile`).
2. Ativar a classe: `oHelper:Activate()`.
3. Quando o teste exige outra filial, usar `oHelper:ChangeFil(...)` e restaurar ao final.
4. Alterar a `dDataBase` quando necessário e restaurar com `dDataBase := Date()` após o commit.
5. Definir o nome da função com `SetFunName(...)` quando aplicável.
6. Alterar as perguntas do SX1 com `oHelper:UTChangePergunte(...)`.
7. Gravar/processar com `oHelper:UTCommitData()` passando o code block que chama a rotina e o flag de automático.
8. Verificar com `oHelper:UTQueryDB()` + `oHelper:AssertTrue()`.

## Exemplo de Script

O exemplo abaixo é baseado no caso real CTBA211 (Apuração de Lucros/Perdas — módulo Contabilidade Gerencial).

> Nota: no exemplo original do TDN, a chamada de perguntas cobre os 31 parâmetros do SX1 (07 a 27 omitidos abaixo para concisão; o padrão se repete: `oHelper:UTChangePergunte("CTB211","NN",<valor>)`).

```advpl
//-----------------------------------------------------------------
/*/{Protheus.doc} CTA211_001
@author ADVPR
@since 09/01/2017
/*/
//-----------------------------------------------------------------
METHOD CTA211_001() CLASS CTBA211TestCase

Local oHelper := FWTestHelper():New() // Instancia a classe do robô
Local cTable  := ""                   // Variável usada no ponto de verificação
Local cQuery  := ""                   // Variável usada no ponto de verificação
Local lAuto   := .T.

// Variáveis private provenientes da rotina de origem
Private oProcess
Private aCols    := {} // Utilizada na conversão das moedas
Private cSeqCorr := ""
Private oSelf

// Variáveis private de controle de erro
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

// Ativação da classe do robô
oHelper:Activate()

// Altera a filial do sistema
oHelper:ChangeFil( "D MG 01" )

// Altera a database
dDataBase := CtoD( "09/01/2016" )

SetFunName( "CTBA211" )

// Altera as perguntas do SX1
oHelper:UTChangePergunte("CTB211","01","20160101")  // Data Inicial de Apuracao
oHelper:UTChangePergunte("CTB211","02","20161231")  // Data Final de Apuracao
oHelper:UTChangePergunte("CTB211","03","CT0001")    // Numero do Lote
oHelper:UTChangePergunte("CTB211","04","001")       // Numero do SubLote
oHelper:UTChangePergunte("CTB211","05","CT0001")    // Num Documento
oHelper:UTChangePergunte("CTB211","06","005")       // Cod. Historico Padrao
oHelper:UTChangePergunte("CTB211","28",1)           // Reprocessa Saldos? 1-Sim
oHelper:UTChangePergunte("CTB211","29",2)           // Seleciona Filiais? 2-Não
oHelper:UTChangePergunte("CTB211","30","D MG 01 ")  // Filial De
oHelper:UTChangePergunte("CTB211","31","D MG 01 ")  // Filial Ate

// Gravação/processamento dos dados
oHelper:UTCommitData( { |X| CTBA211( x ) }, lAuto )

// Restaura a database do sistema
dDataBase := Date()

// Ponto de verificação CT2
cTable := "CT2"
cQuery := "CT2_LOTE = 'CT0001' AND CT2_HP = '005'"

oHelper:UTQueryDB( cTable, "CT2_LOTE", cQuery, 'CT0001'   )
oHelper:UTQueryDB( cTable, "CT2_HP"  , cQuery, '005'      )
oHelper:UTQueryDB( cTable, "CT2_DATA", cQuery, '20161231' )

// Resultado esperado
oHelper:AssertTrue( oHelper:lOk, "" )

Return( oHelper )
```

## Métodos Relevantes

Detalhes completos de assinatura e parâmetros em `api-fwtesthelper.md`.

| Método / Símbolo | Descrição |
|---|---|
| `FWTestHelper():New()` | Construtor — instancia a classe do robô de testes. |
| `:Activate()` | Ativa o ambiente de testes; deve ser chamado antes de qualquer operação. |
| `:ChangeFil(cFilial)` | Altera a filial ativa no contexto do teste. Deve ser restaurada ao final (ver Boas Práticas). |
| `SetFunName(cFunc)` | Função nativa — define o nome da função corrente; exigida por algumas rotinas de processamento para auditoria interna. |
| `:UTChangePergunte(cGroup, cSeq, xVal)` | Altera o valor de uma pergunta do SX1 para o grupo e sequência indicados. |
| `:UTCommitData(bBlock, lAuto)` | Executa o code block que chama a rotina de processamento. O parâmetro `lAuto` (`.T.`) habilita o flag de automático — equivale a rodar a rotina em modo batch sem interação do usuário. |
| `:UTQueryDB(cTable, cField, cWhere, xExpected)` | Consulta o banco após o processamento e acumula o resultado em `lOk`. Prefira este método a qualquer loop `While`/`For` manual de verificação. |
| `:AssertTrue(lCond, cMsg)` | Valida a condição acumulada. Em rotinas de processamento, é sempre chamado com `oHelper:lOk` após todas as chamadas a `UTQueryDB`. |
| `lMsErroAuto` / `lAutoErrNoFile` | Privates de controle de erro — inicializadas no próprio script (ver Boas Práticas). |

## Boas Práticas Específicas

### Restaurar filial com `ChangeFil` de volta

Toda chamada a `oHelper:ChangeFil("filial destino")` deve ter uma chamada correspondente ao final do método para restaurar a filial original (ou confiar no `TearDown` do TestCase, se o Setup a definir). Não restaurar a filial pode contaminar os testes seguintes do mesmo suite.

### Restaurar `dDataBase` após o commit

Altere `dDataBase` antes de `UTCommitData` e restaure imediatamente após:

```advpl
dDataBase := CtoD( "09/01/2016" )
oHelper:UTCommitData( { |X| CTBA211( x ) }, lAuto )
dDataBase := Date()
```

Deixar `dDataBase` alterada após o processamento causa efeitos colaterais em rotinas chamadas depois (datas incorretas em logs, lotes e documentos gerados por outros métodos do suite).

### Privates de origem e de controle de erro são exceção legítima

Em scripts ADVPR normais, todas as variáveis devem ser `Local`. A única exceção são as privates exigidas pela rotina de origem (`oProcess`, `aCols`, `cSeqCorr`, `oSelf`) e as de controle de erro (`lMsErroAuto`, `lAutoErrNoFile`). Declare-as explicitamente com `Private` e inicialize-as antes de `oHelper:Activate()`.

### Verificação via `UTQueryDB` — não use loops manuais

Não use `While`/`For`, `DbSeek` ou `RecLock` para verificar o resultado do processamento. Use exclusivamente `UTQueryDB`:

- **Não use:** loop `While !Eof()` sobre a tabela de resultado
- **Use:** `oHelper:UTQueryDB(cTable, cField, cWhere, xExpected)` para cada campo a verificar

`UTQueryDB` é seguro para ambiente multi-filial, respeita soft-delete e acumula o resultado em `oHelper:lOk` para que `AssertTrue` consuma ao final.

### Nunca use `RecLock`/`MsUnLock` no script de teste

O script ADVPR não deve abrir locks diretamente. Todo acesso a dados de escrita deve passar pela rotina de processamento invocada dentro do code block de `UTCommitData`.

Para dúvidas sobre outros padrões (MVC, ExecAuto, relatórios), consulte os demais arquivos desta skill. Regras gerais de escrita de scripts estão em `best-practices.md`.

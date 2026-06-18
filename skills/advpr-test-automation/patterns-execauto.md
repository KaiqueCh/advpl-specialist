# Padrão ADVPR — Rotinas Automáticas (ExecAuto)

## Quando Usar

Rotina automática é uma funcionalidade do Protheus que realiza operações sistêmicas sem interface gráfica. No contexto de testes ADVPR, este padrão é aplicado sempre que o cenário de teste precisar acionar uma rotina que, no fonte Protheus, possui chamadas para `EnchAuto()` e/ou `MSExecAuto()`.

Para identificar se uma rotina é automática, busque no fonte da rotina padrão as ocorrências de `EnchAuto()` ou `MSExecAuto()`. Se qualquer uma dessas funções estiver presente, o script de teste deve seguir o padrão descrito neste arquivo.

Exemplos de rotinas automáticas comuns: MATA030 (cadastro de clientes), MATA410 (pedido de venda), MATA461, MATA700, entre outras rotinas de faturamento e estoque.

## Exemplo de Script

### Passos do padrão ExecAuto

1. Instanciar a classe: `oHelper := FWTestHelper():New()`
2. Declarar as variáveis `Private` exigidas pela rotina de origem (`lMsErroAuto`, `lAutoErrNoFile`)
3. Ativar a classe: `oHelper:Activate()`
4. Atribuir dados de cabeçalho com `oHelper:UTSetValue("aCab", "CAMPO", xValor)`
5. Atribuir dados de itens (quando houver grid) com `oHelper:UTSetValue("aItens", "CAMPO", xValor)`
6. Gravar com `oHelper:UTCommitData()`, passando um code block que chama a rotina, `GetaCab()`, opcionalmente `GetaItens()`, e o número da operação (3 = inclusão)
7. Verificar os dados gravados com `oHelper:UTQueryDB()` e finalizar com `oHelper:AssertTrue()`

### Exemplo 1 — MATA030 (formulário, inclusão de cliente)

```advpl
//-------------------------------------------------------------------
/*/{Protheus.doc} MAT030_009
Inclusão de cliente com preenchimento de campos obrigatórios
@author ADVPR
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD MAT030_009() CLASS MATA030TestCase

Local oHelper := FWTestHelper():New()   // Instancia a classe do robô
Local cTable  := ""                     // Variável usada no ponto de verificação
Local cQuery  := ""                     // Variável usada no ponto de verificação

// Variáveis private provenientes da rotina de origem
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

// Ativação da classe do robô
oHelper:Activate()

// Atribuição dos dados
oHelper:UTSetValue( "aCab", "A1_COD"    , "FAT909"             )
oHelper:UTSetValue( "aCab", "A1_LOJA"   , "01"                 )
oHelper:UTSetValue( "aCab", "A1_NOME"   , "CAMPOS OBRIGATORIOS")
oHelper:UTSetValue( "aCab", "A1_NREDUZ" , "CAMPOS OBRIGATORIOS")
oHelper:UTSetValue( "aCab", "A1_END"    , "Rua Salete, 154"    )
oHelper:UTSetValue( "aCab", "A1_TIPO"   , "F"                  )
oHelper:UTSetValue( "aCab", "A1_EST"    , "SP"                 )
oHelper:UTSetValue( "aCab", "A1_COD_MUN", "50308"              )

// Gravação dos dados: UTCommitData recebe os mesmos parâmetros da ExecAuto()
oHelper:UTCommitData( { |a,b| MATA030( a, b ) }, oHelper:GetaCab(), 3 )

// Ponto de verificação
cTable := "SA1"
cQuery := "A1_COD = 'FAT909' AND A1_LOJA = '01'"

oHelper:UTQueryDB( cTable, "A1_NOME"   , cQuery, "CAMPOS OBRIGATORIOS" )
oHelper:UTQueryDB( cTable, "A1_NREDUZ" , cQuery, "CAMPOS OBRIGATORIOS" )
oHelper:UTQueryDB( cTable, "A1_END"    , cQuery, "Rua Salete, 154"     )
oHelper:UTQueryDB( cTable, "A1_TIPO"   , cQuery, "F"                   )
oHelper:UTQueryDB( cTable, "A1_EST"    , cQuery, "SP"                  )
oHelper:UTQueryDB( cTable, "A1_COD_MUN", cQuery, "50308"               )

// Resultado esperado
oHelper:AssertTrue( oHelper:lOk, "" )

Return( oHelper )
```

### Exemplo 2 — MATA410 (grid, inclusão de pedido de venda com itens)

```advpl
//-------------------------------------------------------------------
/*/{Protheus.doc} MATA410_021
Incluir Pedido de venda de Complemento de IPI.
@author ADVPR
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD MAT410_021() CLASS MATA410TestCase

Local oHelper := FWTestHelper():New() // Instancia a classe do robô
Local cTable  := ""                   // Variável usada no ponto de verificação
Local cQuery  := ""                   // Variável usada no ponto de verificação
Local cOrder  := "FAT024"
Local cCustom := "FAT008"
Local cProd   := "FAT000000000000000000000000012"

// Variáveis private provenientes da rotina de origem
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

// Ativação da classe do robô
oHelper:Activate()

// Atribuição dos dados do cabeçalho
oHelper:UTSetValue( "aCab", "C5_NUM"    , cOrder    )
oHelper:UTSetValue( "aCab", "C5_TIPO"   , "P"       )
oHelper:UTSetValue( "aCab", "C5_CLIENTE", cCustom   )
oHelper:UTSetValue( "aCab", "C5_LOJACLI", "01"      )
oHelper:UTSetValue( "aCab", "C5_CLIENT" , cCustom   )
oHelper:UTSetValue( "aCab", "C5_LOJAENT", "01"      )
oHelper:UTSetValue( "aCab", "C5_TIPOCLI", "F"       )
oHelper:UTSetValue( "aCab", "C5_CONDPAG", "001"     )
oHelper:UTSetValue( "aCab", "C5_EMISSAO", dDataBase )

// Atribuição dos dados do item
oHelper:UTSetValue( "aItens", "C6_ITEM"   , "01"   )
oHelper:UTSetValue( "aItens", "C6_PRODUTO", cProd  )
oHelper:UTSetValue( "aItens", "C6_QTDVEN" , 0      )
oHelper:UTSetValue( "aItens", "C6_PRCVEN" , 700.00 )
oHelper:UTSetValue( "aItens", "C6_VALOR"  , 700.00 )
oHelper:UTSetValue( "aItens", "C6_TES"    , "560"  )

// Campos como se tivesse executado a tela de Notas Fiscais de Origem - Complemento
oHelper:UTSetValue( "aItens", "C6_NFORI"  , "000671" )
oHelper:UTSetValue( "aItens", "C6_SERIORI", "1"      )
oHelper:UTSetValue( "aItens", "C6_ITEMORI", "01"     )

// Gravação dos dados (inclusão): UTCommitData recebe os mesmos parâmetros da ExecAuto()
oHelper:UTCommitData( { |x,y,z| MATA410( x, y, z ) }, oHelper:GetaCab(), oHelper:GetaItens(), 3 )

// Resultado esperado - Cabeçalho
cTable := "SC5"
cQuery := "C5_NUM = '" + cOrder + "'"

oHelper:UTQueryDB( cTable, "C5_NUM"    , cQuery, cOrder  )
oHelper:UTQueryDB( cTable, "C5_CLIENTE", cQuery, cCustom )
oHelper:UTQueryDB( cTable, "C5_LOJACLI", cQuery, "01"    )
oHelper:AssertTrue( oHelper:lOk, "" )

// Resultado esperado - Itens
cTable := "SC6"
cQuery := "C6_NUM = '" + cOrder + "' AND C6_ITEM = '01' "

oHelper:UTQueryDB( cTable, "C6_PRODUTO", cQuery, cProd  )
oHelper:UTQueryDB( cTable, "C6_VALOR"  , cQuery, 700.00 )
oHelper:AssertTrue( oHelper:lOk, "" )

Return( oHelper )
```

## Métodos Relevantes

Os detalhes completos de assinatura e parâmetros de cada método estão em `api-fwtesthelper.md`. Abaixo o resumo específico para scripts de rotinas automáticas.

| Método / Propriedade | Papel no padrão ExecAuto |
|---|---|
| `FWTestHelper():New()` | Instancia a classe do robô de testes |
| `:Activate()` | Ativa o helper antes de qualquer atribuição de dados |
| `:UTSetValue("aCab", cCampo, xValor)` | Atribui valor a um campo do cabeçalho |
| `:UTSetValue("aItens", cCampo, xValor)` | Atribui valor a um campo de item (linha de grid) |
| `:GetaCab()` | Retorna o array de cabeçalho montado para ser passado à ExecAuto |
| `:GetaItens()` | Retorna o array de itens montado para ser passado à ExecAuto |
| `:UTCommitData()` | Executa a gravação chamando a rotina via code block |
| `:UTQueryDB(cAlias, cCampo, cWhere, xEsperado)` | Consulta o banco para verificar o valor gravado |
| `:AssertTrue(lCondicao, cMsg)` | Valida o resultado; falha o teste se `lCondicao` for `.F.` |
| `.lOk` | Propriedade booleana que acumula o resultado das verificações `UTQueryDB` |

### Assinatura de `UTCommitData`

```advpl
// Rotina sem grid (somente cabeçalho)
oHelper:UTCommitData( { |a,b| ROTINA( a, b ) }, oHelper:GetaCab(), 3 )

// Rotina com grid (cabeçalho + itens)
oHelper:UTCommitData( { |x,y,z| ROTINA( x, y, z ) }, oHelper:GetaCab(), oHelper:GetaItens(), 3 )
```

Parâmetros do code block passado a `UTCommitData`:
- **1o parâmetro do code block:** array de cabeçalho (`aCab`) — equivale ao 1o parâmetro da ExecAuto
- **2o parâmetro do code block:** array de itens (`aItens`) ou número da operação em rotinas sem grid
- **3o parâmetro do code block (quando houver grid):** número da operação
- **Número da operação:** `3` = inclusão (mesmo valor usado na chamada original de `MSExecAuto`)

### Variáveis `Private` da rotina de origem

```advpl
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.
```

Essas duas variáveis são exigidas internamente pela rotina padrão do Protheus para controle de erros da ExecAuto. Devem ser declaradas logo após as variáveis `Local`, antes de `oHelper:Activate()`.

## Boas Práticas Específicas

> Referência complementar: `best-practices.md`

**Gravação: use `UTCommitData`, não acesso direto ao banco.** O script nunca deve abrir locks manuais para gravar registros. `UTCommitData` encapsula a chamada à rotina automática e garante que todas as validações, gatilhos e integridade referencial do Protheus sejam respeitados. Não use `RecLock`/`MsUnLock` para persistir dados em scripts ADVPR.

**Busca: use `UTFindReg`, não navegação de workarea.** Para localizar um registro antes de verificar seus campos, utilize `UTFindReg`. Não use `DbSeek` diretamente em scripts ADVPR, pois isso cria dependência de posicionamento de workarea e pode causar falsos positivos ou comportamento inconsistente entre execuções.

**Verificação: use `UTQueryDB` exclusivamente para leitura.** Queries no banco, dentro do script ADVPR, existem apenas para conferir valores gravados. Não use `UTQueryDB` para montar dados de entrada nem para controlar fluxo do teste.

**Sem laços de iteração nos scripts.** Scripts ADVPR representam casos de teste atômicos e autocontidos. Não use `While`/`For` para percorrer registros; se o cenário exige múltiplos registros, crie métodos de teste separados.

**Não altere parâmetros MV_ nos scripts.** A alteração de parâmetros do sistema via `PutMV` dentro do script pode afetar outros testes e o ambiente de produção. Se o cenário depende de um valor específico de parâmetro, documente como pré-condição e configure o ambiente antes da suíte.

**As variáveis `Private lMsErroAuto` e `Private lAutoErrNoFile` são uma exceção legítima à regra de não usar `Private`.** A regra geral do plugin proíbe variáveis `Private` em código novo (ver `best-practices.md`). Porém, essas duas variáveis são lidas internamente pela rotina padrão do Protheus durante a execução da ExecAuto para controle de fluxo de erros. O script ADVPR precisa declará-las como `Private` exatamente com esses nomes para que a rotina as encontre no escopo correto. Trata-se de um requisito da interface com o fonte Protheus, não de uma escolha de estilo.

**Declare todas as variáveis `Local` no topo do método.** Mesmo em scripts de teste, aplica-se a convenção ADVPL padrão: todas as declarações `Local` devem aparecer logo após a assinatura do método, antes de qualquer instrução executável. As variáveis `Private` da rotina de origem devem vir imediatamente após os `Local`, antes de `oHelper:Activate()`.

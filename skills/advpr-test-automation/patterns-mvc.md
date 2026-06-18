# ADVPR — Padrões de Script para Rotinas MVC

Scripts de teste para rotinas que seguem o padrão MVC do Protheus exigem uma sequência específica de chamadas ao modelo de dados (`FWLoadModel`) e à classe do robô (`FWTestHelper`). Este documento descreve quando usar este padrão, os exemplos completos extraídos do TDN e os métodos envolvidos.

## Quando Usar

Use este padrão sempre que o fonte da rotina a ser testada apresentar as três características a seguir:

1. `#Include "FWMVCDEF.CH"` no cabeçalho do fonte
2. Uma `Static Function ModelDef()` que define o modelo de dados
3. (na grande maioria dos casos) Uma `Static Function ViewDef()` que define a visão

Rotinas MVC **não** devem ter gravação direta no banco (proibido por `best-practices.md`). Toda gravação passa pelo modelo (`UTCommitData`) e todo posicionamento de registro passa por `UTFindReg`.

## Exemplo de Script

### Check List de Implementação MVC

Siga esta sequência obrigatória em todo script MVC:

1. Instanciar o modelo de dados com `FWLoadModel()`
2. Definir a operação com `SetOperation()` — `MODEL_OPERATION_INSERT`, `MODEL_OPERATION_UPDATE` ou `MODEL_OPERATION_DELETE`
3. Ativar o modelo com `oModel:Activate()`
4. Atribuir o modelo à classe do robô com `oHelper:SetModel()`
5. Ativar a classe do robô com `oHelper:Activate()`
6. Inclusão/Alteração: atribuir dados com `UTSetValue()`
7. Alteração/Exclusão: posicionar no registro com `UTFindReg()` **antes** de `SetOperation()`
8. Gravar com `UTCommitData()`
9. Verificar o resultado com `UTQueryDB()` + `AssertTrue()`/`AssertFalse()`

---

### Inclusão (Formulário) — TMKA260

```advpl
//-------------------------------------------------------------------
/*/{Protheus.doc} TMKA260_001
Inclusão de prospect
@author ADVPR
@version 1.00
/*/
//-------------------------------------------------------------------
METHOD TMK260_001() CLASS TMKA260TestCase

Local oHelper := FWTestHelper():New()     // Instancia a classe do robô
Local oModel  := FWLoadModel( "TMKA260" ) // Carrega o modelo de dados
Local cTable  := ""                       // Variável usada no ponto de verificação
Local cQuery  := ""                       // Variável usada no ponto de verificação
Local cCod    := "TMK100"
Local cLoja   := "01"
Local cNome   := "PROSPECT TMK100"
Local cNreduz := "TMK100"
Local cTipo   := "F"
Local cEnd    := "Av. Braz Leme, 1000"
Local cMun    := "SAO PAULO"
Local cBairro := "Santana"
Local cEst    := "SP"

// Definição da operação do sistema
oModel:SetOperation( MODEL_OPERATION_INSERT )

// Ativação do modelo de dados
oModel:Activate()

// Atribuição do modelo de dados na classe do robô
oHelper:SetModel( oModel )

// Ativação da classe do robô
oHelper:Activate()

// Atribuição dos dados
oHelper:UTSetValue( "SUSMASTER", "US_COD"   , cCod    )
oHelper:UTSetValue( "SUSMASTER", "US_LOJA"  , cLoja   )
oHelper:UTSetValue( "SUSMASTER", "US_NOME"  , cNome   )
oHelper:UTSetValue( "SUSMASTER", "US_NREDUZ", cNreduz )
oHelper:UTSetValue( "SUSMASTER", "US_TIPO"  , cTipo   )
oHelper:UTSetValue( "SUSMASTER", "US_END"   , cEnd    )
oHelper:UTSetValue( "SUSMASTER", "US_MUN"   , cMun    )
oHelper:UTSetValue( "SUSMASTER", "US_BAIRRO", cBairro )
oHelper:UTSetValue( "SUSMASTER", "US_EST"   , cEst    )

// Gravação dos dados
oHelper:UTCommitData()

// Ponto de verificação
cTable := "SUS"
cQuery := "US_COD = '" + cCod + "' AND US_LOJA = '" + cLoja + "'"

oHelper:UTQueryDB( cTable, "US_COD"   , cQuery, cCod    )
oHelper:UTQueryDB( cTable, "US_LOJA"  , cQuery, cLoja   )
oHelper:UTQueryDB( cTable, "US_NOME"  , cQuery, cNome   )
oHelper:UTQueryDB( cTable, "US_NREDUZ", cQuery, cNreduz )
oHelper:UTQueryDB( cTable, "US_TIPO"  , cQuery, cTipo   )
oHelper:UTQueryDB( cTable, "US_END"   , cQuery, cEnd    )
oHelper:UTQueryDB( cTable, "US_MUN"   , cQuery, cMun    )
oHelper:UTQueryDB( cTable, "US_BAIRRO", cQuery, cBairro )
oHelper:UTQueryDB( cTable, "US_EST"   , cQuery, cEst    )

// Resultado esperado
oHelper:AssertTrue( oHelper:lOk, "" )

Return( oHelper )
```

---

### Alteração (Formulário) — TMKA260

A diferença em relação à inclusão é: `UTFindReg` posiciona o registro **antes** de `SetOperation`, e a constante passa a ser `MODEL_OPERATION_UPDATE`. Apenas os campos alterados precisam ser passados a `UTSetValue`.

```advpl
//-------------------------------------------------------------------
/*/{Protheus.doc} TMKA260_002
Alteração de prospect
@author ADVPR
@version 1.00
/*/
//-------------------------------------------------------------------
METHOD TMK260_002() CLASS TMKA260TestCase

Local oHelper := FWTestHelper():New()
Local oModel  := FWLoadModel( "TMKA260" )
Local cTable  := ""
Local cQuery  := ""
Local cCod    := "PRO001"
Local cLoja   := "01"
Local cEnd    := "AV. BRAZ LEME, 2000"
Local cCep    := "02511000"

// Posiciona no registro
oHelper:UTFindReg( "SUS", 1, cCod + cLoja )

// Definição da operação do sistema
oModel:SetOperation( MODEL_OPERATION_UPDATE )

// Ativação do modelo de dados
oModel:Activate()

// Atribuição do modelo de dados na classe do robô
oHelper:SetModel( oModel )

// Ativação da classe do robô
oHelper:Activate()

// Atribuição dos dados
oHelper:UTSetValue( "SUSMASTER", "US_END", cEnd )
oHelper:UTSetValue( "SUSMASTER", "US_CEP", cCep )

// Gravação dos dados
oHelper:UTCommitData()

// Ponto de verificação
cTable := "SUS"
cQuery := "US_COD = '" + cCod + "' AND US_LOJA = '" + cLoja + "'"

oHelper:UTQueryDB( cTable, "US_END", cQuery, cEnd )
oHelper:UTQueryDB( cTable, "US_CEP", cQuery, cCep )

// Resultado esperado
oHelper:AssertTrue( oHelper:lOk, "" )

Return( oHelper )
```

---

### Exclusão (Formulário) — TMKA260

Para exclusão usa-se `MODEL_OPERATION_DELETE`. Não há `UTSetValue`. O `UTQueryDB` pós-commit verifica que o registro **não existe mais** (valor esperado vazio).

```advpl
//-------------------------------------------------------------------
/*/{Protheus.doc} TMKA260_003
Exclusão de prospect
@author ADVPR
@version 1.00
/*/
//-------------------------------------------------------------------
METHOD TMK260_003() CLASS TMKA260TestCase

Local oHelper := FWTestHelper():New()
Local oModel  := FWLoadModel( "TMKA260" )
Local cTable  := ""
Local cQuery  := ""
Local cCod    := "PRO002"
Local cLoja   := "01"

// Posiciona no registro
oHelper:UTFindReg( "SUS", 1, cCod + cLoja )

// Definição da operação do sistema
oModel:SetOperation( MODEL_OPERATION_DELETE )

// Ativação do modelo de dados
oModel:Activate()

// Atribuição do modelo de dados na classe do robô
oHelper:SetModel( oModel )

// Ativação da classe do robô
oHelper:Activate()

// Gravação dos dados
oHelper:UTCommitData()

// Ponto de verificação
cTable := "SUS"
cQuery := "US_COD = '" + cCod + "' AND US_LOJA = '" + cLoja + "'"

oHelper:UTQueryDB( cTable, "US_COD" , cQuery, "" )
oHelper:UTQueryDB( cTable, "US_LOJA", cQuery, "" )

// Resultado esperado
oHelper:AssertTrue( oHelper:lOk, "" )

Return( oHelper )
```

---

### Rotina com Grid — OMSA010

Quando a rotina possui grid, é necessário navegar pelo modelo MVC diretamente: `oModel:GetModel(grid)` retorna o sub-modelo da grid, e sobre ele são chamados `GoLine`, `GetValue` e `DeleteLine`. Para adicionar linha usa-se `oHelper:UTAddLine`.

```advpl
//-------------------------------------------------------------------
/*/{Protheus.doc} OMS010_018
Alteração: Deletar registro da grid e incluir uma nova
@author ADVPR
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD OMS010_018() CLASS OMSA010TestCase

Local oHelper  := FWTestHelper():New()
Local oModel   := FWLoadModel( "OMSA010" )
Local cTable   := ""
Local cQuery   := ""
Local cItemEx  := ""
Local cItemAd  := ""
Local cCodProd := "FAT000000000000000000000000024"

// Posiciona no registro
oHelper:UTFindReg( "DA0", 1, "FT1" )

// Definição da operação do sistema
oModel:SetOperation( MODEL_OPERATION_UPDATE )
oModel:Activate()
oHelper:SetModel( oModel )
oHelper:Activate()

// Deleta o item da grid
oModel:GetModel( "DA1DETAIL" ):GoLine( 1 )
cItemEx := oModel:GetModel( "DA1DETAIL" ):GetValue( "DA1_ITEM" )
oModel:GetModel( "DA1DETAIL" ):DeleteLine()

// Adiciona uma nova linha na grid
oHelper:UTAddLine( "DA1DETAIL" )

// Atribuição dos dados
cItemAd := StrZero( Val( cItemEx ) + 1, 4 )
oHelper:UTSetValue( "DA1DETAIL", "DA1_ITEM"  , cItemAd  )
oHelper:UTSetValue( "DA1DETAIL", "DA1_CODPRO", cCodProd )
oHelper:UTSetValue( "DA1DETAIL", "DA1_PRCVEN", 1024.36  )

// Gravação da rotina
oHelper:UTCommitData()

// Resultado esperado - Linha adicionada
cTable := "DA1"
cQuery := "DA1.DA1_CODTAB = 'FT1' AND DA1.DA1_ITEM = '" + cItemAd + "' "
oHelper:UTQueryDB( cTable, "DA1_ITEM"  , cQuery, cItemAd  )
oHelper:UTQueryDB( cTable, "DA1_CODPRO", cQuery, cCodProd )
oHelper:UTQueryDB( cTable, "DA1_PRCVEN", cQuery, 1024.36  )
oHelper:AssertTrue( oHelper:lOk, "" )

// Resultado esperado - Linha deletada
cTable := "DA1"
cQuery := "DA1.DA1_CODTAB = 'FT1' AND DA1.DA1_ITEM = '" + cItemEx + "' "
oHelper:UTQueryDB( cTable, "DA1_ITEM", cQuery, cItemEx )
oHelper:AssertFalse( oHelper:lOk, cItemEx )

Return( oHelper )
```

## Métodos Relevantes

Os métodos abaixo aparecem nos scripts MVC. A assinatura completa e os parâmetros de cada um estão documentados em `api-fwtesthelper.md`.

| Método / Função | Origem | Descrição |
|---|---|---|
| `FWLoadModel(cRotina)` | Nativa Protheus | Carrega e retorna o modelo de dados MVC da rotina |
| `oModel:SetOperation(nOp)` | Modelo MVC | Define a operação: `MODEL_OPERATION_INSERT`, `MODEL_OPERATION_UPDATE` ou `MODEL_OPERATION_DELETE` |
| `oModel:Activate()` | Modelo MVC | Ativa o modelo antes de atribuir dados |
| `oHelper:SetModel(oModel)` | FWTestHelper | Associa o modelo à classe do robô |
| `oHelper:Activate()` | FWTestHelper | Ativa a classe do robô após `SetModel` |
| `oHelper:UTSetValue(cComp, cCampo, xVal)` | FWTestHelper | Atribui valor a um campo do componente/grid |
| `oHelper:UTFindReg(cAlias, nOrdem, cChave)` | FWTestHelper | Posiciona no registro de forma padronizada (substitui posicionamento manual via workarea) |
| `oHelper:UTAddLine(cComp)` | FWTestHelper | Adiciona linha em um componente de grid |
| `oHelper:UTCommitData()` | FWTestHelper | Grava os dados pelo modelo (equivale ao Ok da tela) |
| `oHelper:UTQueryDB(cTab, cCampo, cWhere, xEsp)` | FWTestHelper | Executa query para verificação do resultado esperado |
| `oHelper:AssertTrue(lCond, cMsg)` | FWTestHelper | Asserção positiva — falha se `lCond` for `.F.` |
| `oHelper:AssertFalse(lCond, cMsg)` | FWTestHelper | Asserção negativa — falha se `lCond` for `.T.` |
| `oModel:GetModel(cComp)` | Modelo MVC | Retorna o sub-modelo de um componente (grid) |
| `subModelo:GoLine(nLinha)` | Sub-modelo MVC | Posiciona o cursor na linha indicada da grid |
| `subModelo:GetValue(cCampo)` | Sub-modelo MVC | Lê o valor de um campo da linha atual da grid |
| `subModelo:DeleteLine()` | Sub-modelo MVC | Deleta a linha atual da grid |

## Boas Práticas Específicas

As regras abaixo de `best-practices.md` têm aplicação direta em scripts MVC:

**Proibições absolutas**

- Gravação direta no banco via bloqueio de registro — terminantemente proibida (ver `best-practices.md` seção "Alteração direta no banco de dados"). Toda gravação deve passar por `UTCommitData`, que aciona o modelo MVC e respeita as regras de negócio.
- Posicionamento manual via workarea — proibido. Use sempre `UTFindReg`, que encapsula o posicionamento de forma padronizada e auditável (ver `best-practices.md` seção "Posicionamento no banco de dados").
- Queries diretas no banco (`Select`, `RetSQLName`, `D_E_L_E_T_` etc.) — proibidas nos scripts. A única forma válida de consultar dados para verificação é pelo método `UTQueryDB` (ver `best-practices.md` seção "Comandos de banco de dados").
- Alteração direta de parâmetros SX6 — não usar funções de escrita direta em SX. Use `UTSetParam()` e sempre restaure com `UTRestParam()` após o commit (ver `best-practices.md` seção "Alteração de SXs").

**Restauração de estado após o test case**

- Sempre que usar `UTSetParam()` para alterar um parâmetro, restaurar o valor padrão com `UTRestParam()` após `UTCommitData()`.
- Sempre que trocar de filial com `ChangeFil()`, restaurar a filial do Setup do robô após o resultado esperado.
- Sempre que alterar a data base (`dDataBase`), restaurar com `dDataBase := DATE()` para não impactar os demais casos de teste.

**Variáveis e CHs**

- Não utilizar variáveis `Private`, públicas ou estáticas nos scripts — use apenas `Local`.
- Não incluir CHs de produto dentro de TestCase, Group ou Suite.
- Usar `help()` para envio de mensagens (dispensa `IsBlind` nas tratativas automáticas).

# Classe FWTestHelper — Referência de Métodos

A classe `FWTestHelper` é o núcleo do framework AdvPR para automação de testes no Protheus. Para ter acesso a ela, é necessário aplicar o patch disponível na página de Setup da ferramenta: http://advpr.totvs.com.br:8080/#/setup

Instanciação básica:

```advpl
Local oHelper := FWTestHelper():New()
oHelper:Activate()
```

---

## Ciclo de Vida

### New()

Cria uma nova instância da classe `FWTestHelper`.

```advpl
Local oHelper := FWTestHelper():New()
```

### Activate()

Ativa e valida a classe para uso. Deve ser chamado após configurar CSV, XML, parâmetros e auditoria.

```advpl
Local oHelper := FWTestHelper():New()
oHelper:Activate()
```

### DeActivate()

Desativa a classe ao final do TestCase ou TestSuite.

```advpl
oModel:Deactivate()
oHelper:Deactivate()
```

---

## Assertivas

### AssertTrue( lCondition, cHelp )

Define que o teste espera um retorno verdadeiro para passar.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| lCondition | Lógico | Condição que define se o teste passou ou não | .T. | X |
| cHelp | Caractere | Mensagem customizada exibida no console do robô caso o teste falhe | " " | |

```advpl
oHelper:AssertTrue( oHelper:lOk )
oHelper:AssertTrue( oHelper:lOk, "Falha ao incluir título" )
```

### AssertFalse( lCondition, cErro )

Define que o teste espera um retorno falso para passar.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| lCondition | Lógico | Condição que define se o teste passou ou não | .T. | X |
| cErro | Caractere | Mensagem customizada exibida no console do robô caso o teste falhe | " " | |

```advpl
oHelper:AssertFalse( oHelper:lOk, "" )
```

### AssertHelp( cHelp, cErro )

Define que o teste espera uma resposta de Help para passar. Útil para validar mensagens de ajuda exibidas pela rotina.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cHelp | Caractere | Texto que define parte do help a verificar | "HELP" | X |
| cErro | Caractere | Mensagem customizada exibida no console do robô | " " | |

```advpl
oHelper:AssertHelp( "HELP", "" )
// Uso avançado: validar falha em ExecStatic
oHelper:AssertHelp( "ExecStatic", "Falha nos modelos: " + oHelper:cErrorPrograms )
```

---

## Parâmetros, Filial e Data

### UTSetParam( cParam, xValue, lChange )

Altera parâmetros do sistema (tabela SX6). O array de backup retornado deve ser guardado para restauração posterior com `UTRestParam`.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cParam | Caractere | Nome do parâmetro a ser alterado | | X |
| xValue | Undefined | Novo valor do parâmetro | " " | X |
| lChange | Lógico | Se .T., altera imediatamente; se .F., aguarda `UTLoadData()` | .F. | |

```advpl
oHelper:UTSetParam( "MV_BXCNAB" , 'S', .T. )
oHelper:UTSetParam( "MV_FINJRTP", 2  , .T. )
```

### UTRestParam( aParam )

Restaura os parâmetros para seus valores originais.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| aParam | Array | Array de parâmetros que serão restaurados | X |

```advpl
oHelper:UTRestParam( oHelper:aParamCT )
// Ou com array estático da suite:
oHelper:UTRestParam( ::aParam )
```

### ChangeFil( cFilDest )

Altera a filial logada durante o cenário de teste. Não suportado para testes que consomem Web Service (não é possível alterar a filial corrente no lado do servidor via client).

| Nome | Tipo | Descrição |
|---|---|---|
| cFilDest | Caractere | Filial de destino |

```advpl
oHelper:ChangeFil( "D MG 02 " )
// Ao finalizar, restaurar a filial original:
oHelper:ChangeFil( "D MG 01 " )
```

### UTOpenFilial( cEmpresa, cFil, cMod, aTable, cUser, cPsw )

Abre a filial de acordo com os parâmetros informados. Normalmente chamado em `SetUpSuite`.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cEmpresa | Caractere | Empresa a acessar | | X |
| cFil | Caractere | Filial a acessar | | X |
| cMod | Caractere | Módulo a acessar | FAT | |
| aTable | Array | Tabelas a abrir | | |
| cUser | Caractere | Usuário | ADMIN | |
| cPsw | Caractere | Senha | | |

```advpl
oHelper:UTOpenFilial( "T1", "D MG 01 " )
oHelper:UTOpenFilial( "T1", "D RJ01 ", "CRM",, "VENDFAT05", "1" )
```

### UTCloseFilial()

Fecha a empresa após a execução dos casos de teste. Normalmente chamado em `TearDownSuite`.

```advpl
oHelper:UTCloseFilial()
```

### UTDateCurrent( lDataCorrente )

Define se será utilizada a data do sistema operacional (.T.) ou a data definida no script (.F.). Deve ser chamado antes de `UTOpenFilial`.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| lDataCorrente | Lógico | .T. = utiliza a data corrente do sistema; .F. = utiliza a data que está no script | .T. | X |

```advpl
oHelper:UTDateCurrent(.T.) // Default .T.
```

### UTUpdSpecialKey()

Atualiza a chave `SpecialKey` do `.ini` com o valor de `environment + data + hora + segundo`. Deve ser chamado antes de `UTOpenFilial`.

```advpl
oHelper:UTUpdSpecialKey()
oHelper:UTOpenFilial("T1","D MG 01 ","PCP")
```

### UTAlterSM0( cAltFil, cCampo, xValue )

Altera um campo no SIGAMAT do sistema. Após o uso, restaurar com `UTRestSM0`.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cAltFil | Caractere | Grupo de empresa + filial a ser alterada | X |
| cCampo | Caractere | Nome do campo a ser alterado | X |
| xValue | Undefined | Conteúdo a ser gravado no campo | X |

```advpl
oHelper:UTAlterSM0("T1X TSS02", "M0_ESTCOB", "SP" )
// Após uso, restaurar:
oHelper:UTRestSM0( oHelper:aSM0 )
```

### UTRestSM0( aSM0 )

Restaura os valores originais do SIGAMAT.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| aSM0 | Array | Array de retorno dos campos do SIGAMAT | X |

```advpl
oHelper:UTRestSM0( oHelper:aSM0 )
```

---

## Entrada de Dados e Execução

### UTSetValue( cModel, cField, xValue, cAuxiliar )

Inclui valor em um campo individualmente — tanto em arrays (aCab/aItens) quanto em modelos MVC.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cModel | Caractere | Nome do modelo ou array (ex: "aCab", "aItens", "FW3MASTER") | X |
| cField | Caractere | Nome do campo | X |
| xValue | Undefined | Valor a ser incluído | X |
| cAuxiliar | Caractere | Valor auxiliar | |

```advpl
// Array (cabeçalho e itens):
oHelper:UTSetValue("aCab","E1_PREFIXO","AUT")
oHelper:UTSetValue("aCab","E1_VALOR",1000)
oHelper:UTSetValue("aItens","UB_QUANT", 1)

// MVC:
oHelper:UTSetValue('FW3MASTER', 'FW3_SOLICI', cIdSolic)
oHelper:UTSetValue('FW4DETAIL', 'FW4_ITEM',   '01')
```

### UTAddLine( cModel )

Inclui uma nova linha em um modelo de dados ou array.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cModel | Caractere | Nome do array ou Model onde inserir a nova linha | X |

```advpl
// Em array:
oHelper:UTSetValue( "aItens", 'N3_VORIG1', 1000 )
oHelper:UTAddLine( 'aItens' )
oHelper:UTSetValue( "aItens", "N3_CBASE", "ATF038 ")

// Em modelo MVC:
oHelper:UTAddLine( "CPIDETAIL" )
oHelper:UTSetValue( "CPIDETAIL", "CPI_CODORG", '000002' )
```

### UTCommitData( bExec, xParam1, xParam2…xParam20 )

Executa o commit do teste e captura erros, se houver. Suporta até 20 parâmetros adicionais.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| bExec | Bloco | Bloco de execução do MsExecAuto | Não |
| xParam | Undefined | Parâmetros a serem passados para o bloco | Não |

```advpl
// Rotina automática (MsExecAuto):
oHelper:UTCommitData( { |x,y,z| ATFA010( x, y, z ) }, oHelper:GetaCab(), oHelper:GetaItens(), 3 )

// MVC (sem parâmetros):
oHelper:UTCommitData()
```

### UTGetaCab()

Recupera o array `aCab` declarado via `UTSetValue`.

```advpl
oHelper:UTSetValue( "aCab","N1_CBASE", 'CT001')
oHelper:UTCommitData( { |x,y,z| ATFA010( x, y, z ) }, oHelper:GetaCab(), oHelper:GetaItens(), 3 )
```

### UTGetaItens()

Recupera o array `aItens` declarado via `UTSetValue`.

```advpl
oHelper:UTSetValue( "aItens", 'N3_TIPO', '01')
oHelper:UTCommitData( { |x,y,z| ATFA010( x, y, z ) }, oHelper:GetaCab(), oHelper:GetaItens(), 3 )
```

### GetaCab()
Retorna o array de cabeçalho (`aCab`) preenchido via `UTSetValue("aCab",...)`, para passar como parâmetro ao `UTCommitData` nas execuções ExecAuto.

Exemplo:
```advpl
oHelper:UTCommitData( {|a,b| MATA030(a,b)}, oHelper:GetaCab(), 3 )
```

### GetaItens()
Retorna o array de itens (`aItens`) preenchido via `UTSetValue("aItens",...)`, para passar ao `UTCommitData` em ExecAuto com grid.

Exemplo:
```advpl
oHelper:UTCommitData( {|x,y,z| MATA410(x,y,z)}, oHelper:GetaCab(), oHelper:GetaItens(), 3 )
```

### UTChangePergunte( cGrupo, cOrdem, xValue )

Altera o conteúdo das perguntas do SX1.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cGrupo | Caractere | Grupo da rotina a ser alterada | X |
| cOrdem | Caractere | Sequência da pergunta | X |
| xValue | Undefined | Valor a ser atribuído | X |

```advpl
oHelper:UTChangePergunte( "AFA010", "01", 2 ) // Mostra Lançamento - N
oHelper:UTChangePergunte( "AFA010", "02", 2 ) // Repete Chapa     - S
oHelper:UTChangePergunte( "FIN501", "07", "1" ) // Moeda
```

### UTInputValue( cValue )

Envia dados digitados do teclado para scripts que utilizam comunicação Telnet.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cValue | String | Valor a ser digitado | X |

```advpl
oHelper:UTInputValue("Admin")
oHelper:UTInputValue("1234")
oHelper:UTInputValue("Avenida Braz Leme")
```

### UTSetKey( cCommand1, cCommand2 )

Envia teclas (ações) do teclado para scripts com comunicação Telnet.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cCommand1 | String | Tecla de comando (ex: "ENTER", "{F5}") | X |
| cCommand2 | Lógico | Tecla auxiliar (ex: "CTRL") | X |

Teclas válidas: `{BACKSPACE}`, `{DELETE}`, `{DOWN}`, `{END}`, `{ENTER}` ou `~`, `{ESC}`, `{HOME}`, `{INSERT}`, `{LEFT}`, `{PGDN}`, `{PGUP}`, `{RIGHT}`, `{TAB}`, `{UP}`, `{F1}`–`{F16}`, entre outras.

```advpl
oHelper:UTSetKey("ENTER")
oHelper:UTSetKey("CTRL","X")
```

### UTExecTelNet( cScript )

Executa scripts criados em VBS para comunicação com aplicação Telnet.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cScript | String | Nome do caso de teste criado no script ADVPL | X |

```advpl
oHelper:UTExecTelNet("ACD010_001")
```

### SetModel( oModel, lValid )

Ativa o modelo que será utilizado nas operações em fontes MVC.

| Nome | Tipo | Descrição |
|---|---|---|
| oModel | Objeto | Nome do modelo a ser carregado |
| lValid | Lógico | Se .T., interrompe execução em caso de falha ao instanciar. Default: .F. |

```advpl
oHelper:SetModel( oModel )
```

### SetMsErroAuto( lMsAuto, lErrFile )

Seta variáveis privadas da execução automática.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| lMsAuto | Lógico | Se .T., houve erro no MsExecAuto | .F. | |
| lErrFile | Lógico | Se .T., alimenta a variável `__aErrAuto` | .T. | |

```advpl
oHelper:SetMsErroAuto()
```

### UTGetError()

Procura e retorna o erro capturado pelo MsExecAuto / MVC.

```advpl
Local cErro := oHelper:UTGetError()
```

### UTPutError( cError )

O cabeçalho original do TDN grafa `UtPutError`.

Inclui um erro manualmente no log do teste.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cError | Caractere | Mensagem de erro a ser registrada | X |

```advpl
If !FOpnTabTAf( cTable, cAliasST1 )
    oHelper:UTPutError(" Problemas na estrutura da tabela TAFST1 ou a tabela nao existe" )
    oHelper:AssertTrue( .F., "" )
EndIf
```

### UTSchedule( cRotina, cFilSched )

Realiza o agendamento e a execução da rotina. Parâmetros devem ser configurados via `UTChangePergunte` antes da chamada.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cRotina | String | Nome da rotina a agendar e executar | X |
| cFilSched | String | Filial para o agendamento | Não |

```advpl
oHelper:UTChangePergunte("MTA320","01",2)
oHelper:UTSchedule("MATA320")
```

---

## Consulta e Validação em Base

### UTFindReg( cAlias, nOrdem, cChave )
Posiciona no registro da tabela/alias informado, usando a ordem do índice e a chave de busca. É o método ADVPR para posicionamento (use no lugar de `DbSeek`), usado em operações MVC de Alteração/Exclusão e antes de processar registros existentes.

Exemplo:
```advpl
oHelper:UTFindReg( "SUS", 1, cCod + cLoja )
```

### UTQueryDB( cTable, cField, cFilter, xValue, cFil )

Realiza query de verificação de resultado esperado em banco de dados.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cTable | Caractere | Alias da tabela | | X |
| cField | Caractere | Campo a ser consultado e validado | | X |
| cFilter | Caractere | Condição WHERE | | X |
| xValue | Undefined | Valor esperado no campo | " " | X |
| cFil | Caractere | Filial específica (ignora a filial do Setup) | | |
| lAssert | Lógico | Execução via AssertTrue ou AssertFalse | .F. | |

```advpl
cTable := "FW6"
cQuery := "FW6_ITEM = '01' AND FW6_SOLICI = '" + cSolicit + "'"

oHelper:UTQueryDB( cTable, "FW6_PORCEN", cQuery, 100 )
oHelper:UTQueryDB( cTable, "FW6_CC",     cQuery, 'FIN10101' )
oHelper:AssertTrue( oHelper:lOk, "" )
```

### UTCheckDB( cAlias, cField, xValue )

Verifica se o conteúdo de um campo no banco de dados confere com o valor esperado. Atualiza `oHelper:lOk`.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cAlias | Caractere | Nome da tabela | X |
| cField | Caractere | Nome do campo a verificar | X |
| xValue | Undefined | Conteúdo esperado | X |

```advpl
oHelper:UTCheckDB( "SAH", "AH_UNIMED", cCodigo )
oHelper:AssertTrue( oHelper:lOk, "" )

oHelper:UTCheckDB( "SE1", "E1_VALOR", 1000 )
oHelper:AssertTrue( oHelper:lOk, "" )
```

### UTSelectDB( cTable, aFields, cFilter )

Retorna os registros de uma tabela conforme os parâmetros, via consulta SQL.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cTable | String | Nome da tabela | X |
| aFields | Array | Lista com os nomes dos campos a retornar | X |
| cFilter | String | Filtro para a cláusula WHERE | X |

Retorno: `aRows` — array bidimensional com os registros encontrados.

```advpl
Local aFields  := {"E1_TIPO","E1_DATAIN","E1_VALOR"}
Local cFilter  := "E1_NUM = '000000001' AND E1_FILIAL = 'D MG 01 '"

aTitulos := oHelper:UTSelectDB('SE1T10', aFields, cFilter)
If Len(aTitulos) <> 1
    oHelper:lOk := .F.
EndIf
oHelper:AssertTrue( oHelper:lOK, "" )
```

### UTUpdateDB( cTable, cField, xVal, cFilter )

Altera registros no banco de dados via SQL.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cTable | String | Nome físico da tabela | X |
| cField | String | Campo a ser atualizado | X |
| xVal | Any | Valor a ser inserido no campo | X |
| cFilter | String | Filtro para a cláusula WHERE | |

Retorno: `::lOK` lógico indicando sucesso.

```advpl
oHelper:UTUpdateDB('SE1T10', "E1_NUM",   "000000002", cFilter)
oHelper:UTUpdateDB('SE1T10', "E1_VALOR", 1000.00,     cFilter)
```

### UTRetReg( cTable, cFiltro, aFields )

Retorna registros de uma tabela usando consulta SQL com filtro.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cTable | Caractere | Nome da tabela (ex: `RetSqlName("SA1")`) | | X |
| cFiltro | Caractere | Filtro para seleção de registros | | X |
| aFields | Caractere | Campos a retornar (ex: `{"A1_COD","A1_TPCLI"}`) | | X |

```advpl
aRet := oHelper:UTRetReg( RetSqlName("SA1"), "A1_COD = '0001' AND A1_TPCLI = 'R'", {"A1_COD","A1_TPCLI"} )
```

### UTMarkReg( cTable, cField, cMark )

Realiza marcação física no banco de dados de registros sem uso de telas markBrowse. Deve ser utilizado em conjunto com `UTFindReg` para posicionar o registro antes de marcar.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cTable | Caractere | Nome da tabela | X |
| cField | Caractere | Campo de marcação | X |
| cMark | Caractere | Marca a ser utilizada (vazio para desmarcar) | X |

```advpl
// Marcação:
oHelper:UTFindReg( "SA2", 1, '000002')
oHelper:UTMarkReg( "SA2", "A2_OK", "AT" )

// Desmarcação:
oHelper:UTFindReg( "SA2", 1, '000002')
oHelper:UTMarkReg( "SA2", "A2_OK", "" )
```

### UTContDB( cAlias, nCount )

Conta a quantidade de registros de uma determinada tabela.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cAlias | Caractere | Nome da tabela | X |
| nCount | Numérico | Quantidade esperada | X |

> **Nota de fidelidade:** O exemplo do fonte TDN chama `UTCheckDB` em vez de `UTContDB` (provável erro do fonte); a correção foi aplicada abaixo.

```advpl
nRegister := oHelper:UTContDB( "SA1", 13 )
```

### UTCountRows( cTable, cFilter )

Conta linhas de uma tabela de acordo com um filtro SQL.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cTable | Caractere | Nome da tabela | X |
| cFilter | Caractere | Filtro usado como cláusula WHERE | |

Retorno: `nCount` — quantidade de linhas encontradas.

```advpl
nCount := oHelper:UTCountRows( "SA2", "A2_EST = 'SP'" )
```

### UTClearDB( aAlias )

Limpa os dados de tabelas específicas.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| aAlias | Array | Array de aliases a excluir | X |

```advpl
oHelper:UTClearDB( { "ACG","B44","SEZ","SFQ","SK1","SC5","SC6","SC9","SDA" } )
```

### UTDeleteDB( cTable, cFilter )

Deleta registros de uma tabela, podendo filtrar via WHERE. Os dados são apagados definitivamente — o AdvPR não realiza backup ou restore.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cTable | String | Nome físico da tabela (incluindo grupo de empresa) | " " | X |
| cFilter | String | Filtro para a cláusula WHERE | " " | |

```advpl
oHelper:UTDeleteDB("SA1T10", "A1_LOJA = '01'")
oHelper:UTDeleteDB("SFTT10", "FT_NFISCAL = '000006' AND FT_SERIE = '664'")
```

### UTAppendData( cTable, lExcluir, cFile )

Apenda dados para a tabela da base conforme configurado no appServer.ini.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cTable | Caractere | Nome da tabela | | X |
| lExcluir | Lógico | Se .T., exclui os dados da tabela antes do append | .T. | |
| cFile | Caractere | Nome do arquivo para o append | " " | |

Retorno: `oHelper:lOk` indicando sucesso.

```advpl
oHelper:UTAppendData("TAFST2",,"AdvPR_007")
// Append sem deletar registros:
oHelper:UTAppendData("SA1", .F., "AdvPR_008")
```

### UTAlterAutoCont( cTable, nOrder, cSeek, aData )

Altera um campo em uma tabela autocontida por TestCase. Deve ser seguido de `UTRestAutoCont` ao final do teste.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cTable | Caractere | Nome da tabela autocontida | X |
| nOrder | Numérico | Índice de busca | X |
| cSeek | Caractere | Chave de pesquisa | X |
| aData | Array | Valor de preenchimento `{ campo, valor }` | X |

```advpl
If oHelper:UTAlterAutoCont( 'CC2', 1, "GO" + "14804", { { "CC2_PERMAT", 25 } } )
    lUpdtAuto := .F.
EndIf
oHelper:UTRestAutoCont()
```

### UTRestAutoCont()

Restaura as alterações efetuadas na tabela autocontida pelo método `UTAlterAutoCont`.

```advpl
oHelper:UTRestAutoCont()
```

### UTSetStamp( aTables, lGroup )

Adiciona o campo `S_T_A_M_P_` nas tabelas do Protheus.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| aTables | Array | Lista com as tabelas a atualizar | | X |
| lGroup | Lógico | Se .T., realiza `RetSqlName` na tabela (o fonte TDN grafa `IGroup`) | .T. | Opcional |

Retorno: `::lOK` indicando sucesso.

```advpl
oHelper:UTSetStamp({"SE1"})
```

### UTAtuSX3( cTableName, aSX3Estr, aSX3Data )

Altera estrutura de campos do SX3 em tempo de execução. Requer DBAccess 20220303 (Build 22.1.1.0) ou superior.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cTableName | String | Nome da tabela a atualizar | X |
| aSX3Estr | Array | Estrutura dos campos (ex: `{"X3_CAMPO","X3_TAMANHO","X3_DECIMAL","X3_PICTURE"}`) | X |
| aSX3Data | Array | Dados a atualizar (ex: `{"C6_PRCVEN", 15, 4, '@E 9,999,999.9999'}`) | X |

```advpl
Local aSX3Estr := {"X3_CAMPO", "X3_TAMANHO","X3_DECIMAL","X3_PICTURE"}
Local aSX3Data := {}
Aadd(aSX3Data, {"C6_PRCVEN", 15, 4, '@E 9,999,999,999.9999'})
oHelper:UTAtuSX3("SC6", aSX3Estr, aSX3Data)
// Ao final, restaurar:
oHelper:UTRestSX3()
```

### UTRestSX3()

Restaura a estrutura de uma tabela alterada pelo método `UTAtuSX3`.

```advpl
oHelper:UTRestSX3()
```

### UTUpdComp( aSX2Data )

Altera o compartilhamento das tabelas no SX2. Retorna array com valores originais para restauração.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| aSX2Data | Array | Informações da tabela e compartilhamento a alterar | X |

```advpl
Local aNewComp := {}
aAdd(aNewComp, {"SB1", "E", "E", "E"})
::aSX2DataRest := oHelper:UTUpdComp(aNewComp)
```

### UTRestComp( aSX2DataRest )

Restaura o compartilhamento das tabelas no SX2 após a execução dos testes.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| aSX2DataRest | Array | Array com informações para restaurar | X |

```advpl
oHelper:UTRestComp(::aSX2DataRest)
```

---

## Auditoria

### UTAuditField( cTable, cField )

Audita um campo específico de uma tabela via Audit Trail. Deve ser chamado imediatamente após `Activate`. Para múltiplos campos, repita o método.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cTable | Caractere | Nome da tabela | X |
| cField | Caractere | Nome do campo a auditar | X |

```advpl
oHelper:Activate()
oHelper:UTAuditField("SE1","E1_NUM")
oHelper:UTAuditField("SE1","E1_TIPO")
// ... operações ...
oHelper:UTCheckAudit("FINA040_001")
oHelper:AssertTrue(oHelper:lOk,"")
```

### UTAuditNoField( cTable, cField )

Audita uma tabela inteira, exceto o campo informado. Para excluir múltiplos campos, repita o método.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cTable | Caractere | Nome da tabela a auditar | X |
| cField | Caractere | Campo a ser desconsiderado na auditoria | X |

```advpl
oHelper:Activate()
oHelper:UTAuditNoField("SE1","E1_NUM")
oHelper:UTAuditNoField("SE1","E1_TIPO")
```

### UTAuditTable( cTable )

Audita uma tabela inteira. Para múltiplas tabelas, repita o método.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cTable | Caractere | Nome da tabela a auditar | X |

```advpl
oHelper:Activate()
oHelper:UTAuditTable("SE1")
oHelper:UTAuditTable("SE2")
```

### UTCheckAudit( cRptName, lUseTxt, lConvAcent, cOrder )

Extrai dados das tabelas de auditoria e compara com arquivo base. Deve ser chamado após o commit. Recomenda-se o modo TXT por ser mais rápido.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cRptName | Caractere | Nome do relatório | | X |
| lUseTxt | Lógico | .T. = comparação via TXT; .F. = via relatório Audit Trail | .T. | |
| lConvAcent | Lógico | Se deve converter acentos | .T. | |
| cOrder | Caractere | Chave de ordenação dos registros | TTAT_DTIME,TTAT_RECNO,TTAT_OPERATI,TTAT_FIELD | |

```advpl
oHelper:UTAuditTable("SE1")
// ... operações e commit ...
oHelper:UTCheckAudit("FINA040_001")
oHelper:AssertTrue(oHelper:lOk,"")
```

---

## Webservice, REST e EAI

### UTSetAPI( cApi, cTypeAPI )

Define qual modelo de API será consumido (REST ou SOAP).

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cApi | String | Caminho da API na URL | | Sim |
| cTypeAPI | String | Modelo da API: "REST" ou "SOAP" | REST | Não |

Retorno: `lOk` indicando se o tipo foi configurado corretamente.

```advpl
oHelper:UTSetAPI("/api/v1/","REST")
lOk := oHelper:UTSetAPI("/api/v1","REST")
```

### UTSetAuthorization( cUser, cPwd )

Gera a string de autenticação Basic (Base64) para uso no header de WebService.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cUser | String | Login do usuário | Sim |
| cPwd | String | Senha do usuário | Sim |

Retorno: string com o encode Base64 de `usuário:senha`.

```advpl
Local aHeader := {"Content-Type: application/json", "Authorization: Basic " + oHelper:UTSetAuthorization("CRMREST01", "1")}
```

### UTGetWS( aHeader, cFile, cGetParms, cURLRest, aReplace, aReplaceX, lLastResult, lRetry, aIgnoreProperty, lIgnoreNewProperty )

Consome API via GET (REST/JSON ou SOAP/XML) e compara o response com arquivo baseline.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| aHeader | Array | Strings a adicionar ao header | Rest: `{Content-Type: application/json}` | Não |
| cFile | String | Nome do arquivo baseline para comparação | " " | Não |
| cGetParms | String | Parâmetros de query string | " " | Não |
| cURLRest | String | URL da API (se vazio, usa chave REST do appserver.ini) | http://localhost:8787/ | Não |
| aReplace | Array | Array de replace no response | {} | Não |
| aReplaceX | Array | Substitui valor entre duas strings (para XML) | {} | Não |
| lLastResult | Lógico | .T. = usa GetResult (erros completos); .F. = usa GetLastError | .F. | Não |
| lRetry | Lógico | .T. = realiza segundo request em caso de falha | .T. | Não |
| aIgnoreProperty | Array | Propriedades JSON dinâmicas a ignorar na validação | | Não |
| lIgnoreNewProperty | Lógico | .T. = ignora novas propriedades do JSON auto gerado | .F. | Não |

Retorno: `cRet` (response da API) e `oHelper:cHeaderGet` (header SOAP retornado).

```advpl
oHelper:UTSetAPI("/api/v1/","REST")
Aadd(aIgnoreProperty,{"properties","name",{"MES01"},{"description"}})
cRet := oHelper:UTGetWS(aHeader,"UTGETWS0001_REST",,,,,,,aIgnoreProperty)
oHelper:AssertTrue( oHelper:lOk, "" )
```

### UTPostWS( cBody, aHeader, cFile, cGetParms, cURLRest, aReplace, aReplaceX, lLastResult, lRetry )

Consome API via POST (REST/JSON ou SOAP/XML).

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cBody | String | Body da requisição (JSON ou XML) | " " | Não |
| aHeader | Array | Strings do header | Rest: `{Content-Type: application/json}` | Não |
| cFile | String | Nome do arquivo baseline | " " | Não |
| cGetParms | String | Parâmetros de query string | " " | Não |
| cURLRest | String | URL da API | http://localhost:8787/ | Não |
| aReplace | Array | Array de replace no response | {} | Não |
| aReplaceX | Array | Substitui valor entre duas strings | {} | Não |
| lLastResult | Lógico | .T. = GetResult; .F. = GetLastError | .F. | Não |
| lRetry | Lógico | .T. = segundo request em caso de falha | .T. | Não |

```advpl
Local cBody := '{"body_request":"advPr", "test_modelo": "interface"}'
oHelper:UTSetAPI("/api/v1","REST")
cRet := oHelper:UTPostWS(cBody, aHeader, "UTPostWs_004")
oHelper:AssertTrue( oHelper:lOk, "" )
```

### UTPutWS( cBody, aHeader, cFile, cURLRest, aReplace, aReplaceX, lRetry )

Consome API via PUT (REST/JSON ou SOAP/XML).

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cBody | String | Body da requisição | " " | Não |
| aHeader | Array | Strings do header | Rest: `{Content-Type: application/json}` | Não |
| cFile | String | Nome do arquivo baseline | " " | Não |
| cURLRest | String | URL da API | http://localhost:8787/ | Não |
| aReplace | Array | Array de replace | {} | Não |
| aReplaceX | Array | Substitui valor entre duas strings | {} | Não |
| lRetry | Lógico | .T. = segundo request em caso de falha | .T. | Não |

```advpl
oHelper:UTSetAPI("/CRMMOPPORTUNITYCONTACT/","REST")
cRet := oHelper:UTPutWS(cBody, aHeader, "testcrmput")
oHelper:AssertTrue( oHelper:lOk, "" )
```

### UTDeleteWS( cBody, aHeader, cFile, cURLRest, aReplace, aReplaceX, lRetry )

Consome API via DELETE (REST/JSON ou SOAP/XML).

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cBody | String | Body da requisição | " " | Não |
| aHeader | Array | Strings do header | Rest: `{Content-Type: application/json}` | Não |
| cFile | String | Nome do arquivo baseline | " " | Não |
| cURLRest | String | URL da API | http://localhost:8787/ | Não |
| aReplace | Array | Array de replace | {} | Não |
| aReplaceX | Array | Substitui valor entre duas strings | {} | Não |
| lRetry | Lógico | .T. = segundo request em caso de falha | .T. | Não |

```advpl
Local aHeader := {"Content-Type: application/json", "Authorization: Basic " + oHelper:UTSetAuthorization("Admin", "1")}
oHelper:UTSetAPI("/CRMMOPPORTUNITYCONTACT/00024401/TMK035/","REST")
cRet := oHelper:UTDeleteWS(cBody, aHeader, "testcrmdelete")
oHelper:AssertTrue( oHelper:lOk, "" )
```

### UTClientWSDL( cWSDL, cOperation, cXml, cFile, aReplace, cService )

Envia mensagem SOAP para um Web Service via WSDL.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cWsdl | String | URL do WSDL (se vazio, usa chave SOAP do appserver.ini) | http://localhost:8787/ | Não |
| cOperation | String | Nome da operação/serviço | " " | Não |
| cXml | String | XML a enviar (se vazio, usar `UTSetSoapValue`) | " " | Não |
| cFile | String | Nome do arquivo baseline para comparação | " " | Não |
| aReplace | String | Array com strings para replace no response | {} | Não |
| cService | String | Nome do serviço `.apw` a consumir | " " | Não |

Retorno: `cRet` — response ou erro do servidor.

```advpl
// Usando UTSetSoapValue para preencher o XML:
oHelper:UTSetSoapValue("USERCODE","MSALPHA")
oHelper:UTSetSoapValue("GUIAS","000001")
cRet := oHelper:UTClientWSDL(, cOperation,,,, "/ws/PLSXMOV.apw?WSDL")

// Enviando XML diretamente e comparando com baseline:
cRet := oHelper:UTClientWSDL(, cOperation, cXml, "advpr001CT",, "/ws/PLSXMOV.apw?WSDL")
```

### UTSetSoapValue( cField, xValue )

Define valores no XML para estruturas simples (SOAP).

| Nome | Tipo | Descrição | Default |
|---|---|---|---|
| cField | String | Nome da propriedade do XML | " " |
| xValue | Undefined | Valor a ser enviado | " " |

Retorno: `lRet` indicando sucesso.

```advpl
oHelper:UTSetSoapValue("USERCODE","MSALPHA")
oHelper:UTSetSoapValue("GUIAS","000001")
```

### UTEAIActivate( cProgram, cFormat, cVersion, cFilExec )

Ativa a configuração de envio do EAI para um adapter.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cProgram | Caractere | Nome do adapter configurado | | X |
| cFormat | Caractere | Formato do arquivo | XML | |
| cVersion | Caractere | Versão do Adapter | | |
| cFilExec | Caractere | Filial de execução (XX4_FILEXE) | | |

Retorno: .T./.F. indicando se foi possível ativar o adapter.

```advpl
oHelper:UTEAIActivate( 'FINA010' )
```

### UTEAIReceive( cProgram, cFormat, cFilExec )

Habilita o recebimento do EAI para um adapter.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cProgram | Caractere | Nome do adapter | | X |
| cFormat | Caractere | Formato do arquivo | XML | |
| cFilExec | Caractere | Filial de execução (XX4_FILEXE) | | |

```advpl
oHelper:UTEAIReceive( 'FINA010' )
```

### UTExecEAI( cCodigo, cTestCase, cFormat, aReplaceX )

Executa a mensagem única de RECEBIMENTO do EAI.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cCodigo | Caractere | Código para busca (XX3_UUID) | X |
| cTestCase | Caractere | Nome do caso de teste (para gerar arquivo baseline) | |
| cFormat | Caractere | Formato do arquivo validado | |
| aReplaceX | Array | Substitui valor entre duas strings | |

```advpl
oHelper:UTExecEAI( "9000000000000000000037785" )
```

### UTVldEAI( cProgram, cTestCase, cFormat, aReplaceX, cFilExec, nPosition )

Compara o arquivo XML gerado na mensagem única de ENVIO do EAI.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cProgram | Caractere | Nome do adapter | | X |
| cTestCase | Caractere | Nome do caso de teste | | X |
| cFormat | Caractere | Formato do arquivo | XML | |
| aReplaceX | Array | Substitui valor entre duas strings | | |
| cFilExec | Caractere | Filial de execução do Adapter | | |
| nPosition | Numérico | Número do registro (0 = último incluído) | 0 | |

```advpl
oHelper:UTEAIActivate( 'FINA010' )
oHelper:UTCommitData( { |x,y| FINA010( x, y) }, oHelper:GetaCab(), 3 )
oHelper:UTVldEAI( 'FINA010', 'FIN010_001' )
oHelper:AssertTrue(oHelper:lOk,"")
```

### UTRestartRest()

Reinicia o serviço de REST durante a execução do teste.

```advpl
oHelper:UTRestartRest()
```

### UTGetTenantID( cInteg )

Configura credenciais do TOTVS RAC e retorna o Tenant ID da fila do SmartLink.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cInteg | String | Nome da integração do SmartLink (ex: "GESPLAN") | X |

Retorno: `cTenantId` — Tenant ID da fila.

```advpl
oHelper:UTGetTenantID("GESPLAN")
```

### UTSetConfigSendSmtLink( cInteg )

Seta a configuração do TenantId e credenciais de envio para a fila do SmartLink. Disponível com LIB >= 20230626.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cInteg | String | Nome da integração | X |

```advpl
oHelper:UTSetConfigSendSmtLink("CONTA DIGITAL")
```

### UTReadSmtLink( cInteg )

Inicia o Job de leitura das mensagens da fila do SmartLink. Disponível com LIB >= 20230626.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cInteg | String | Nome da integração | X |

```advpl
oHelper:UTReadSmtLink("CONTA DIGITAL")
```

### UTExecSmtLink( cTypeMessage, cMessage, cAudience )

Verifica status da fila do SmartLink, remove mensagens travadas e envia a mensagem do caso de teste. Disponível com LIB >= 20230626.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cTypeMessage | String | Tipo da mensagem | | X |
| cMessage | String | Corpo da mensagem | | X |
| cAudience | String | Audiência da mensagem | | |

```advpl
oHelper:UTExecSmtLink( cTypeMessage, cMessage, cAudience )
```

### UTVldSmtLink( cTestCase, aTagIgnore, aReplaceX )

Compara o retorno das mensagens do SmartLink processadas pelo Protheus. Disponível com LIB >= 20230626.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cTestCase | String | Nome do TestCase para geração do arquivo de comparação | | X |
| aTagIgnore | Array | Tags a ignorar (ex: `{{"time"," "},{"tenantID"," "}}`) | `{{"time"," "},{"tenantID"," "}}` | |
| aReplaceX | Array | Substitui conteúdo entre duas strings | | |

```advpl
oHelper:UTVldSmtLink("C102XG_003")
```

### UTGetRACToken( cInteg, cClientID, cClientSecr )

Gera token do TOTVS RAC informando integração ou credenciais.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cInteg | String | Nome da integração (ex: "TRANSMITE") | X |
| cClientID | String | ClientID alternativo | |
| cClientSecr | String | ClientSecret alternativo | |

Retorno: `cToken` — token do TOTVS RAC.

```advpl
oHelper:UTGetRACToken("TRANSMITE")
```

### UTSetLoginPP( cUser, cPassword, cTipoPortal )

Realiza login no Portal Protheus e retorna o SessionID.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cUser | String | Nome do usuário do portal | X |
| cPassword | String | Senha do usuário | X |
| cTipoPortal | String | Tipo do portal a acessar | X |

Retorno: `cSessionID`.

```advpl
cSessionID := oHelper:UTSetLoginPP(cUser, cPassword, cTipoPortal)
```

### UTSetRouteMock( cRoute, cSubRoute, lRegistry )

Seta a rota do server mock para testes de APIs e integrações.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cRoute | String | Nome da rota do módulo/produto no server mock | | X |
| cSubRoute | String | Sub-rota (para mockar serviço existente com retorno diferente) | | |
| lRegistry | Lógico | Se .T., configura chaves do Registry do appserver.ini com endereço do mock | .F. | |

Retorno: `lRet` indicando sucesso.

```advpl
oHelper:UTSetRouteMock("techfin",,.T.)
cMockServer := oHelper:UTGetRouteMock()
oHelper:UTSetParam( "MV_RSKPLAT", cMockServer, .T. )
oHelper:UTCommitData({|x| RskPostConcession(x)}, EndPoint)
oHelper:UTRestRegistry()
```

### UTGetRouteMock()

Captura a URL do server mock com a rota configurada em `UTSetRouteMock`.

Retorno: `cURLServerMock` — URL do Server Mock.

```advpl
cMockServer := oHelper:UTGetRouteMock()
```

### UTRestRegistry()

Restaura no `.ini` do usuário o conteúdo original das chaves do Registry que foram atualizadas em `UTSetRouteMock`.

Retorno: `lRet` indicando sucesso.

```advpl
oHelper:UTRestRegistry()
```

---

## NF-e e TSS

### GeraChvNfe( cUFEmi, cAAMMEmi, cCnpjEmi, cModeloNf, cSerieNf, cNumNf )

Gera a chave do documento fiscal (NF-e).

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cUFEmi | Caractere | Código da UF emitente | X |
| cAAMMEmi | Caractere | Ano e mês de emissão no formato AAMM | X |
| cCnpjEmi | Caractere | CNPJ do emitente | X |
| cModeloNf | Caractere | Modelo do documento fiscal | X |
| cSerieNf | Caractere | Série do documento fiscal | X |
| cNumNf | Caractere | Número do documento fiscal | X |

```advpl
oHelper:GeraChvNfe('33','1809','00000000001082','57','001','000000001')
```

### UTXMLReplace( cXml, cPath, cReplace, lEncode64 )

Substitui o valor de um atributo do XML. Retorna o XML modificado.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cXml | Caractere | String com o XML | X |
| cPath | Caractere | Caminho do atributo a substituir | X |
| cReplace | Caractere | Conteúdo que será substituído | X |
| lEncode64 | Lógico | Se o conteúdo deve ser gravado em Base64 | X |

```advpl
cNewXml := UTXMLReplace(cNewXml, "/infNFe/ide/serie", "1", .F.)
```

### UTXMLGETVALUE( cXml, cPath, lEncode64 )

Obtém o valor de uma tag do XML.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cXml | Caractere | String com o XML | X |
| cPath | Caractere | Caminho do atributo a buscar | X |
| lEncode64 | Lógico | Se o conteúdo está em Base64 | X |

```advpl
cPath   := "SOAPENV:ENVELOPE/SOAPENV:BODY/NFS:SCHEMA/NFS:NFE/NFS:NOTAS/NFS:NFES/NFS:XML"
cNewXml := UTXMLGETVALUE(cXml, cPath, .T.)
```

### UTTSSNFE( cXml, cPath, aReplace )

Função específica para notas fiscais do TSS. Substitui valores dinâmicos do XML do NF-e dentro do cliente.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cXml | Caractere | String com o XML | X |
| cPath | Caractere | Caminho do atributo a buscar | X |
| aReplace | Caractere | Atributos a substituir dentro do cPath | X |

```advpl
aAdd(aReplace, {"/infNFe/ide/serie","1", .F.})
cPath := "SOAPENV:ENVELOPE/SOAPENV:BODY/NFS:SCHEMA/NFS:NFE/NFS:NOTAS/NFS:NFES/NFS:XML"
UTTSSNFE(cXml, cPath, aReplace)
```

### UTExecPredecessor( cNomeCT, cNumeroCT, aPar )

Executa os predecessores do caso de teste.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cNomeCT | Caractere | Nome do caso de teste (ex: "TAFS1000TestCase") | X |
| cNumeroCT | Caractere | Nome do método (ex: "S1000_001") | X |
| aPar | Caractere | Parâmetros do caso de teste | X |

```advpl
oHelper:UTExecPredecessor("TSSNFESBRANORSPTestCase","NFE_001",{cEntidade,cSerie,cNota})
```

---

## Smart View

### UTParamSmartView( cParam, xValue )

Informa os parâmetros de relatório do Smart View, conforme os nomes definidos na fonte de dados do design.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cParam | Caractere | Nome do parâmetro do relatório | X |
| xValue | Undefined | Conteúdo do parâmetro | X |

> Para parâmetros do tipo data, utilize `totvs.framework.treports.date.stringToTimeStamp` para evitar falhas intermitentes por fuso horário.

```advpl
oHelper:UTParamSmartView("processo","00012")
oHelper:UTParamSmartView("periodo", totvs.framework.treports.date.stringToTimeStamp("20220121"))
oHelper:UTParamSmartView("filialDe","M PR 02")
```

### UTGenerateSmartView( cReport, cFileName, cType )

Gera relatórios utilizando Smart View a partir do Objeto de Negócios e arquivo `.trp` compilado no repositório.

> **Nota:** O exemplo do TDN chama `oHelper:UTSmartView(...)` (possível alias/nome legado); o nome canônico documentado é `UTGenerateSmartView`.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cReport | Caractere | Nome do relatório (mesmo nome do arquivo `.trp`, sem extensão) | | X |
| cFileName | Caractere | Nome do arquivo de saída + número do caso de teste | | X |
| cType | Caractere | Tipo de dado: "report", "data-grid" ou "pivot-table" | report | |

```advpl
oHelper:UTSmartView("RELATORIO_FOLHA_FECHADA","RELATORIO_FOLHA_FECHADA_001")
```

### UTCompareSmartView( cFileName, aReplace, aReplaceX, lUpdateFile )

Compara o relatório gerado no Smart View com o arquivo baseline.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cFileName | Caractere | Nome do arquivo + número do caso de teste | | X |
| aReplace | Array | Substitui uma string por outra | {} | |
| aReplaceX | Array | Substitui conteúdo entre duas strings | {} | |
| lUpdateFile | Lógico | Se .T., altera o arquivo auto gerado após os replaces | .F. | |

```advpl
aadd(aReplace,{"01/01/2016 até 31/01/2016","01/01/2023 até 31/01/2023"})
oHelper:UTCompareSmartView("RELATORIO_FOLHA_FECHADA_001", aReplace, aReplaceX, .T.)
```

### UTSchemaSmartView( cNameSpace, cBusinessObject, cFile, aReplace, aIgnoreProperty, lIgnoreNewProperty )

Gera e valida o Schema do objeto de negócios do SmartView.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cNameSpace | Caractere | Namespace do fonte do objeto de negócios | | X |
| cBusinessObject | Caractere | Nome da classe do objeto de negócios | | X |
| cFile | Caractere | Nome do arquivo do caso de teste | | X |
| aReplace | Array | Tags JSON a alterar na validação | {} | |
| aIgnoreProperty | Array | Propriedades dinâmicas a ignorar | | |
| lIgnoreNewProperty | Lógico | .T. = ignora novas propriedades; .F. = valida todas | .F. | |

```advpl
oHelper:UTSchemaSmartView(cNameSpace, cBusinessObject, "OBJEST_001",, aIgnoreProperty, .T.)
oHelper:AssertTrue(oHelper:lOk)
```

### UTGetDataSmartView( cNameSpace, cBusinessObject, cFile, aReplace, jFilter )

Gera e valida o Data do objeto de negócios do SmartView. Os parâmetros devem ser informados via `UTParamSmartView`.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cNameSpace | Caractere | Namespace do objeto de negócios | | X |
| cBusinessObject | Caractere | Nome da classe | | X |
| cFile | Caractere | Nome do arquivo do caso de teste | | X |
| aReplace | Array | Tags JSON a alterar | {} | |
| jFilter | Json | Filtro no formato JSON do Smart View | | |

```advpl
oHelper:UTParamSmartView("MV_PAR01", {""})
oHelper:UTGetDataSmartView(cNameSpace, cBusinessObject, "OBJEST_002")
oHelper:AssertTrue(oHelper:lOk)
```

### UTCustomSmartView( cNameSpace, cBusinessObject, cTable, cField, cName, cDescri, cType )

Adiciona campos personalizáveis do Smart View (tabela `FW_SV_CUSTOM`).

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cNameSpace | Caractere | Namespace do objeto de negócios | X |
| cBusinessObject | Caractere | Nome da classe | X |
| cTable | Caractere | Nome da tabela | X |
| cField | Caractere | Nome do campo | X |
| cName | Caractere | Nome do campo personalizado | X |
| cDescri | Caractere | Descrição do campo | X |
| cType | Caractere | Tipo do campo | X |

```advpl
oHelper:UTCustomSmartView(cNameSpace, cBusinessObject, "SN3", "N3_CLVLDES", "Clvl Cor.Dep", "Classe de Vlr Cor. Depr.", "string")
```

### UTRemoveCustomSmartView( cNameSpace, cBusinessObject, cTable, cField, cName, cDescri, cType )

Remove campos personalizáveis do Smart View (tabela `FW_SV_CUSTOM`). Mesma assinatura de `UTCustomSmartView`.

```advpl
oHelper:UTRemoveCustomSmartView(cNameSpace, cBusinessObject, "SN3", "N3_CLVLDES", "Clvl Cor.Dep", "Classe de Vlr Cor. Depr.", "string")
```

### UTSetSVConfig()

Configura a URL do Smart View para execução dos testes. Para ambiente local, incluir a chave `URL_SMARTVIEW` na seção `[ADVPR]` do appserver.ini.

Retorno: `oHelper:lOk` indicando sucesso.

```advpl
oHelper:UTSetSVConfig()
oHelper:UTCommitData({|| ESTSV023()})
```

---

## Utilitários

### GetReleaseRobo()

Verifica o conteúdo do arquivo `advpr.ini` para identificar o release do ambiente Protheus. Útil para condicionar execução de casos de teste por versão.

```advpl
If oHelper:GetReleaseRobo() >= "12.1.19"
    ::AddTestMethod("MAT030_001",,"Caso de teste 001")
EndIf
```

### SetCsv( cLayout, cTxtFiel, xAlias )

Informa um arquivo CSV a ser importado (usar antes de `Activate`).

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cLayout | Caractere | Nome do layout no MILE | X |
| cTxtFiel | Caractere | Nome do arquivo CSV | X |
| xAlias | Undefined | Nome da tabela principal ou array de tabelas a limpar durante a carga | X |

```advpl
oHelper:SetCSV( "CTBA010", "ctba010.csv", "CTG" )
oHelper:SetCSV( "CTBA020", "ctba020.csv", "CT1" )
oHelper:Activate()
```

### SetXml( cXml )

Informa um layout de importação XML (usar antes de `Activate`).

| Nome | Tipo | Descrição |
|---|---|---|
| cXML | Caractere | Nome do arquivo XML |

```advpl
oHelper:SetXml( "ctba010.xml" )
oHelper:SetXml( "ctba020.xml" )
oHelper:Activate()
```

### UTLoadData( lClearDB, aParam )

Importa layouts XML e executa layouts CSV configurados via `SetCsv`/`SetXml`.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| lClearDB | Lógico | Se .T., limpa as tabelas antes da importação | Não |
| aParam | Array | Array de backup de parâmetros para restauração | Não |

```advpl
oHelper:UTLoadData( .T., ::aParam )
```

### GetParAuto( cProgram, lCabItem, aHeader )

Para programas não preparados para receber informações automáticas. Retorna array a ser informado no TestCase.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cProgram | Caractere | Nome do TestCase que retornará o array | | X |
| lCabItem | Lógico | Preenche variáveis simulando Enchoice() e GetDados() | .F. | |
| aHeader | Array | Array do aHeader da rotina (quando lCabItem = .T.) | | |

```advpl
// Na rotina padrão:
If FindFunction( "GetParAuto" )
    aRetAuto := GetParAuto( "FINA667TestCase" )
EndIf
```

### ExecStatic( cStaticFun, aPrgNames )

Executa uma função static do fonte em múltiplos programas.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cStaticFun | Caractere | Nome da função static a executar | | X |
| aPrgNames | Array | Array unidimensional com os nomes dos programas | | X |

```advpl
Local aProgramas := {"TEC880EXE","TECA001","teca010","TECA011","TECA011A","TECA012"}
Local lOk := oHelper:ExecStatic("ModelDef", aProgramas)
If !lOk
    oHelper:AssertHelp("ExecStatic","Falha nos modelos: " + oHelper:cErrorPrograms)
EndIf
oHelper:AssertTrue(lOk,"")
```

### UTArqCompare( cPath, cFileModel, cFileTest, cIdLinha, aReplace, lConvAcent, aReplaceX )

Compara arquivo inteiro ou parcial.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cPath | Caractere | Caminho dos arquivos | StartPath do Protheus | |
| cFileModel | Caractere | Nome do arquivo modelo | Arquivo_001_Model.txt | X |
| cFileTest | Caractere | Nome do arquivo gerado pelo caso de teste | Arquivo_001 | |
| cIdLinha | Caractere | Linha em que ocorrerá o replace | " " | |
| aReplace | Array | Array De/Para de strings | {} | |
| lConvAcent | Lógico | Se deve converter acentos | .T. | |
| aReplaceX | Array | Substitui valor entre duas strings | {} | |

```advpl
Aadd( aReplace, { "01112016", "03102016" } )
oHelper:UTArqCompare( "", cArqTest, cArqModel, "|E350", aReplace )
```

### UTPrtCompare( cReport, lConvAcent, lConvAuto, aReplace, aReplacex )

Compara relatórios gerados com arquivo baseline.

| Nome | Tipo | Descrição | Exemplo |
|---|---|---|---|
| cReport | Caractere | Nome da função + número do caso de teste | "FINR130_001" |
| lConvAcent | Lógico | Converte caracteres para Hexadecimal | |
| lConvAuto | Lógico | Converte o arquivo gerado automaticamente para Hex | |
| aReplace | Array | Conteúdo a substituir no arquivo base | |
| aReplacex | Array | Substitui valor entre duas strings | |

```advpl
oHelper:UTPrtCompare( "FINR130_001" )
```

### UTStartRpt( cReport, aListParam, cDef, cPerg, nOrder, wnrel, lEndReport, lEmptyLine )

Permite a geração de arquivos de relatório.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cReport | Caractere | Nome da função + número do caso de teste | | X |
| aListParam | Array | Perguntas do SX1 (desnecessário se usar UTChangePergunte) | {} | |
| cDef | Caractere | Nome da função quando não houver ReportDef | | |
| cPerg | Caractere | Nome do pergunte no SX1 | " " | |
| nOrder | Numérico | Ordem de impressão | | |
| wnrel | Caractere | Nome do relatório (se diferente do fonte) | " " | |
| lEndReport | Lógico | Se .T., imprime com "Total Geral" | .F. | |
| lEmptyLine | Lógico | Se .T., considera linhas em branco no Excel | .F. | |

```advpl
oHelper:UTChangePergunte( "FIN501", "01", "000007" )
oHelper:UTStartRpt( "FINR501_001" )
```

### UTStartTimer( cOperation )

Marca o início da medição de tempo de uma operação.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cOperation | Caractere | Identificação do timer | "Default" | Não |

```advpl
oHelper:UTStartTimer( 'TESTE 001' )
```

### UTStopTimer( cOperation )

Marca o final da medição de tempo de uma operação.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cOperation | Caractere | Identificação do timer | "Default" | Não |

```advpl
oHelper:UTStopTimer( 'TESTE 001' )
```

### UTAtzPsw()

Atualiza o `SIGAPSS.spf` de acordo com o backup da base congelada.

```advpl
oHelper:UTAtzPsw()
```

### UTDelPsw()

Apaga o arquivo `SIGAPSS.SPF`.

```advpl
oHelper:UTDelPsw()
```

### UTSerieID( cTabela, cCampo, cEspecie, cSerie )

Verifica novo formato de gravação do ID no campo `_SERIE`.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cTable | Caractere | Tabela a validar | " " | X |
| cCampo | Caractere | Campo a validar | " " | X |
| cEspecie | Caractere | Espécie da nota | " " | |
| cSerie | Caractere | Série da nota | " " | |

```advpl
cSerieId := oHelper:UTSerieID( 'SF1', 'F1_SERIE', cEspecie, cSerie )
```

### ConvAcento( cString )

Converte caracteres com acento.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cString | Caractere | String a converter | X |

```advpl
cRet := ConvAcento( cString )
```

### Conv2Hex( cChar )

Converte caractere para Hexadecimal.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cChar | Caractere | String a converter | X |

```advpl
cRet := Conv2Hex( cChar )
```

### TabForTxt( cPath, nExtensao, nTipo, aTables )

Converte dados de tabelas para arquivo de texto.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cPath | Caractere | Caminho onde o arquivo será salvo | | X |
| nExtensao | Numérico | Extensão: 1=TXT; 2=CSV | 1 | |
| nTipo | Numérico | Tipo: 1=Modelo; 2=Teste | 1 | |
| aTables | Array | Tabelas a gerar | | X |

```advpl
TabForTxt( cPath, 2, 2, { "SA1" } )
```

### Txt2Array( cArqTxt, cCond, aReplace )

Transforma um arquivo texto em array.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cArqTxt | Caractere | Nome do arquivo TXT | X |
| cCond | Caractere | Condição de aglutinação | X |
| aReplace | Array | Retorno do arquivo transformado em array | |

```advpl
aArqModel := Txt2Array( cArqModel, "|T001" )
```

### UTLoadBody( cJson, lTrimLine )

Realiza a leitura de um arquivo localizado na pasta `baseline` do ambiente.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cJson | String | Nome com extensão do arquivo a ler | | X |
| lTrimLine | Lógico | Se .T., aplica Alltrim nas linhas | .T. | |

```advpl
Local cJson := oHelper:UTLoadBody("ADVPR001.txt")
oHelper:UTCommitData({|x| JsonSend(x)}, cJson)
```

### UTCreateFile( cContent, cFileName, cPath )

Cria um arquivo em pasta especificada.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cContent | String | Conteúdo do arquivo | | X |
| cFileName | String | Nome + extensão do arquivo | | X |
| cPath | String | Local onde o arquivo será gerado | baseline | |

Retorno: `lRet` indicando se o arquivo foi gerado.

```advpl
oHelper:UTCreateFile("Conteúdo do arquivo","Nome.txt")
```

### UTNotDeleteRel()

Não permite a exclusão dos arquivos `.rel` da pasta Spool.

```advpl
oHelper:UTNotDeleteRel()
```

### EnvUpdExp()

Verifica o tipo de Base Congelada utilizada. Retorna `.F.` quando a base for MNT.

```advpl
If oHelper:EnvUpdExp()
    ::AddTestMethod("GPR010_001",,"Benefícios por Entidade")
EndIf
```

### UTEngSPSInstall( cProcess, cCompany, cOrigin )

Instala um processo de procedures em uma determinada empresa.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cProcess | Carácter | Código do processo | | X |
| cCompany | Carácter | Grupo de empresa | Grupo logado | Opcional |
| cOrigin | Carácter | Origem do pacote de procedures | RPO | Opcional |

```advpl
oHelper:UTEngSPSInstall("01", "T1")
```

### UTEngSPSUninstall( cProcess, cCompany )

Desinstala um processo de procedures em uma empresa.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cProcess | Carácter | Código do processo | | X |
| cCompany | Carácter | Grupo de empresa | Grupo logado | Opcional |

```advpl
oHelper:UTEngSPSUninstall("01", "T1")
```

### UTEngSPSBatch( cAction )

Instala ou desinstala em lote todos os processos existentes no RPO em todas as empresas.

| Nome | Tipo | Descrição | Obrigatório |
|---|---|---|---|
| cAction | Carácter | Ação: "1" = Instalação; "2" = Remoção | X |

```advpl
oHelper:UTEngSPSBatch("1")
```

### UTEngSPSStatus( cProcess, cCompany )

Retorna o status do processo na empresa solicitada como objeto JSON.

| Nome | Tipo | Descrição | Default | Obrigatório |
|---|---|---|---|---|
| cProcess | Carácter | Código do processo | | X |
| cCompany | Carácter | Grupo de empresa | Grupo logado | Opcional |

Retorno: objeto JSON com propriedades `status`, `process`, `company`, `version`, `signature`, `idsps`, `generation` e `error`.

```advpl
oSPSStatus := oHelper:UTEngSPSStatus("02","T1")
```

# Padrão ADVPR — Webservice (REST, SOAP e Portal Protheus)

## Quando Usar

- Testes automatizados de Webservices REST (JSON) ou SOAP (XML) do Protheus
- Operações HTTP: POST, GET, PUT e DELETE contra APIs do Protheus ou externas
- Validação de response por comparação de string diretamente no script
- Validação de response por comparação com arquivo **baseline** (2º ou 3º parâmetro `cFile` nos métodos de WS)
- Testes do Portal Protheus que exigem login com `UTSetLoginPP` e envio de corpo `multipart/form-data`

### Configuração no appserver.ini

Para execução local, criar a chave correspondente na seção `[ADVPR]` do `appserver.ini`:

```ini
[ADVPR]
REST=http://localhost:9902/rest/
SOAP=http://localhost:9804/
```

No Servidor Contínuo as URLs/portas são capturadas automaticamente por essas chaves — não passe URL fixa nos métodos, a menos que seja uma URL externa de conteúdo fixo.

Ao informar a suíte à Central de Automação (via Ryver), indicar: nome da suíte, integração com TSS (Sim/Não), autenticação (Sim/Não), e se é REST ou SOAP (se SOAP, em qual filial executar).

---

## Exemplo de Script

### REST com retorno do response — DELETE (CRMS700)

Valida a resposta JSON diretamente no script, verificando a presença da string `"Sucesso"` no campo `response`.

```advpl
//-------------------------------------------------------------------
/*/{Protheus.doc} CRM700_001()
Delete de prospect
@author ADVPR
@version 1.00
/*/
//-------------------------------------------------------------------
METHOD CRM700_001() CLASS CRMS700TestCase
    Local aHeader := {}
    Local cBody   := ''
    Local cRet    := ''
    Local cURL    := "/api/crm/v1/Prospects/API01+01"
    Local oRet    := Nil
    Local oHelper := FWTestHelper():New()

    oHelper:Activate()

    aHeader := {"Content-Type: application/json","Authorization: Basic "+ oHelper:UTSetAuthorization('APICRM','A') +"" }

    If !oHelper:UTSetAPI(cURL,"REST")
        oHelper:UTPutError("Falha ao executar metodo DELETE - Ocorreu um erro ao conectar-se ao servidor")
    Else
        cBody := '{"Code": "API01 "}'
        cRet := oHelper:UTDeleteWS(cBody,aHeader)
        oRet := JsonObject():new()

        If oRet:fromJson(cRet) != Nil
            oHelper:UTPutError("Falha ao executar metodo DELETE - Falha ao converter o retorno em Objeto JSON")
        Else
            If oRet['response'] <> Nil
                If "Sucesso" $ oRet['response']
                    oHelper:lOk := .T.
                Else
                    oHelper:UTPutError("Falha ao executar metodo DELETE - Retorno diferente do esperado")
                Endif
            Else
                oHelper:UTPutError("Falha ao executar metodo DELETE - Retorno diferente do esperado")
            EndIf
        EndIf
    EndIf

    oHelper:AssertTrue(oHelper:lOk,'')
Return oHelper
```

---

### REST com comparação de arquivo baseline — GET (CRM030)

O 2º parâmetro de `UTGetWS` indica o nome do arquivo baseline. Quando informado, o framework compara o response com o arquivo e atualiza `oHelper:lOk` automaticamente.

```advpl
//-------------------------------------------------------------------
/*/{Protheus.doc} CRM030_001()
Get Contacts
@author ADVPR
@version 1.00
/*/
//-------------------------------------------------------------------
METHOD CRM030_001() CLASS CRM030TestCase

    Local oHelper := FWTestHelper():New()
    Local aHeader := {"Content-Type: application/json"}
    Local cRet    := ""

    oHelper:Activate()

    // Indica qual api será utilizada
    oHelper:UTSetAPI("/CRMMCONTACTS/TMK036?Language=EN","REST")

    // Realiza o consumo da api e comparação do response com o arquivo baseline
    cRet := oHelper:UTGetWS(aHeader,"crmm030_002")

    // Grava se o teste passou/não passou
    oHelper:AssertTrue(oHelper:lOk,"")

Return oHelper
```

---

### SOAP com retorno do response — WSFLUIGJURIDICO

Para SOAP, usa-se `UTClientWSDL` passando a operação, o envelope XML e o arquivo `.apw?WSDL`. O response é parseado com `XmlParser()` para navegar na estrutura do retorno.

```advpl
//-------------------------------------------------------------------
/*/{Protheus.doc} FLUIG_001()
Geração de Contrato
@author ADVPR
@version 1.00
/*/
//-------------------------------------------------------------------
METHOD FLUIG_001() CLASS WSFLUIGJURIDICOTestCase

    Local oHelper    := FWTestHelper():New()
    Local cOperation := "MTGERACONTRATOASSUNTOJURIDICO"
    Local cService   := "WSFLUIGJURIDICO.apw?WSDL"
    Local cRet       := ""
    Local cError     := ""
    Local cWarning   := ""
    Local getDate    := DTOS(Date())
    Local dtInclusao := substr(getDate,7,2) + "/" + substr(getDate,5,2) + "/" + substr(getDate,1,4)
    Local cXml       := '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><MTGERACONTRATOASSUNTOJURIDICO xmlns="com.totvs.sigajuri.wsfluigjuridico"><CONTRATOASSUNTOJURIDICO><ADVOGADO>WILLIAN.KAZAHAYA@TOTVS.COM.BR</ADVOGADO><AREA>FIN  </AREA><DATAINCLUSAO>'+ dtInclusao +'</DATAINCLUSAO><DESCRICAOSOLICITACAO>Inclusão para automação</DESCRICAOSOLICITACAO><ESCRITORIO>SP001</ESCRITORIO><POLOATIVO>JLT00101</POLOATIVO><POLOPASSIVO>JLT00201</POLOPASSIVO><SOLICITACAO>1066</SOLICITANTE><SOLICITANTE>Willian Kazahaya</SOLICITANTE><TIPOASSUNTOJURIDICO>006</TIPOASSUNTOJURIDICO><TIPOCONTRATO>001</TIPOCONTRATO><TIPOPESSOAPARTEC>1</TIPOPESSOAPARTEC></CONTRATOASSUNTOJURIDICO></MTGERACONTRATOASSUNTOJURIDICO></soap:Body></soap:Envelope>'
    Local oXml       := Nil

    oHelper:Activate()

    // Faz a consulta no webservice
    cRet := oHelper:UTClientWSDL(,cOperation,cXml,,,cService)

    // Verifica se a consulta ao webservice foi feita corretamente
    If Empty(cRet)
        oHelper:AssertTrue(oHelper:lOK,"Falha ao consultar webservice - Retorno Vazio/Invalido")
    Else
        // Realiza o parser do XML
        If "CODIGOFOLLOWUP" $ cRet
            oXml := XmlParser(cRet,"_", @cError, @cWarning)
            If Empty(oXml)
                oHelper:AssertTrue(oHelper:lOK,cRet)
            Else
                If oXml:_SOAP_ENVELOPE:_SOAP_BODY:_MTGERACONTRATOASSUNTOJURIDICORESPONSE:_MTGERACONTRATOASSUNTOJURIDICORESULT:_CODIGOFOLLOWUP <> Nil
                    oHelper:lOk := .T.
                Endif
            Endif
        Else
            oHelper:UTPutError("Erro retornado:" + cRet)
        EndIf
    Endif

    oHelper:AssertTrue(oHelper:lOk,"")

Return oHelper
```

---

### Portal Protheus — login + GET + POST multipart (PortalPTestCase)

Para scripts do Portal Protheus é necessário conhecer as requisições via "Ferramentas do desenvolvedor" do navegador (método, header, body). `UTSetLoginPP` realiza o login e retorna o `SessionID`, que deve ser incluído no header como `Cookie`. Para `Content-Type: multipart/form-data`, inserir uma linha em branco (`CRLF`) sempre antes do conteúdo de cada campo (ver doc HTTPPost).

```advpl
//-------------------------------------------------------------------
/*/{Protheus.doc} PORTAL_001
Caso de Teste 001 - Teste de Update do Fornecedor
/*/
//-------------------------------------------------------------------
METHOD PORTAL_001() CLASS PortalPTestCase

    Local oHelper     := FWTestHelper():New()
    Local aHeader     := {}
    Local cRetGet     := ""
    Local cRetPost    := ""
    Local cBody       := ""
    Local cApiGet     := "pp/w_PWSF040.apw"
    Local cApiPost    := "pp/w_PWSF042.apw"
    Local cBoundary   := "----------FormBoundaryShouldDifferAtRuntime--"
    Local cUser       := "adm"
    Local cPassword   := "1"
    Local cTipoPortal := "1"
    Local cSessionID  := ""
    Local cCodForn    := "000001"
    Local cLoja       := "01"
    Local cNomeForn   := "FORNECEDOR ACD 32"
    Local cNomeReduz  := "ACD 32"

    oHelper:Activate()

    // Realiza o login no Portal Protheus
    cSessionID := oHelper:UTSetLoginPP(cUser,cPassword,cTipoPortal)

    oHelper:Activate()

    // Define o Header da requisição
    AAdd( aHeader, 'Content-Type: multipart/form-data; boundary=' + cBoundary )
    AAdd( aHeader, 'Cookie: ' + cSessionID )

    // Realiza o Get do Fornecedor
    oHelper:UTSetAPI(cApiGet,"SOAP")
    cRetGet := oHelper:UTGetWS(aHeader,/*"PORTAL_001_GET"*/) // 2º parâmetro (cFile) p/ validar via baseline

    // Realiza o Update do Fornecedor, caso o Get retorne corretamente
    If !Empty(cRetGet) .and. cCodForn $ cRetGet
        oHelper:UTSetAPI(cApiPost,"SOAP")
        // Monta o corpo multipart/form-data (uma linha em branco antes do valor de cada campo).
        // [corpo abreviado] — exemplo de um campo:
        cBody += '--' + cBoundary
        cBody += CRLF
        cBody += 'Content-Disposition: form-data; name="CSUPPLIERCODE_H"'
        cBody += CRLF
        cBody += CRLF
        cBody += cCodForn
        cBody += CRLF
        // ... demais campos (CNAME, CNICKNAME, CADDRESS_1, ...) seguem o mesmo padrão ...
        cBody += '--' + cBoundary + '--'

        cRetPost := oHelper:UTPostWS(cBody,aHeader,/*"PORTAL_001_POST"*/) // 3º parâmetro (cFile) p/ validar via baseline

        // Verificação de string no retorno
        If "Alteracoes efetuadas com SUCESSO" $ cRetPost
            oHelper:lOk := .T.
        Else
            oHelper:UTPutError("Falha ao executar método POST.")
        EndIf

        // Verificação do update na tabela SA2
        cTable := "SA2"
        cQuery := "A2_COD = '"+cCodForn+"' AND A2_LOJA = '"+cLoja+"' "
        oHelper:UTQueryDB(cTable,"A2_NOME"  ,cQuery, cNomeForn)
        oHelper:UTQueryDB(cTable,"A2_NREDUZ",cQuery, cNomeReduz)
    Else
        oHelper:UTPutError("Falha ao executar método GET.")
    EndIf

    oHelper:AssertTrue(oHelper:lOk,"")

Return oHelper
```

> Nota: no exemplo original o corpo multipart preenche aproximadamente 20 campos do fornecedor; acima está abreviado mantendo o padrão exato de montagem (`'--'+cBoundary` / `CRLF` / `Content-Disposition` / linha em branco / valor / `CRLF`). Execução do Portal exige protheus_data (systemload e web) atualizados, usuários configurados na Base Congelada e chave `SOAP=http://localhost:9804/` na seção `[ADVPR]` do appserver.ini.

---

## Métodos Relevantes

Os métodos abaixo pertencem à classe `FWTestHelper`. Consulte `api-fwtesthelper.md` para assinaturas completas, tipos de parâmetros e comportamento de retorno.

| Método | Tipo de WS | Descrição |
|---|---|---|
| `UTSetAuthorization(cUser, cType)` | REST | Gera o token de autenticação Basic para o header `Authorization` |
| `UTSetAPI(cURL, cType)` | REST / SOAP | Define a URL relativa e o tipo da API (`"REST"` ou `"SOAP"`) que será consumida |
| `UTGetWS(aHeader, cFile)` | REST / Portal | Executa um GET; `cFile` (opcional) compara response com arquivo baseline |
| `UTPostWS(cBody, aHeader, cFile)` | REST / Portal | Executa um POST; `cFile` (opcional) compara response com arquivo baseline |
| `UTPutWS(cBody, aHeader, cFile)` | REST | Executa um PUT; `cFile` (opcional) compara response com arquivo baseline |
| `UTDeleteWS(cBody, aHeader)` | REST | Executa um DELETE e retorna o response como string |
| `UTClientWSDL(,cOperation, cXml,,, cService)` | SOAP | Consome um serviço SOAP a partir do WSDL; retorna o response XML |
| `UTSetLoginPP(cUser, cPassword, cTipoPortal)` | Portal | Realiza login no Portal Protheus e retorna o `SessionID` |
| `UTPutError(cMsg)` | Todos | Registra mensagem de erro no resultado do caso de teste |
| `UTQueryDB(cTable, cField, cWhere, cExpected)` | Todos | Consulta um campo na tabela e compara com o valor esperado |
| `AssertTrue(lCond, cMsg)` | Todos | Registra o resultado final do caso de teste (passou/não passou) |

Funções nativas ADVPL utilizadas nos exemplos: `JsonObject()`, `XmlParser()`, `DTOS()`, `substr()`.

---

## Boas Práticas Específicas

Consulte `best-practices.md` para as diretrizes gerais de escrita de scripts ADVPR. As práticas abaixo são específicas para testes de Webservice.

**Configuração local**
- Sempre criar a chave `REST` ou `SOAP` na seção `[ADVPR]` do `appserver.ini` para testes locais. Nunca codificar a URL no script — ela é capturada automaticamente pela chave no Servidor Contínuo.

**Validação do response**
- Prefira validação por string (`"Sucesso" $ cRet`) quando o response é simples e estável.
- Use o parâmetro `cFile` (2º parâmetro em `UTGetWS`/`UTPutWS`, 3º em `UTPostWS`) para comparação com arquivo baseline quando o response é um JSON/XML estruturado e determinístico.
- O response retornado pelos métodos de WS é exibido automaticamente como mensagem ao final do caso de teste.

**Verificação no banco de dados**
- Após POST/PUT, confirme o resultado diretamente no banco com `UTQueryDB`. Isso garante que o dado foi persistido corretamente, independentemente do response HTTP.

**SOAP**
- Informe sempre em qual filial a suíte SOAP deve ser executada ao comunicar à Central de Automação.
- Monte o envelope XML completo antes de chamar `UTClientWSDL`; use `XmlParser()` para navegar no retorno e evite comparações de string frágeis em estruturas XML complexas.

**Portal Protheus**
- Inspecione as requisições pelo "Ferramentas do desenvolvedor" do navegador antes de escrever o script (método, headers exatos, estrutura do body).
- Para `multipart/form-data`, sempre inserir `CRLF` em branco antes do valor de cada campo (obrigatorio pelo protocolo HTTP multipart).
- O `SessionID` retornado por `UTSetLoginPP` deve ser enviado no header `Cookie` em todas as requisições subsequentes.
- A execução de testes do Portal exige protheus_data (systemload e web) atualizado e usuários configurados na Base Congelada.

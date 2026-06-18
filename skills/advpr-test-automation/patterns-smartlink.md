# Padrão ADVPR — Integração SmartLink

## Quando Usar

Aplique este padrão quando o caso de teste automatizado precisar interagir com o **SmartLink** — componente de integração que conecta os aplicativos TOTVS com o ERP Protheus. As integrações suportadas são: **Gesplan**, **Conta Digital** e **GRR**.

### Pré-requisitos de ambiente

- **2 credenciais TOTVS RAC** (uma para envio e outra para leitura de mensagens) criadas no ambiente de produção.
- No `appserver.ini`, seção do environment, incluir a chave:
  `fw-tf-registry-endpoint=https://endpoint-registry.totvs.app/api/v1/services`
- Para credenciais diferentes do padrão da Automação, incluir na seção `[ADVPR]`:
  `TENANTID_SMTLINK`, `CLIENTID_SMTLINK_SEND`, `CLIENTSECRET_SMTLINK_SEND`, `CLIENTID_SMTLINK_READ`, `CLIENTSECRET_SMTLINK_READ`.
- Configuração do TenantID **não** está disponível na Base Congelada; é obrigatória apenas na execução local.

### Cinco grupos de métodos

| Grupo | Método principal | Responsabilidade |
|---|---|---|
| 1 — Configuração TenantID | `UTGetTenantID(cInteg)` | Retorna o Tenant ID da fila para uso no content da mensagem |
| 2 — Envio e leitura | `UTExecSmtLink(cTypeMessage, cMessage, cAudience)` | Gerencia a fila, envia a mensagem e inicia o Job de leitura |
| 3 — Validação de resposta | `UTVldSmtLink(cTestCase, aTagIgnore)` | Compara o retorno das mensagens processadas com o arquivo BASE |
| 4 — Envio pela rotina Protheus | `UTSetConfigSendSmtLink(cInteg)` + `UTReadSmtLink(cInteg)` | Seta credenciais quando a mensagem é enviada pela própria rotina, não pelo caso de teste |
| 5 — Execução na esteira | — | No SmartTest, executar apenas uma suíte SmartLink por vez para evitar concorrência de fila; novas suítes exigem abertura de task no Ryver |

#### Regras de fila de `UTExecSmtLink`

- Fila **vazia** → envia a mensagem do caso de teste.
- Fila **com mensagem** → aguarda o processamento.
- Fila **travada por 5 min** → remove a mensagem travada.
- Fila **travada por 15 min** sem conseguir remover → encerra o caso de teste com erro.
- Quando `cAudience` é informado, usa `FwTotvsLinkClient():SendAudience()`; caso contrário usa `FwTotvsLinkClient():Send()`. Em falha de comunicação, verificar `FwTotvsLinkClient():GetError()`.
- Ao final do envio, inicia automaticamente o Job `FWTOTVSLINKJOB()` para leitura.

---

## Exemplo de Script

### Exemplo 1 — Validação via query (teste positivo) — CTB102G

```advpl
//-------------------------------------------------------------------
/*/{Protheus.doc} C102XG_001
INCLUSÃO PARTIDA DOBRADA VALOR COM DECIMAL E CONTINUACAO DE HISTORICO
@author TOTVS
@version 1.0
/*/
//------------------------------------------------------------------
METHOD C102XG_001() CLASS CTB102GTestCase
    Local oHelper := FWTestHelper():New()
    Local cMessage as character
    Local cTenantId as character
    Local cTypeMessage := "CT2readXGsp"
    Local cAudience := "LinkProxy"

    oHelper:Activate()
    cTenantId := oHelper:UTGetTenantID("GESPLAN")

    BeginContent Var cMessage
    {
        "specversion": "1.0",
        "type": "CT2readXGsp",
        "tenantId": "%Exp:cTenantId%",
        "generatedOn": "2021-06-08T15:18:08.367574Z",
        "data": [{
            "COD_EMP":"T1" ,
            "CT2_DATA":"15/04/2023" ,
            "CT2_LOTE":  "998877",
            "CT2_SBLOTE":  "001",
            "CT2_FILIAL":  "D MG 01",
            "CT2_LINHA":  "001",
            "CT2_MOEDLC":  "01",
            "CT2_DC" :  "3",
            "CT2_CREDIT":  "CTBXATUC",
            "CT2_DEBITO":  "CTBXATUD",
            "CT2_KEY":  "PARTIDA DOBRADA VALOR COM DECIMAL",
            "CT2_TPSALD": "1",
            "CT2_ROTINA": "WFNCASH",
            "CT2_VALOR":  1500.60 ,
            "CT2_ORIGEM":  "GESPLAN"
        }]
    }
    EndContent

    oHelper:UTExecSmtLink( cTypeMessage, cMessage, cAudience )

    // Ponto de verificação - CT2
    cTable := "CT2"
    cQuery := "CT2_DC = '3' AND CT2_MOEDLC = '01' AND CT2_TPSALD = '1' AND CT2_LOTE = '998877' AND CT2_SBLOTE = '001' AND CT2_DATA = '20230415' AND CT2_KEY ='PARTIDA DOBRADA VALOR COM DECIMAL' AND CT2_ROTINA='WFNCASH'"
    oHelper:ChangeFil("D MG 01 ")
    oHelper:UTQueryDB(cTable,"CT2_DEBITO",cQuery ,"CTBXATUD")
    oHelper:UTQueryDB(cTable,"CT2_CREDIT",cQuery ,"CTBXATUC")
    oHelper:UTQueryDB(cTable,"CT2_VALOR" ,cQuery , 1500.60)
    oHelper:UTQueryDB(cTable,"CT2_ORIGEM",cQuery , "GESPLAN")
    oHelper:AssertTrue(oHelper:lOk)

Return oHelper
```

### Exemplo 2 — Comparação de arquivo (teste negativo) — CTB102G

```advpl
//-------------------------------------------------------------------
/*/{Protheus.doc} C102XG_003
TESTE NEGATIVO ITENS OBRIGATÓRIOS VAZIOS E NÃO ENVIADOS
@author TOTVS
@version 1.0
/*/
//------------------------------------------------------------------
METHOD C102XG_003() CLASS CTB102GTestCase
    Local oHelper := FWTestHelper():New()
    Local cMessage as character
    Local cTenantId as character
    Local cTypeMessage := "CT2readXGsp"
    Local cAudience := "LinkProxy"

    oHelper:Activate()
    cTenantId := oHelper:UTGetTenantID("GESPLAN")

    BeginContent Var cMessage
    {
        "specversion": "1.0",
        "type": "CT2readXGsp",
        "tenantId": "%Exp:cTenantId%",
        "generatedOn": "2021-06-08T15:18:08.367574Z",
        "data": [{
            "COD_EMP":"" ,
            "CT2_DATA":"" ,
            "CT2_LOTE":  "",
            "CT2_SBLOTE":  "001",
            "CT2_FILIAL":  "D MG 01",
            "CT2_LINHA":  "001",
            "CT2_MOEDLC":  "01",
            "CT2_EMPORI":  "T2",
            "CT2_FILORI":  "M PR 02"
        }]
    }
    EndContent

    oHelper:UTExecSmtLink( cTypeMessage, cMessage, cAudience )

    oHelper:UTVldSmtLink("C102XG_003")

    oHelper:AssertTrue(oHelper:lOk)

Return oHelper
```

---

## Métodos Relevantes

| Método / Recurso | Descrição |
|---|---|
| `UTGetTenantID(cInteg)` | Retorna o Tenant ID da fila para a integração informada (ex.: `"GESPLAN"`). Usado para popular o campo `tenantId` no JSON da mensagem. |
| `UTExecSmtLink(cTypeMessage, cMessage, cAudience)` | Gerencia o ciclo completo de envio: verifica e limpa a fila, envia a mensagem e inicia o Job de leitura. |
| `UTVldSmtLink(cTestCase, aTagIgnore)` | Valida a resposta comparando com arquivo BASE na pasta baseline. Gera arquivo AUTO na primeira execução; após conferência, renomear para BASE. Tags dinâmicas `time` e `TenantId` são ignoradas automaticamente. |
| `UTSetConfigSendSmtLink(cInteg)` | Seta TenantId e credenciais de envio quando a mensagem é disparada pela própria rotina Protheus (não pelo script de teste). |
| `UTReadSmtLink(cInteg)` | Lê as mensagens usando as credenciais de leitura; depende das classes MessageReader configuradas no setup do robô. |
| `ChangeFil(cFilial)` | Muda a filial ativa durante o teste. Deve ser restaurada ao valor original ao final (ver `best-practices.md`). |
| `UTQueryDB(cTabela, cCampo, cWhere, xValor)` | Consulta o banco e acumula o resultado em `lOk`. Usado para verificar se o registro foi incluído corretamente. |
| `AssertTrue(lCondicao)` | Assertiva positiva; registra sucesso se `lCondicao` for `.T.`. |
| `AssertFalse(lCondicao)` | Assertiva negativa; registra sucesso se `lCondicao` for `.F.`. Útil para validar que um registro **não** foi gerado em testes negativos. |

### Construção da mensagem

Utilize `BeginContent Var cNome ... EndContent` para definir o JSON inline no script ADVPL. Dentro do bloco, a macro `%Exp:cTenantId%` é expandida em tempo de execução com o valor da variável `cTenantId` retornada por `UTGetTenantID`.

### Classes de apoio (configuradas no setup do robô)

- **`FwTotvsLinkClient`** — responsável pelo envio e leitura via SmartLink (`Send`, `SendAudience`, `GetError`).
- **`MessageReader`** — classe base para leitores de mensagens específicos por tipo (ex.: `CT2respXGspMessageReader`, `MOVrespXGspMessageReader`). Exigida quando se usa `UTReadSmtLink`.

Detalhes completos de assinaturas e parâmetros estão em `api-fwtesthelper.md`.

---

## Boas Práticas Específicas

- **Credenciais RAC e appserver.ini:** configure as 2 credenciais TOTVS RAC (envio e leitura) no ambiente antes de executar qualquer suíte SmartLink. Em execução local, garanta a chave `fw-tf-registry-endpoint` no `appserver.ini`. Credenciais customizadas vão na seção `[ADVPR]` com as chaves `TENANTID_SMTLINK`, `CLIENTID_SMTLINK_SEND`, `CLIENTSECRET_SMTLINK_SEND`, `CLIENTID_SMTLINK_READ` e `CLIENTSECRET_SMTLINK_READ`.

- **`ChangeFil` com restauração obrigatória:** sempre que o teste precisar mudar de filial, chame `ChangeFil` antes da verificação e restaure a filial original ao final do método. Consulte `best-practices.md` para o padrão completo de ida e volta.

- **Validação positiva — `UTQueryDB` + `AssertTrue`:** após `UTExecSmtLink`, consulte os campos-chave com `UTQueryDB` e confirme com `oHelper:AssertTrue(oHelper:lOk)`. Este padrão valida que o Protheus processou corretamente a mensagem recebida (ver Exemplo 1).

- **Validação de erro — `UTQueryDB` + `AssertFalse` ou `UTVldSmtLink`:** em testes negativos (campos obrigatórios ausentes, valores inválidos), use `UTQueryDB` combinado com `AssertFalse` para confirmar que o registro **não** foi gerado, ou use `UTVldSmtLink` para comparação do arquivo de resposta de erro com o arquivo BASE (ver Exemplo 2).

- **Concorrência na esteira:** execute apenas uma suíte SmartLink por vez no SmartTest. Suítes paralelas causam concorrência na fila e resultam em falhas intermitentes. Para adicionar uma nova suíte ao pipeline, abra task no Ryver.

- **Arquivo BASE para `UTVldSmtLink`:** na primeira execução o método gera um arquivo AUTO. Revise o conteúdo, valide os dados e então renomeie para BASE. Somente após isso o método passa a funcionar como verificação efetiva.

Para regras gerais de estrutura de scripts, nomenclatura de métodos e configuração de classes de teste, consulte `best-practices.md`.

# Padrão ADVPR — Preparação de Rotina (Desvio de Telas)

## Quando Usar

Para rotinas que **não possuem execução automática** (sem `ExecAuto`), é possível prepará-las para a execução de testes automatizados pelo ADVPR. A preparação consiste em **desviar da interface** — janelas de diálogo, perguntas e telas customizadas — para que os testes foquem exclusivamente na **regra de negócio**, sem interação humana.

Exemplos de situações que exigem preparação:

- Rotinas que exibem `Alert()`, `MsgAlert()`, `MsgInfo()`, `MsgStop()` ou `MsgYesNo()` no fluxo normal.
- Rotinas que chamam `Pergunte()` antes de processar (parâmetros em tela).
- Telas customizadas sem ligação direta com o dicionário de dados (ex.: GetDados, campos livres).
- Rotinas MVC com views que exibem seleções ou avisos intermediários.

> **Atenção:** toda e qualquer interface deve ser desviada antes de executar o teste. Nenhuma janela pode aguardar interação do operador durante uma execução automatizada.

## Exemplo de Script

### Atributos auxiliares

Antes dos desvios, dois atributos pré-definidos controlam o comportamento:

- `lAutomato` — variável lógica que indica se o acesso à rotina está sendo feito pelo robô de testes. O código da rotina verifica este valor para decidir se exibe ou não a interface.
- `aRetAuto` — array responsável por armazenar os dados que seriam preenchidos manualmente em telas customizadas (telas sem ligação direta com o dicionário de dados).

### Desvio de mensagem (Help vs MsgStop)

Após o desvio com `lAutomato`, no lugar de `Alert`, `MsgAlert`, `MsgInfo`, `MsgStop` ou `MsgYesNo` usa-se a função `Help()`, que concatena a mensagem internamente e a exibe apenas na interface do robô.

```advpl
//--------------------------------------------------------------------
// Se execução via Robô, concatena a mensagem desviando da tela
//--------------------------------------------------------------------
If !lRet
    If !lAutomato
        MsgStop( "Nao existe chave de relacionamento definida para o alias." )
    Else
        Help( " ", 1, "Help",, "Nao existe chave de relacionamento definida para o alias.", 1 )
    EndIf
EndIf
```

### Desvio de Pergunte() (segundo parâmetro = exibição em tela = .F.)

```advpl
//--------------------------------------------------------------------
// Se execução via Robô não mostra a tela de perguntas
//--------------------------------------------------------------------
If !lAutomato
    Pergunte( "MTA440", .T. )
Else
    Pergunte( "MTA440", .F. )
EndIf
```

## Métodos Relevantes

| Elemento | Descrição |
|---|---|
| `lAutomato` | Variável lógica pré-definida; `.T.` quando o robô está no controle. Usada em todos os desvios de interface. |
| `aRetAuto` | Array pré-definido; armazena os dados que seriam digitados manualmente em telas customizadas. |
| `Help()` | Substituto de `Alert`, `MsgAlert`, `MsgInfo`, `MsgStop` e `MsgYesNo` durante a execução automática. Concatena a mensagem para o robô sem exibir janela. Dispensa o uso de `IsBlind` (ver `best-practices.md`). |
| `Pergunte(..., .F.)` | Chamada de `Pergunte` com o segundo parâmetro `.F.` para suprimir a exibição da tela de parâmetros durante o teste. |
| `MSGetDAuto` | Simula o modelo de interface da GetDados (modelos 2 e 3) para preenchimento automático de grades. |
| `GetParAuto` | Função estática declarada no TestCase; recupera o conteúdo de `aRetAuto` para as telas customizadas. |
| `AutoParDef` | Função estática declarada no TestCase; retorna o array com os dados do caso de teste que serão usados por `GetParAuto`. |

### Cenários documentados no TDN

- **CNTA210 — MSGetDados/MSNewGetDados:** desvio via `lAutomato`; preenchimento de grades com `MSGetDAuto` e `aRetAuto`; recuperação pelo `GetParAuto` no TestCase; validações da grade também devem ser desviadas.
- **MATA450 — chamada sem passar pelo Browse (Liberação de Crédito):** a rotina recebe a operação do `MenuDef()` e `lAutomato`; executa conforme o `MenuDef()` e avalia `lAutomato` para desconsiderar avisos, perguntes e interfaces intermediárias.
- **FINA060 — simulação de preenchimento em tela (Transferência de portador):** desvio via `lAutomato`; campos preenchidos por `GetParAuto()` instanciado no TestCase; `aRetAuto` declarado como estático no `SetUpClass()`; `AutoParDef()` retorna o array do caso de teste; validações de preenchimento são mantidas.
- **CRMA020 — MVC com particularidades (Transferência de Contas):** usa mais de um modelo de dados com views complementares; desvios adicionados para impedir mensagens de seleção; atenção para não remover processos essenciais (ex.: load do modelo de dados) nem desviar a exibição da View indevidamente.

## Boas Práticas Específicas

- **Use as variáveis pré-definidas:** sempre que possível, utilize `lAutomato` e `aRetAuto`. Evite criar variáveis `Private` e/ou estáticas desnecessárias ao alterar fontes do produto padrão — elas podem impactar tanto os testes automatizados quanto os testes manuais.
- **Minimize a "poluição" do código:** como há alteração em fontes do produto, a diretriz do TDN é evitar ao máximo adicionar declarações que não sejam estritamente necessárias para o desvio.
- **Mantenha as validações de negócio:** desviar a interface não significa remover as validações. Campos obrigatórios, regras de preenchimento e consistências de dados devem permanecer ativos durante o teste.
- **Não remova processos essenciais em MVC:** em rotinas MVC, certifique-se de que o load do modelo de dados e os processos críticos do fluxo não sejam suprimidos junto com a interface. Desvie apenas a exibição das Views e as mensagens de seleção.
- **Consulte `best-practices.md`** para as diretrizes gerais de estrutura de TestCase, uso de `IsBlind`, e organização de `SetUpClass`/`TearDownClass` no ADVPR.

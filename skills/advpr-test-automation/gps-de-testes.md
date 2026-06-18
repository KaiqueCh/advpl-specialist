# GPS de Testes

Ferramenta integrada ao ADVPR que indica quais suítes de testes e casos de testes passam por um determinado trecho do código, com base em dados da última cobertura de código coletada.

## Introdução

Ferramenta que indica quais suítes de testes e casos de testes passam por um determinado trecho do código, utilizando os dados da última cobertura de código. O objetivo é facilitar a identificação de quais testes podem ser executados de acordo com as alterações previstas/realizadas. O Dev/Tester pode usar a ferramenta antes e depois das alterações para identificar quais suítes e casos de testes cobrem as linhas alteradas, evitando colaterais indesejados.

## Como Funciona

Com base em um programa e um intervalo de linhas, os dados são capturados via API no Portal da Qualidade Protheus. Os valores informados são sempre referentes à última extração publicada pela Central de Automação - Protheus. São consideradas apenas linhas válidas.

## Utilização

Para entrar na funcionalidade, clicar no banner "GPS de Testes" (a tela é expandida). Campos:

- **Programa**: nome do fonte pesquisado (não é necessário informar a extensão).
- **Data/Hora do fonte**: preenchido automaticamente conforme o fonte informado. Corresponde à data/hora do fonte considerado na última publicação da cobertura.
- **Linha Inicial**: número inicial do grupo de linhas a consultar.
- **Linha Final**: número final do grupo de linhas a consultar.

Observações: sem valores em Linha Inicial/Final, considera todas as linhas do fonte. Para uma linha específica, informar o mesmo valor em Linha Inicial e Final. Após preencher, clicar em **Consultar**.

O resultado lista, abaixo do cabeçalho, quais testes passam pelo grupo de linhas:

- **Programa**: nome do programa consultado.
- **TestSuite**: lista de TestSuites que passam pelo grupo de linhas.
- **TestCase**: lista de TestCases que passam pelo grupo de linhas.
- **TestMethod**: lista de TestMethods (CTs) que passam pelo grupo de linhas.

Clicar duas vezes na coluna exibe os dados em um painel para melhor visualização.

**Exportar**: os dados podem ser exportados para `.csv` clicando no botão **Salvar** e escolhendo o destino.

## Dicas

Recomenda-se fazer um merge no TFS para saber a diferença das linhas do fonte antigo x alterado.

- **Exemplo 1**: alterei a linha 5104 do FINA040 e na nova versão o conteúdo foi para 5105. Qual linha informar? Usar o merge do TFS (fonte da data da última cobertura x fonte local). R: informar os dados da versão antiga, para garantir que os testes que passam nas linhas antigas continuem funcionando após a alteração.
- **Exemplo 2**: muitas alterações em uma função, em pontos diferentes — quais linhas informar? R: informar o grupo de linhas do início da declaração da função até seu Return, obtendo os testes que cobrem essa função.

# ADVPR — Boas Práticas na Automação

Direcionamento para evitar não conformidades na confecção de scripts de testes, garantindo qualidade e facilitando manutenções futuras.

## Evite Utilizar

- **Variáveis**: Privates, públicas e estáticas nos scripts, pois podem impactar a execução dos demais testes do projeto do robô.
- **Comandos de loop**: `While`/`DbSkip`, `For`/`Next`, pois podem onerar a execução dos testes.
- **Alteração direta no banco de dados**: `RecLock`/`MsUnLock` — terminantemente **PROIBIDO**, pois efetuam gravação direto no banco fugindo do processo de avaliação de regra de negócios.
- **Comandos de banco de dados**: `Select`, `RetSQLName`, `D_E_L_E_T_`, `ChangeQuery`, `DbUseArea`, `DbCloseArea`, `TCGenQry`. Queries devem ser utilizadas apenas para análise do resultado esperado do robô, efetuadas especificamente pelo método do ADVPR `UTQueryDB`.
- **Posicionamento no banco de dados**: `DbSelectArea`, `DbSetOrder`, `DbSeek`. Para manter a padronização, utilizar o método do ADVPR `UTFindReg`.
- **Alteração de SXs**: `PutMV`. Não alterar informações diretamente nos SXs, pois altera as informações padrões sistêmicas impactando a execução dos casos de testes.
- Não utilizar strings de localização dos arquivos.
- Não utilizar CHs de produto no TestCase, Group ou Suite.
- Sempre utilizar a função `help()` para envio de mensagens. Assim não é necessário usar a função `IsBlind` nas tratativas de mensagens para execução automática.

**Exceção**: scripts de relatórios padrão TOTVS Report, onde às vezes há necessidade de replicar as variáveis privates declaradas antes da chamada do `ReportDef()` e validações de SX3 que mencionam as privates `ALTERA` e `INCLUI`.

## Dependência de Métodos

- **Alteração de parâmetros (SX6)**: sempre que utilizar o método `UTSetParam()`, após o commit restaurar os valores default com `UTRestParam()`.
- **Alteração de filial**: sempre que utilizar `ChangeFil()`, após o resultado esperado restaurar a filial logada para a filial descrita no Setup do robô com o próprio `ChangeFil()`.
- **Alteração de data base**: sempre que alterar a database para execução de um test case, após o commit restaurar a data base com `dDataBase := DATE()` para manter a integridade das execuções e não impactar os demais casos de testes.

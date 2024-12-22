![Badge em Desenvolvimento](http://img.shields.io/static/v1?label=STATUS&message=EM%20DESENVOLVIMENTO&color=GREEN&style=for-the-badge)
# Leitor de Notas de Corretagem
Leitor de notas de corretagem para importar em planilhas

# Padrões Usados nesse Documento
Nota de Corretagem = NC

Notas de Corretagem = NCs

# Requisitos
É necessário o pacote poppler-utils instalado

# Histórico
Nessa primeira versão está lendo e convertendo somente NCs da Nomad.

A Nomad modificou suas NCs a partir do mês 11/2024, o que gerou uma atualização no script, portanto deve-se validar a data da NC antes da execução do script.
Usar a versão 1 para NCs até 11/2024 e a versão 2 para NCs posteriores.

# Continuidade
O objetivo principal foi criar uma saída da NC para inserir dados na planilha do dlombello, portanto o padrão atual está descrito abaixo:

AÇÃO;DATA;(C|V);VALOR;PREÇO;FIXO(0,00);FIXO(NOMAD);FIXO(0,00);FIXO(USD)

Exemplo

AMT;12/11/2024;C;0,08286342;193,0888;0,00;NOMAD;0,00;USD

# Observações
1. Eu criei a nota de corretagem para a Nomad porque é o único banco que tenho esse tipo de documento;
2. Caso precise extrair dados de NC de outras casas de investimento, favor compartilhar para análise;
3. Caso precise extrair dados para outros fins, favor compartilhar para análise.

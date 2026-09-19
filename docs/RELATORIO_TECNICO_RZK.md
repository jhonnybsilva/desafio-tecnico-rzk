# Relatório Técnico: Análise de Dados e Modelagem E-Commerce

**Candidato:** Jhonny Brasiliano da Silva  
**Vaga:** Analista de Dados - RZK Digital  
**Base de Dados:** Brazilian E-Commerce Public Dataset (Olist)  

---

## 1. Introdução

Para este desafio técnico da **RZK Digital**, trabalhei na análise dos dados públicos de e-commerce brasileiro entre os anos de 2016 e 2018.

O objetivo foi extrair insights sobre o desempenho de **categorias** e **sellers**, definir critérios claros para avaliar os melhores participantes do marketplace e construir uma modelagem dimensional no padrão **Star Schema**, pronta para consumo no Power BI e com visualizações interativas seguindo a paleta de cores da empresa.

---

## 2. Critérios e Metodologia Adotada

Antes de rodar os números, defini algumas regras de negócio essenciais para garantir que os resultados fossem confiáveis:

1. **Foco em Pedidos Entregues (`delivered`):**  
   Filtrei a base para considerar apenas os pedidos efetivamente entregues ao cliente final. Pedidos cancelados ou com problema de estoque não devem contar como faturamento realizado nem como volume entregue.

2. **Faturamento vs. Frete:**  
   Considerei como faturamento o valor dos produtos (`price`). O frete foi mantido na tabela fato como métrica separada, já que o valor do frete repassa o custo logístico e não a receita do produto em si.

3. **Volume de Itens:**  
   Contagem real de itens vendidos (`order_item_id`). Se um cliente comprou 3 unidades do mesmo produto no mesmo pedido, isso conta como volume 3.

4. **Tratamento das Avaliações (O ponto crítico da análise):**  
   Ao olhar para as notas de avaliação (1 a 5 estrelas), notei algo que acontece com frequência em bases de marketplace: categorias e lojistas que fizeram **uma única venda** no ano e receberam nota 5 acabavam ficando em 1º lugar se olhássemos apenas para a média simples.  
   Para evitar essa distorção e trazer um resultado que faça sentido pro negócio, analisei os dados de duas formas:
   - **Nota Média Pura:** O topo matemático direto sem filtros.
   - **Nota Média com Consistência:** Categorias e sellers com volume mínimo de avaliações (pelo menos 20 a 25 avaliações), identificando quem realmente manteve um padrão alto de qualidade com volume relevante.

---

## 3. Respostas das Questões

### Questão 1: Melhores Categorias de Produtos por Ano

| Ano | Maior Faturamento | Maior Volume de Itens | Maior Nota Média (Geral) | Maior Nota Média (Consistente)* |
| :---: | :--- | :--- | :--- | :--- |
| **2016** | **Móveis Decoração** (R$ 5.690,52) | **Móveis Decoração** (65 itens) | **Alimentos** (5,0 ★ - 1 pedido) | **Móveis Decoração** (3,7 ★ - 64 avaliações) |
| **2017** | **Cama, Mesa e Banho** (R$ 490.596,92) | **Cama, Mesa e Banho** (5.135 itens) | **Artes e Artesanato** (5,0 ★ - 2 pedidos) | **Livros de Interesse Geral** (4,5 ★ - 226 avaliações) |
| **2018** | **Beleza e Saúde** (R$ 755.724,50) | **Beleza e Saúde** (5.841 itens) | **CDs e DVDs** (5,0 ★ - 1 pedido) | **Livros Importados** (4,6 ★ - 43 avaliações)<br>*(Livros Interesse Geral ficou logo atrás com 4,4 ★ em 263 avaliações)* |

**Principais observações:**
- Em **2016**, como a operação da plataforma estava no início, o volume foi concentrado no final do ano e a categoria de Móveis puxou tanto a receita quanto a quantidade de itens.
- Em **2017**, com o marketplace já escalando forte, **Cama, Mesa e Banho** liderou com folga em receita e itens.
- Em **2018**, o consumo migrou fortemente para itens de compra recorrente e cuidados pessoais, fazendo **Beleza e Saúde** assumir o 1º lugar com mais de R$ 755 mil de faturamento.
- No quesito **satisfação do cliente**, a categoria de **Livros** foi a grande campeã de consistência em 2017 e 2018, mantendo médias acima de 4,45 estrelas com centenas de pedidos entregues.

---

### Questão 2: Melhores Sellers por Ano

| Ano | Maior Faturamento | Maior Volume de Itens | Maior Nota Média (Consistente) |
| :---: | :--- | :--- | :--- |
| **2016** | `620c87c171fb...` (R$ 4.887,60 - Resende/RJ) | `620c87c171fb...` (24 itens) | `024b564ae893...` (5,0 ★ - 6 avaliações - Franca/SP) |
| **2017** | `53243585a1d6...` (R$ 177.557,31 - Curitiba/PR) | `cc419e0650a3...` (1.222 itens - Santo André/SP) | `48efc9d94a98...` (5,0 ★ - 33 avaliações sem nenhuma nota baixa!) |
| **2018** | `4869f7a5dfa2...` (R$ 136.164,90 - Guariba/SP) | `955fee9216a6...` (1.252 itens - São Paulo/SP) | `d9bd94811c33...` (4,8 ★ - 61 avaliações - São Bernardo/SP) |

**Principais observações:**
- Tanto em 2017 quanto em 2018, o seller que mais faturou não foi o que mais vendeu em quantidade. O lojista líder em receita atua no segmento de relógios/acessórios de ticket alto, enquanto o líder de volume vende produtos de utilidades e cama/mesa/banho de baixo valor unitário.
- Vale destacar o seller `48efc9d94a98...` em 2017, que conseguiu nota máxima de 5,0 em 33 pedidos seguidos, algo bem raro em operações de marketplace.

---

### Questão 3: Ticket Médio por Seller

Analisei a métrica sob duas visões:
- **Ticket Médio por Pedido:** Faturamento do seller / Total de pedidos únicos
- **Ticket Médio por Item:** Faturamento do seller / Quantidade de itens vendidos

**Resumo estatístico do Ticket Médio por Pedido:**
- **Média geral entre os lojistas:** R$ 195,52
- **Mediana:** R$ 105,14
- **Ticket médio consolidado da plataforma:** R$ 137,04
- **Primeiro quartil (25% dos lojistas):** até R$ 57,00
- **Terceiro quartil (75% dos lojistas):** até R$ 209,50

**Por que a média e a mediana são tão distantes?**  
A mediana de R$ 105,14 mostra que metade dos lojistas trabalha com pedidos de valor mais acessível. Porém, a média sobe para quase R$ 200 porque temos alguns lojistas bem específicos vendendo itens caros (móveis corporativos, instrumentos, equipamentos de TI).

**Top 3 Sellers com maior Ticket Médio (mínimo de 10 vendas):**
1. `59417c56835dd8e2e...`: Ticket de **R$ 2.025,50** por pedido (Móveis de Escritório - Bento Gonçalves/RS)
2. `40db9e9aa57f7bb15...`: Ticket de **R$ 1.930,67** por pedido (Equipamentos Agro/TI - Londrina/PR)
3. `2bf6a2c1e71bbd29a...`: Ticket de **R$ 1.687,63** por pedido (Instrumentos Musicais - Maringá/PR)

---

## 4. Modelagem Dimensional (Star Schema)

Construí o modelo seguindo a metodologia Kimball, separando claramente o que é evento (fato) do que é contexto de negócio (dimensão), com os prefixos `ft_` e `dm_`:

- **`ft_itens_pedidos` (Fato Principal):** Grão no nível de item de pedido. Chaves para produto, seller, cliente e data de compra. Métricas de preço e frete. Filtrada para pedidos entregues.
- **`ft_avaliacoes` (Fato de Feedback):** Grão de avaliação do pedido. Conecta pelo `order_id` e traz a nota de 1 a 5 e datas de resposta.
- **`dm_calendario` (Dimensão de Tempo):** Tabela diária contínua com colunas de Ano, Mês, Nome do Mês em português, Ano-Mês, Trimestre e Dia da Semana.
- **`dm_produtos` (Dimensão de Produtos):** Cadastro com categorização tratada e tradução (nulos preenchidos com "outros/nao_informado").
- **`dm_sellers` (Dimensão de Lojistas):** ID, CEP, cidade e estado do lojista.
- **`dm_clientes` (Dimensão de Clientes):** ID único, cidade e estado do cliente.

---

## 5. Visualização e Paleta da RZK Digital

Para a visualização, evitei tabelas convencionais e montei visuais dinâmicos no dashboard:
- Cartões com os KPIs principais no topo.
- Gráficos de barras horizontais para categorias e sellers (mais fáceis de ler os nomes longos).
- Série temporal de evolução mês a mês com faturamento e volume no mesmo gráfico.
- Gráfico de rosca para ver a concentração das vendas por estado de origem dos lojistas (SP, PR e MG concentram a maior parte).

Apliquei as cores solicitadas no documento:
- **Azul extra escuro (`#063052`)**: Topo e títulos principais.
- **Azul escuro (`#0C4165`)**: Barras de dados e cartões.
- **Azul regular (`#125379`)**: Barras de volume e gráficos secundários.
- **Azul claro (`#8197AC`)**: Rótulos e textos descritivos.
- **Azul extra claro (`#A8A7B1`)**: Linhas de grade e bordas.
- **Verde regular (`#50C0AE`)**: Destaques positivos e indicadores.

---

## 6. Onde Encontrar os Arquivos

- **Dashboard Interativo Online:** [jhonnybsilva.github.io/desafio-tecnico-rzk/](https://jhonnybsilva.github.io/desafio-tecnico-rzk/)
- **Repositório GitHub:** [github.com/jhonnybsilva/desafio-tecnico-rzk](https://github.com/jhonnybsilva/desafio-tecnico-rzk)
- **Power Query:** `powerbi/power_query_models.m`
- **Medidas DAX:** `powerbi/dax_measures.dax`
- **Tema Power BI:** `powerbi/rzk_digital_theme.json`
- **Tabelas do Modelo (CSVs):** pasta `data_model/`

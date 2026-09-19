// ==============================================================================
// DESAFIO TÉCNICO RZK DIGITAL - MODELAGEM POWER QUERY (M)
// ETL A PARTIR DOS DADOS ORIGINAIS DO DATASET OLIST
// ==============================================================================
// Instrução de uso:
// 1. Crie um Parâmetro no Power BI chamado "CaminhoOrigem" com o caminho da pasta data:
//    Exemplo: "C:\Users\jhonny.brasiliano\.gemini\antigravity\scratch\desafio-rzk-digital\data\"
// 2. Cole o código de cada consulta no Editor Avançado (Advanced Editor).
// ==============================================================================

// ------------------------------------------------------------------------------
// PARÂMETRO: CaminhoOrigem
// ------------------------------------------------------------------------------
"C:\Users\jhonny.brasiliano\.gemini\antigravity\scratch\desafio-rzk-digital\data\" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]


// ------------------------------------------------------------------------------
// TABELA DIMENSÃO: dm_calendario (Gerada 100% no Power Query via M)
// ------------------------------------------------------------------------------
let
    // Define o período com base no intervalo real do dataset (2016 a 2018)
    DataInicial = #date(2016, 1, 1),
    DataFinal = #date(2018, 12, 31),
    TotalDias = Duration.Days(DataFinal - DataInicial) + 1,
    ListaDatas = List.Dates(DataInicial, TotalDias, #duration(1, 0, 0, 0)),
    Tabela = Table.FromList(ListaDatas, Splitter.SplitByNothing(), {"Data"}, null, ExtraValues.Error),
    TipoData = Table.TransformColumnTypes(Tabela, {{"Data", type date}}),
    
    // Adição dos atributos temporais
    Ano = Table.AddColumn(TipoData, "Ano", each Date.Year([Data]), Int64.Type),
    Mes = Table.AddColumn(Ano, "Mes", each Date.Month([Data]), Int64.Type),
    NomeMes = Table.AddColumn(Mes, "Mes_Nome", each Date.MonthName([Data], "pt-BR"), type text),
    AnoMes = Table.AddColumn(NomeMes, "Ano_Mes", each Text.From([Ano]) & "-" & Text.PadStart(Text.From([Mes]), 2, "0"), type text),
    Trimestre = Table.AddColumn(AnoMes, "Trimestre", each Date.QuarterOfYear([Data]), Int64.Type),
    DiaSemana = Table.AddColumn(Trimestre, "Dia_Semana", each Date.DayOfWeekName([Data], "pt-BR"), type text),
    DiaMes = Table.AddColumn(DiaSemana, "Dia_Mes", each Date.Day([Data]), Int64.Type)
in
    DiaMes


// ------------------------------------------------------------------------------
// TABELA DIMENSÃO: dm_produtos (Original olist_products + translation)
// ------------------------------------------------------------------------------
let
    // Carrega produtos originais
    FonteProdutos = Csv.Document(File.Contents(CaminhoOrigem & "olist_products_dataset.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.None]),
    CabecalhosProdutos = Table.PromoteHeaders(FonteProdutos, [PromoteAllScalars=true]),
    TipoProdutos = Table.TransformColumnTypes(CabecalhosProdutos, {
        {"product_id", type text},
        {"product_category_name", type text},
        {"product_name_lenght", Int64.Type},
        {"product_description_lenght", Int64.Type},
        {"product_photos_qty", Int64.Type},
        {"product_weight_g", type number},
        {"product_length_cm", type number},
        {"product_height_cm", type number},
        {"product_width_cm", type number}
    }),
    
    // Carrega tradução original
    FonteTraducao = Csv.Document(File.Contents(CaminhoOrigem & "product_category_name_translation.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.None]),
    CabecalhosTraducao = Table.PromoteHeaders(FonteTraducao, [PromoteAllScalars=true]),
    TipoTraducao = Table.TransformColumnTypes(CabecalhosTraducao, {
        {"product_category_name", type text},
        {"product_category_name_english", type text}
    }),
    
    // Mesclar tradução
    ConsultaMesclada = Table.NestedJoin(TipoProdutos, {"product_category_name"}, TipoTraducao, {"product_category_name"}, "Traducao", JoinKind.LeftOuter),
    TraducaoExpandida = Table.ExpandTableColumn(ConsultaMesclada, "Traducao", {"product_category_name_english"}, {"product_category_name_english"}),
    
    // Tratamento de valores nulos
    TratarNulosPt = Table.ReplaceValue(TraducaoExpandida, null, "outros/nao_informado", Replacer.ReplaceValue, {"product_category_name"}),
    TratarNulosEn = Table.ReplaceValue(TratarNulosPt, null, "other/unspecified", Replacer.ReplaceValue, {"product_category_name_english"})
in
    TratarNulosEn


// ------------------------------------------------------------------------------
// TABELA DIMENSÃO: dm_sellers (Original olist_sellers_dataset.csv)
// ------------------------------------------------------------------------------
let
    Fonte = Csv.Document(File.Contents(CaminhoOrigem & "olist_sellers_dataset.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.None]),
    Cabecalhos = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    TipoAlterado = Table.TransformColumnTypes(Cabecalhos, {
        {"seller_id", type text},
        {"seller_zip_code_prefix", type text},
        {"seller_city", type text},
        {"seller_state", type text}
    }),
    TextoLimpo = Table.TransformColumns(TipoAlterado, {
        {"seller_city", Text.Proper, type text},
        {"seller_state", Text.Upper, type text}
    })
in
    TextoLimpo


// ------------------------------------------------------------------------------
// TABELA DIMENSÃO: dm_clientes (Original olist_customers_dataset.csv)
// ------------------------------------------------------------------------------
let
    Fonte = Csv.Document(File.Contents(CaminhoOrigem & "olist_customers_dataset.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.None]),
    Cabecalhos = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    TipoAlterado = Table.TransformColumnTypes(Cabecalhos, {
        {"customer_id", type text},
        {"customer_unique_id", type text},
        {"customer_zip_code_prefix", type text},
        {"customer_city", type text},
        {"customer_state", type text}
    }),
    TextoLimpo = Table.TransformColumns(TipoAlterado, {
        {"customer_city", Text.Proper, type text},
        {"customer_state", Text.Upper, type text}
    })
in
    TextoLimpo


// ------------------------------------------------------------------------------
// TABELA FATO: ft_itens_pedidos (Original olist_order_items + olist_orders)
// ------------------------------------------------------------------------------
let
    // 1. Carrega itens de pedidos originais
    FonteItens = Csv.Document(File.Contents(CaminhoOrigem & "olist_order_items_dataset.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.None]),
    CabecalhosItens = Table.PromoteHeaders(FonteItens, [PromoteAllScalars=true]),
    TipoItens = Table.TransformColumnTypes(CabecalhosItens, {
        {"order_id", type text},
        {"order_item_id", Int64.Type},
        {"product_id", type text},
        {"seller_id", type text},
        {"shipping_limit_date", type datetime},
        {"price", type number},
        {"freight_value", type number}
    }),
    
    // 2. Carrega pedidos originais
    FontePedidos = Csv.Document(File.Contents(CaminhoOrigem & "olist_orders_dataset.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.None]),
    CabecalhosPedidos = Table.PromoteHeaders(FontePedidos, [PromoteAllScalars=true]),
    TipoPedidos = Table.TransformColumnTypes(CabecalhosPedidos, {
        {"order_id", type text},
        {"customer_id", type text},
        {"order_status", type text},
        {"order_purchase_timestamp", type datetime},
        {"order_delivered_customer_date", type datetime}
    }),
    
    // 3. Mesclar dados do pedido no item
    ItensComPedidos = Table.NestedJoin(TipoItens, {"order_id"}, TipoPedidos, {"order_id"}, "Pedido", JoinKind.Inner),
    PedidoExpandido = Table.ExpandTableColumn(ItensComPedidos, "Pedido", 
        {"customer_id", "order_status", "order_purchase_timestamp"}, 
        {"customer_id", "order_status", "order_purchase_timestamp"}
    ),
    
    // 4. Filtrar apenas pedidos entregues (conforme regra de negócio)
    ApenasEntregues = Table.SelectRows(PedidoExpandido, each ([order_status] = "delivered")),
    
    // 5. Criar chave de data para relacionamento com dm_calendario
    DataCompra = Table.AddColumn(ApenasEntregues, "Data_Compra", each DateTime.Date([order_purchase_timestamp]), type date),
    
    // 6. Tipagem final
    TipoFinal = Table.TransformColumnTypes(DataCompra, {
        {"price", Currency.Type},
        {"freight_value", Currency.Type},
        {"Data_Compra", type date}
    })
in
    TipoFinal


// ------------------------------------------------------------------------------
// TABELA FATO: ft_avaliacoes (Original olist_order_reviews_dataset.csv)
// ------------------------------------------------------------------------------
let
    Fonte = Csv.Document(File.Contents(CaminhoOrigem & "olist_order_reviews_dataset.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.None]),
    Cabecalhos = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    TipoAlterado = Table.TransformColumnTypes(Cabecalhos, {
        {"review_id", type text},
        {"order_id", type text},
        {"review_score", Int64.Type},
        {"review_creation_date", type datetime},
        {"review_answer_timestamp", type datetime}
    }),
    ColunasSelecionadas = Table.SelectColumns(TipoAlterado, {
        "review_id", "order_id", "review_score", "review_creation_date", "review_answer_timestamp"
    }),
    DuplicadasRemovidas = Table.Distinct(ColunasSelecionadas, {"review_id"})
in
    DuplicadasRemovidas

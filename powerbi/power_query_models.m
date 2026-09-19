// ==============================================================================
// DESAFIO TÉCNICO RZK DIGITAL - MODELAGEM POWER QUERY (M)
// ==============================================================================
// Caminho base dos arquivos configurado via parâmetro:
// Parametro "CaminhoDados": "C:\Users\jhonny.brasiliano\.gemini\antigravity\scratch\desafio-rzk-digital\data_model"
// ==============================================================================

// ------------------------------------------------------------------------------
// 1. dm_calendario
// ------------------------------------------------------------------------------
let
    Fonte = Csv.Document(File.Contents("C:\Users\jhonny.brasiliano\.gemini\antigravity\scratch\desafio-rzk-digital\data_model\dm_calendario.csv"), [Delimiter=",", Columns=9, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    CabecalhosPromovidos = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    TipoAlterado = Table.TransformColumnTypes(CabecalhosPromovidos, {
        {"Data", type date},
        {"Ano", Int64.Type},
        {"Mes", Int64.Type},
        {"Mes_Nome", type text},
        {"Ano_Mes", type text},
        {"Trimestre", Int64.Type},
        {"Dia_Semana", type text},
        {"Dia_Mes", Int64.Type},
        {"Semana_Ano", Int64.Type}
    })
in
    TipoAlterado

// ------------------------------------------------------------------------------
// 2. dm_produtos
// ------------------------------------------------------------------------------
let
    Fonte = Csv.Document(File.Contents("C:\Users\jhonny.brasiliano\.gemini\antigravity\scratch\desafio-rzk-digital\data_model\dm_produtos.csv"), [Delimiter=",", Columns=10, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    CabecalhosPromovidos = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    TipoAlterado = Table.TransformColumnTypes(CabecalhosPromovidos, {
        {"product_id", type text},
        {"product_category_name", type text},
        {"product_name_lenght", Int64.Type},
        {"product_description_lenght", Int64.Type},
        {"product_photos_qty", Int64.Type},
        {"product_weight_g", type number},
        {"product_length_cm", type number},
        {"product_height_cm", type number},
        {"product_width_cm", type number},
        {"product_category_name_english", type text}
    }),
    SubstituirNulos = Table.ReplaceValue(TipoAlterado, null, "outros/nao_informado", Replacer.ReplaceValue, {"product_category_name"})
in
    SubstituirNulos

// ------------------------------------------------------------------------------
// 3. dm_sellers
// ------------------------------------------------------------------------------
let
    Fonte = Csv.Document(File.Contents("C:\Users\jhonny.brasiliano\.gemini\antigravity\scratch\desafio-rzk-digital\data_model\dm_sellers.csv"), [Delimiter=",", Columns=4, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    CabecalhosPromovidos = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    TipoAlterado = Table.TransformColumnTypes(CabecalhosPromovidos, {
        {"seller_id", type text},
        {"seller_zip_code_prefix", type text},
        {"seller_city", type text},
        {"seller_state", type text}
    })
in
    TipoAlterado

// ------------------------------------------------------------------------------
// 4. dm_clientes
// ------------------------------------------------------------------------------
let
    Fonte = Csv.Document(File.Contents("C:\Users\jhonny.brasiliano\.gemini\antigravity\scratch\desafio-rzk-digital\data_model\dm_clientes.csv"), [Delimiter=",", Columns=5, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    CabecalhosPromovidos = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    TipoAlterado = Table.TransformColumnTypes(CabecalhosPromovidos, {
        {"customer_id", type text},
        {"customer_unique_id", type text},
        {"customer_zip_code_prefix", type text},
        {"customer_city", type text},
        {"customer_state", type text}
    })
in
    TipoAlterado

// ------------------------------------------------------------------------------
// 5. ft_itens_pedidos
// ------------------------------------------------------------------------------
let
    Fonte = Csv.Document(File.Contents("C:\Users\jhonny.brasiliano\.gemini\antigravity\scratch\desafio-rzk-digital\data_model\ft_itens_pedidos.csv"), [Delimiter=",", Columns=14, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    CabecalhosPromovidos = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    TipoAlterado = Table.TransformColumnTypes(CabecalhosPromovidos, {
        {"order_id", type text},
        {"order_item_id", Int64.Type},
        {"product_id", type text},
        {"seller_id", type text},
        {"shipping_limit_date", type datetime},
        {"price", type number},
        {"freight_value", type number},
        {"customer_id", type text},
        {"order_status", type text},
        {"order_purchase_timestamp", type datetime},
        {"order_approved_at", type datetime},
        {"order_delivered_carrier_date", type datetime},
        {"order_delivered_customer_date", type datetime},
        {"order_estimated_delivery_date", type datetime}
    }),
    DataCompraAdicionada = Table.AddColumn(TipoAlterado, "Data_Compra", each DateTime.Date([order_purchase_timestamp]), type date),
    // Filtragem de pedidos finalizados e válidos para a análise de vendas
    LinhasFiltradas = Table.SelectRows(DataCompraAdicionada, each ([order_status] = "delivered"))
in
    LinhasFiltradas

// ------------------------------------------------------------------------------
// 6. ft_avaliacoes
// ------------------------------------------------------------------------------
let
    Fonte = Csv.Document(File.Contents("C:\Users\jhonny.brasiliano\.gemini\antigravity\scratch\desafio-rzk-digital\data_model\ft_avaliacoes.csv"), [Delimiter=",", Columns=7, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    CabecalhosPromovidos = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    TipoAlterado = Table.TransformColumnTypes(CabecalhosPromovidos, {
        {"review_id", type text},
        {"order_id", type text},
        {"review_score", Int64.Type},
        {"review_comment_title", type text},
        {"review_comment_message", type text},
        {"review_creation_date", type datetime},
        {"review_answer_timestamp", type datetime}
    })
in
    TipoAlterado

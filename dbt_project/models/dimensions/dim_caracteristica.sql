select
    row_number() over (order by tipo_imovel, tipo_construcao, padrao_acabamento, estado_conservacao, tipo_ocupacao)::integer as sk_caracteristica,
    tipo_imovel,
    tipo_construcao,
    padrao_acabamento,
    estado_conservacao,
    tipo_ocupacao
from (
    select distinct tipo_imovel, tipo_construcao, padrao_acabamento, estado_conservacao, tipo_ocupacao
    from {{ ref('stg_itbi_raw') }}
    where tipo_imovel is not null
) sub

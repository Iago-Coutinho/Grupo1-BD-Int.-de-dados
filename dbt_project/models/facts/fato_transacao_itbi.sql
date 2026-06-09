{{ config(
    materialized='table',
    pre_hook="SET LOCAL statement_timeout = 0"
) }}

with src as (
    select * from {{ ref('stg_itbi_raw') }}
),

dim_t as (select * from {{ ref('dim_tempo') }}),
dim_l as (select * from {{ ref('dim_localizacao') }}),
dim_c as (select * from {{ ref('dim_caracteristica') }})

select
    row_number() over ()::integer                          as sk_transacao,
    dim_t.sk_tempo,
    dim_l.sk_localizacao,
    dim_c.sk_caracteristica,
    src.valor_avaliacao,
    src.area_terreno,
    src.area_construida,
    src.fracao_ideal,
    src.sfh,
    case
        when src.area_construida > 0
        then round((src.valor_avaliacao / src.area_construida)::numeric, 2)
        else null
    end                                                    as valor_m2_construido,
    extract(year from src.data_transacao)::integer
        - src.ano_construcao_int                           as idade_imovel_anos
from src
join dim_t on dim_t.data_completa  = src.data_transacao
join dim_l on dim_l.cod_logradouro = src.cod_logradouro
          and dim_l.numero         = src.numero_tratado
join dim_c on dim_c.tipo_imovel        = src.tipo_imovel
          and dim_c.tipo_construcao     = src.tipo_construcao
          and dim_c.padrao_acabamento   = src.padrao_acabamento
          and dim_c.estado_conservacao  = src.estado_conservacao
          and dim_c.tipo_ocupacao       = src.tipo_ocupacao

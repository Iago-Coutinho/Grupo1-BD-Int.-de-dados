select
    row_number() over (order by complemento_numero nulls last, nome_edificio nulls last, ano_construcao_int nulls last)::integer as sk_imovel,
    complemento_numero,
    nome_edificio,
    ano_construcao_int  as ano_construcao,
    decada_construcao
from (
    select distinct complemento_numero, nome_edificio, ano_construcao_int, decada_construcao
    from "postgres"."staging"."stg_itbi_raw"
) sub
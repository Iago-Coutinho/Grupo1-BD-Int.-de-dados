
  
    

  create  table "postgres"."dw_elt"."dim_caracteristica__dbt_tmp"
  
  
    as
  
  (
    select
    row_number() over (order by tipo_imovel, tipo_construcao, padrao_acabamento, estado_conservacao, tipo_ocupacao)::integer as sk_caracteristica,
    tipo_imovel,
    tipo_construcao,
    padrao_acabamento,
    estado_conservacao,
    tipo_ocupacao
from (
    select distinct tipo_imovel, tipo_construcao, padrao_acabamento, estado_conservacao, tipo_ocupacao
    from "postgres"."staging"."stg_itbi_raw"
    where tipo_imovel is not null
) sub
  );
  
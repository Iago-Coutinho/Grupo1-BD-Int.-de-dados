
  
    

  create  table "postgres"."dw_elt"."dim_localizacao__dbt_tmp"
  
  
    as
  
  (
    select
    row_number() over (order by cod_logradouro, numero_tratado)::integer as sk_localizacao,
    cod_logradouro,
    logradouro,
    numero_tratado as numero,
    bairro
from (
    select distinct on (cod_logradouro, numero_tratado)
        cod_logradouro, logradouro, numero_tratado, bairro
    from "postgres"."staging"."stg_itbi_raw"
    where cod_logradouro is not null
    order by cod_logradouro, numero_tratado
) sub
  );
  
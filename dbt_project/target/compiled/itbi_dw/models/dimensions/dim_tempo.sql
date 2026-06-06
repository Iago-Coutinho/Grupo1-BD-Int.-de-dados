select
    row_number() over (order by data_transacao)::integer as sk_tempo,
    data_transacao                                       as data_completa,
    extract(day     from data_transacao)::integer     as dia,
    extract(month   from data_transacao)::integer     as mes,
    to_char(data_transacao, 'TMMonth')                as nome_mes,
    extract(quarter from data_transacao)::integer     as trimestre,
    extract(year    from data_transacao)::integer     as ano,
    extract(isodow  from data_transacao)::integer     as dia_semana,
    to_char(data_transacao, 'TMDay')                  as nome_dia_semana
from (select distinct data_transacao from "postgres"."staging"."stg_itbi_raw" where data_transacao is not null) sub
order by data_transacao
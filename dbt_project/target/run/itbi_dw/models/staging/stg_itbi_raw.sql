
  create view "postgres"."staging"."stg_itbi_raw__dbt_tmp"
    
    
  as (
    with source as (
    select * from staging.itbi_raw
    where logradouro != 'logradouro'
),

tratado as (
    select
        lower(trim(logradouro))           as logradouro,
        upper(trim(numero))               as numero,
        upper(trim(complemento))          as complemento,
        initcap(trim(bairro))             as bairro,
        initcap(trim(estado_conservacao)) as estado_conservacao,
        initcap(trim(tipo_ocupacao))      as tipo_ocupacao,
        initcap(trim(tipo_imovel))        as tipo_imovel,
        trim(tipo_construcao)             as tipo_construcao,
        trim(padrao_acabamento)           as padrao_acabamento,
        trim(cod_logradouro)              as cod_logradouro,
        trim(ano_construcao)              as ano_construcao,
        nullif(trim(numero), '')          as numero_limpo,

        case
            when trim(numero) is null
              or upper(trim(numero)) in ('-1','0','S/N','SEM NUMERO','SEM NÚMERO','NAN','')
            then 'SN'
            else upper(trim(numero))
        end as numero_tratado,

        trim(substring(upper(complemento)
            from '(?i)(?:EDF\.?|ED\.?|EDIFICIO|EDIFÍCIO)\s+([A-Z0-9 ]+)'))
            as nome_edificio,

        trim(regexp_replace(upper(complemento),
            '(?i)(EDF\.?|ED\.?|EDIFICIO|EDIFÍCIO)\s+[^,;]+', '', 'g'))
            as complemento_numero,

        case
            when ano_construcao ~ '^\d{4}$'
            then (nullif(trim(ano_construcao), '')::integer / 10) * 10
            else null
        end as decada_construcao,

        nullif(replace(valor_avaliacao, ',', '.'), '')::numeric  as valor_avaliacao_raw,
        nullif(replace(area_terreno,    ',', '.'), '')::numeric  as area_terreno,
        nullif(replace(area_construida, ',', '.'), '')::numeric  as area_construida,
        nullif(replace(fracao_ideal,    ',', '.'), '')::numeric  as fracao_ideal,
        nullif(replace(sfh,             ',', '.'), '')::numeric  as sfh,
        data_transacao::date                                     as data_transacao,
        nullif(trim(ano_construcao), '')::integer                as ano_construcao_int

    from source
),

-- mediana por bairro excluindo valores irrealistas (< 10000)
mediana_bairro as (
    select
        bairro,
        percentile_cont(0.5) within group (order by valor_avaliacao_raw) as mediana
    from tratado
    where valor_avaliacao_raw >= 10000
    group by bairro
),

-- mediana geral como fallback
mediana_geral as (
    select percentile_cont(0.5) within group (order by valor_avaliacao_raw) as mediana
    from tratado
    where valor_avaliacao_raw >= 10000
)

select
    t.logradouro,
    t.numero,
    t.complemento,
    t.bairro,
    t.estado_conservacao,
    t.tipo_ocupacao,
    t.tipo_imovel,
    t.tipo_construcao,
    t.padrao_acabamento,
    t.cod_logradouro,
    t.ano_construcao,
    t.numero_limpo,
    t.numero_tratado,
    t.nome_edificio,
    t.complemento_numero,
    t.decada_construcao,
    case
        when t.valor_avaliacao_raw < 10000 or t.valor_avaliacao_raw is null
        then coalesce(mb.mediana, mg.mediana)
        else t.valor_avaliacao_raw
    end as valor_avaliacao,
    t.area_terreno,
    t.area_construida,
    t.fracao_ideal,
    t.sfh,
    t.data_transacao,
    t.ano_construcao_int
from tratado t
left join mediana_bairro mb on mb.bairro = t.bairro
cross join mediana_geral mg
  );
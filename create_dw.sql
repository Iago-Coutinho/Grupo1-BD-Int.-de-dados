

CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS dw;


DROP TABLE IF EXISTS staging.itbi_raw CASCADE;

CREATE TABLE staging.itbi_raw (
    logradouro        TEXT,
    numero            TEXT,
    complemento       TEXT,
    valor_avaliacao   TEXT,
    bairro            TEXT,
    cidade            TEXT,
    uf                TEXT,
    ano_construcao    TEXT,
    area_terreno      TEXT,
    area_construida   TEXT,
    fracao_ideal      TEXT,
    padrao_acabamento TEXT,
    tipo_construcao   TEXT,
    tipo_ocupacao     TEXT,
    data_transacao    TEXT,
    estado_conservacao TEXT,
    tipo_imovel       TEXT,
    sfh               TEXT,
    cod_logradouro    TEXT,
    latitude          TEXT,
    longitude         TEXT,
    ano               TEXT,
    distrito          TEXT
);


DROP TABLE IF EXISTS dw.fato_transacao_itbi CASCADE;
DROP TABLE IF EXISTS dw.dim_tempo CASCADE;
DROP TABLE IF EXISTS dw.dim_localizacao CASCADE;
DROP TABLE IF EXISTS dw.dim_imovel CASCADE;
DROP TABLE IF EXISTS dw.dim_caracteristica CASCADE;


CREATE TABLE dw.dim_tempo (
    sk_tempo          SERIAL PRIMARY KEY,
    data_completa     DATE           NOT NULL,
    dia               SMALLINT       NOT NULL,
    mes               SMALLINT       NOT NULL,
    nome_mes          VARCHAR(15)    NOT NULL,
    trimestre         SMALLINT       NOT NULL,
    ano               SMALLINT       NOT NULL,
    dia_semana        SMALLINT       NOT NULL,
    nome_dia_semana   VARCHAR(15)    NOT NULL
);


CREATE TABLE dw.dim_localizacao (
    sk_localizacao    SERIAL PRIMARY KEY,
    cod_logradouro    INTEGER,
    logradouro        VARCHAR(255),
    numero            VARCHAR(20),
    bairro            VARCHAR(100),
);

-- ------------------------------------------------------------
-- dim_imovel
-- ------------------------------------------------------------
CREATE TABLE dw.dim_imovel (
    sk_imovel           SERIAL PRIMARY KEY,
    complemento_numero  VARCHAR(100),
    nome_edificio       VARCHAR(150),
    ano_construcao      SMALLINT,
    decada_construcao   SMALLINT
);

-- ------------------------------------------------------------
-- dim_caracteristica (junction dimension)
-- ------------------------------------------------------------
CREATE TABLE dw.dim_caracteristica (
    sk_caracteristica   SERIAL PRIMARY KEY,
    tipo_imovel         VARCHAR(50),
    tipo_construcao     VARCHAR(50),
    padrao_acabamento   VARCHAR(20),
    estado_conservacao  VARCHAR(20),
    tipo_ocupacao       VARCHAR(50)
);

-- ------------------------------------------------------------
-- fato_transacao_itbi
-- ------------------------------------------------------------
CREATE TABLE dw.fato_transacao_itbi (
    sk_transacao        BIGSERIAL PRIMARY KEY,
    sk_tempo            INTEGER        NOT NULL REFERENCES dw.dim_tempo(sk_tempo),
    sk_localizacao      INTEGER        NOT NULL REFERENCES dw.dim_localizacao(sk_localizacao),
    sk_imovel           INTEGER        NOT NULL REFERENCES dw.dim_imovel(sk_imovel),
    sk_caracteristica   INTEGER        NOT NULL REFERENCES dw.dim_caracteristica(sk_caracteristica),
    valor_avaliacao     NUMERIC(15,2),
    area_terreno        NUMERIC(12,2),
    area_construida     NUMERIC(12,2),
    fracao_ideal        NUMERIC(10,6),
    sfh                 NUMERIC(15,2),
    valor_m2_construido NUMERIC(15,2),
    idade_imovel_anos   INTEGER
);

-- ============================================================
-- Índices para performance analítica
-- ============================================================
CREATE INDEX idx_fato_tempo          ON dw.fato_transacao_itbi(sk_tempo);
CREATE INDEX idx_fato_localizacao    ON dw.fato_transacao_itbi(sk_localizacao);
CREATE INDEX idx_fato_imovel         ON dw.fato_transacao_itbi(sk_imovel);
CREATE INDEX idx_fato_caracteristica ON dw.fato_transacao_itbi(sk_caracteristica);
CREATE INDEX idx_tempo_ano           ON dw.dim_tempo(ano);
CREATE INDEX idx_tempo_mes           ON dw.dim_tempo(mes);
CREATE INDEX idx_loc_bairro          ON dw.dim_localizacao(bairro);
CREATE INDEX idx_loc_distrito        ON dw.dim_localizacao(distrito);

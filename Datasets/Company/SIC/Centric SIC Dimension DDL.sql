create table sic (
  sic_key int NOT NULL
, sic_level int NOT NULL
, sic_code varchar(8) NOT NULL
, sic_desc varchar(200) NOT NULL
, sic_level_01_code varchar(8) NOT NULL
, sic_level_01_desc varchar(200) NOT NULL
, sic_level_02_code varchar(8) NOT NULL
, sic_level_02_desc varchar(200) NOT NULL
, sic_level_03_code varchar(8) NOT NULL
, sic_level_03_desc varchar(200) NOT NULL
, sic_level_04_code varchar(8) NOT NULL
, sic_level_05_desc varchar(200) NOT NULL
, CONSTRAINT sic_pk PRIMARY KEY (sic_key)
);
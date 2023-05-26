
-- psql -h 127.0.0.1 -U postgres -w -f create_tables.sql

CREATE DATABASE "json_scada"
    WITH OWNER "postgres"
    ENCODING 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TEMPLATE template0;

\c json_scada

CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

-- disable timescaledb telemetry
ALTER SYSTEM SET timescaledb.telemetry_level=off;

-- create tables

-- DROP TABLE hist;
CREATE TABLE IF NOT EXISTS hist (
   tag text not null,
   time_tag TIMESTAMPTZ(3),
   value float not null,
   value_json jsonb,
   time_tag_at_source TIMESTAMPTZ(3),
   flags bit(8) not null,
   PRIMARY KEY ( tag, time_tag )
   );
CREATE INDEX ind_timeTag on hist ( time_tag );
CREATE INDEX ind_tagTimeTag on hist ( tag, time_tag_at_source );
comment on table hist is 'Historical data table';
comment on column hist.tag is 'String key for the point';
comment on column hist.value is 'Value as a double';
comment on column hist.time_tag is 'GMT Timestamp for the time data was received by the server';
comment on column hist.time_tag_at_source is 'Field GMT timestamp for the event (null if not available)';
comment on column hist.value_json is 'Structured value as JSON, can be null when do not apply. For digital point it should be the status as in {s:"OFF"}';
comment on column hist.flags is 'Bit mask 0x80=value invalid, 0x40=Time tag at source invalid, 0x20=Analog, 0x10=value recorded by integrity (not by variation)';

-- timescaledb hypertable, partitioned by day
SELECT create_hypertable('hist', 'time_tag', chunk_time_interval=>86400000000);

-- DROP TABLE realtime_data;
CREATE TABLE IF NOT EXISTS realtime_data (
   tag text not null,
   time_tag TIMESTAMPTZ(3) not null,
   json_data jsonb,
   PRIMARY KEY ( tag )
   );

comment on table realtime_data is 'Realtime data and catalog data';
comment on column realtime_data.tag is 'String key for the point';
comment on column realtime_data.time_tag is 'GMT Timestamp for the data update';
comment on column realtime_data.json_data is 'Data image as JSON from Mongodb';
CREATE INDEX ind_tag on realtime_data ( tag );


-- drop view grafana_hist;
create view grafana_hist as
SELECT
  time_tag AS "time",
  tag AS metric,
  value as value,
  time_tag_at_source,
  value_json,
  split_part(tag, '~', 1) as group1,
  split_part(tag, '~', 2) as group2,
  flags
FROM hist;

-- drop view grafana_realtime;
create view grafana_realtime as
select 
tag as metric, 
time_tag as time, 
cast(json_data->>'timeTagAtSource' as timestamp with time zone) as time_tag_at_source,
cast(json_data->>'value' as float) as value, 
cast(json_data->>'_id' as text) as point_key, 
json_data->>'valueString' as value_string, 
cast(json_data->>'invalid' as boolean) as invalid,
cast(json_data->>'alerted' as boolean) as alerted,
cast(json_data->>'alarmed' as boolean) as alarmed,
json_data->>'description' as description, 
json_data->>'group1' as group1,
json_data->>'group2' as group2,
json_data->>'group3' as group3,
json_data->>'ungroupedDescription' as ungrouped_description
from realtime_data;

CREATE OR REPLACE VIEW public.realtime_data_view AS
 SELECT
   rd.tag,
   rd.json_data ->> '_id'::text AS _id,
   rd.json_data ->> 'group1'::text AS group1,
   rd.json_data ->> 'group2'::text AS group2,
   rd.json_data ->> 'group3'::text AS group3,
   rd.json_data ->> 'description'::text AS description,
   rd.json_data ->> 'ungroupedDescription'::text AS ungroupeddescription,

   cast(rd.json_data->>'alarmed' as boolean) as alarmed,
   cast(rd.json_data->>'invalid' as boolean) as invalid,
   cast(rd.json_data->>'frozen' as boolean) as frozen,

   rd.time_tag,
   rd.json_data ->> 'timeTagAtSource' AS time_tag_at_source,
   cast(rd.json_data->>'value' as float) as value,
   rd.json_data->>'valueString' as value_string,
   cast(rd.json_data ->> 'valueJson' as jsonb) as value_json
FROM realtime_data rd;

CREATE OR REPLACE VIEW public.hist_view
AS SELECT hist.tag,
    rd.json_data->>'_id'::text AS _id,
    rd.json_data->>'protocolSourceConnectionNumber' AS protocolSourceConnectionNumber,
    rd.json_data->>'protocolSourceObjectAddress'::text AS protocolSourceObjectAddress,
    rd.json_data->>'description'::text AS description,
    rd.json_data->>'group1'::text AS group1,
    rd.json_data->>'group2'::text AS group2,
    rd.json_data->>'group3'::text AS group3,
    rd.json_data->>'ungroupedDescription'::text AS ungroupeddescription,
    rd.json_data->'location'->'properties'->>'type'::text AS object_type,
    rd.json_data->'location'->'properties'->>'code'::text AS code,
    cast(rd.json_data->'location'->'geometry'->'coordinates'->>0 as numeric) AS longitude,
    cast(rd.json_data->'location'->'geometry'->'coordinates'->>1 as numeric) AS latitude,
    rd.json_data->>'unit'::text AS unit,
    hist.time_tag,
    hist.value,
    hist.value_json ->> 's'::text AS value_string,
    hist.value_json,
    hist.time_tag_at_source,
    hist.flags,
    get_bit(hist.flags, 0) AS invalid, -- b7
    get_bit(hist.flags, 1) AS time_tag_at_source_invalid, -- b6
    get_bit(hist.flags, 2) AS analog, -- b5
    get_bit(hist.flags, 3) AS integrity, -- b4
    get_bit(hist.flags, 4) AS alarmed -- b3 - this one isn't actually set by json_scada's cs_data_processor as it is
   FROM hist
     JOIN realtime_data rd ON hist.tag = rd.tag;

-- In porstgresql create a grafana user just for selects
CREATE USER grafana WITH PASSWORD 'JSGrafana';
GRANT CONNECT ON DATABASE json_scada TO grafana;
GRANT USAGE ON SCHEMA public TO grafana;
GRANT SELECT ON hist TO grafana;
GRANT SELECT ON realtime_data TO grafana;
GRANT SELECT ON grafana_hist TO grafana;
GRANT SELECT ON grafana_realtime TO grafana;
GRANT SELECT ON realtime_data_view TO grafana;
GRANT SELECT ON hist_view TO grafana;

CREATE USER json_scada WITH PASSWORD 'json_scada';
GRANT CONNECT ON DATABASE json_scada TO json_scada;
GRANT all ON realtime_data, hist TO json_scada;

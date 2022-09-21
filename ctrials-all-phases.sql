DROP TABLE ctrials_stats_phases CASCADE;
CREATE TABLE ctrials_stats_phases (
  rank          varchar,
  title         varchar,
  status        varchar,
  studyresults  varchar,
  conditions    varchar,
  interventions varchar,
  sponsorcollaborator varchar,
  phases              varchar,
  n                   varchar,
  start_date          varchar,
  end_date     varchar,
  last_update_posted  varchar,
  locations           varchar,
  nctnumber           varchar
);
--
copy ctrials_stats_phases from '/tmp/inputs.csv'  WITH CSV HEADER;
delete from ctrials_stats_phases where n = 'Enrollment';
update ctrials_stats_phases set end_date = null where end_date='null';
update ctrials_stats_phases set start_date = null where start_date='null';
ALTER TABLE ctrials_stats_phases add column duration_in_years real;

ALTER TABLE ctrials_stats_phases add column enrollment integer;
update ctrials_stats_phases set enrollment = to_number(n, '99999')::integer;

CREATE or REPLACE function ct_duration_years(v_start varchar, v_end varchar) returns float as
$BODY$
      DECLARE
       v_years float;
        w_start date;
        w_end   date;
        j int;
        k int;
      BEGIN
-- Calculate interval in years like 1.5 e.g. from Jan 1, 2022 to June 30, 2023
          IF position(',' IN v_start) >  1 THEN
                w_start = v_start::date;
          END IF;
          IF position(',' IN v_end) >  1  THEN
                w_end = v_end::date;
          END IF;

          IF position(',' IN v_start) = 0  THEN
                w_start = (substring (v_start, 1,  position(' ' IN v_start) )||'1 ,'|| right(v_start, 4))::date;
          END IF;
          IF position(',' IN v_end) = 0  THEN
                w_end =   (substring (v_end, 1,  position(' ' IN v_end) )||'1 ,'|| right(v_end, 4))::date;
          END IF;
          v_years  = (w_end - w_start)::float/365.0;

          return v_years;
      END
$BODY$
 language 'plpgsql';

 update ctrials_stats_phases set duration_in_years = ct_duration_years(start_date,end_date);


   CREATE or REPLACE function ct_grouping(v_number_studies int) returns int as
   $BODY$
         DECLARE
           v_years int;
           j int;
           k int;
         BEGIN
   -- Return a size based on a range of studies performed
             IF v_number_studies >= 25 THEN
                return 1;
                ELSE
                return 2;
             END IF;
         END
   $BODY$
    language 'plpgsql';

--
--
CREATE OR REPLACE VIEW ctrials_leads AS
    select sponsorcollaborator as "Sponsor Name",
    ct_grouping(count(*)::int) AS opportunity_size,
    count(*)::int as "Number of Studies",
    to_char(avg(enrollment),'999999999') as "Average Enrollment",
    to_char(max(enrollment),'999999999') as "Top Enrollment",
    to_char(min(enrollment),'999999999') as "Low Enrollment",
    to_char(max(duration_in_years),'999999999') as "Longest Study",
    to_char(min(duration_in_years),'999999999') as "Shortest Study",
    to_char(avg(duration_in_years),'999999999.99') as "Average Study Duration"
    from ctrials_stats_phases group by sponsorcollaborator;
--

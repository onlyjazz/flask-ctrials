-- 19/9/2022 using new ct format
\c ctrials
DROP TABLE ctrials_ph1 CASCADE;
CREATE TABLE ctrials_ph1 (
      nctnumber     varchar,
      title         varchar,
      status        varchar,
      conditions    varchar,
      interventions varchar,
      sponsor       varchar,
      collaborators varchar,
      studytype     varchar,
      start_date    varchar,
      primary_completion_date   varchar,
      completion_date           varchar
);
copy ctrials_ph1 from '/tmp/ctg-studies.csv'  WITH CSV HEADER;
---delete  from ctrials_ph1 where  right(primary_completion_date,4) < '2022';

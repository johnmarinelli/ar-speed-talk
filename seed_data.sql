-- from http://stackoverflow.com/questions/3970795/how-do-you-create-a-random-string-in-postgresql
-- \c benchmark_talk
CREATE OR REPLACE function random_string(length INTEGER) RETURNS TEXT AS
  $$
  DECLARE
    chars TEXT[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
    result TEXT:= '';
    i INTEGER := 0;
  begin
    if length < 0 then
    raise exception 'Given length cannot be less than 0';
    end if;
    for i in 1..length loop
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  end loop;
    return result;
  end;
  $$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION random_date(start_date VARCHAR, end_date VARCHAR) RETURNS TIMESTAMP AS
  $$
    DECLARE
      ts_start TIMESTAMP:= start_date;
      ts_end TIMESTAMP:= end_date;
    BEGIN
      RETURN ts_start + random() * (ts_end - ts_start);
    END
  $$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION random_email() RETURNS VARCHAR AS
  $$
    BEGIN
      RETURN (random_string(3) || '@' || random_string(4) || '.com');
    END
  $$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION random_location() RETURNS VARCHAR AS
  $$
    BEGIN
      RETURN (string_to_array('california,nevada,new york,oregon,washington', ','))[random_num(0, 4)];
    END
  $$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION random_num(min INTEGER, max INTEGER) RETURNS INTEGER AS
  $$
  BEGIN
    return trunc(random() * max + min);
  END;
  $$ LANGUAGE PLPGSQL;


ALTER SEQUENCE users_id_seq RESTART WITH 1;
ALTER SEQUENCE articles_id_seq RESTART WITH 1;
ALTER SEQUENCE posts_id_seq RESTART WITH 1;
DELETE FROM users;
DELETE FROM articles;
DELETE FROM posts;

DO
$do$
BEGIN
  RAISE NOTICE 'starting users seed...';
  FOR i in 1..2000000 LOOP
    INSERT INTO users 
      (email, first_name, last_name, location, phone_number, created_at, updated_at) 
      VALUES 
      (random_email(), random_string(7), random_string(7), random_location(), random_string(9), random_date('2015-01-01', '2016-01-01'), random_date('2016-01-02', '2016-01-27'))
    IF i % 100000 = 0 THEN
      RAISE NOTICE 'user # %', i;
    END IF;
  END LOOP;
  RAISE NOTICE 'done.';

  RAISE NOTICE 'starting articles seed...';
  FOR i in 1..4000000 LOOP
    INSERT INTO articles
      (user_id, title, body, created_at, updated_at)
      VALUES
      -- 25% of users have made 4 million articles - avg 8 articles each
      (random_num(1, 500000), random_string(7), random_string(20), random_date('2015-01-01', '2016-01-01'), random_date('2016-01-02', '2016-01-27'))

    IF i % 100000 = 0 THEN
      RAISE NOTICE 'article # %', i;
    END IF;
  END LOOP;
  RAISE NOTICE 'done.';

  RAISE NOTICE 'starting posts seed...';
  FOR i in 1..8000000 LOOP
    INSERT INTO posts
      (user_id, article_id, body, created_at, updated_at)
      VALUES
      -- 25% of users have made 8 million posts - avg 16 posts each
      -- across 25% of articles - avg 8 posts per article
      (random_num(1, 500000), random_num(1, 1000000), random_string(20), random_date('2015-01-01', '2016-01-01'), random_date('2016-01-02', '2016-01-27'))

    IF i % 100000 = 0 THEN
      RAISE NOTICE 'post # %', i;
    END IF;
  END LOOP;
  RAISE NOTICE 'done.';
END
$do$ LANGUAGE PLPGSQL;

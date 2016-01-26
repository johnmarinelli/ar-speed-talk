-- from http://stackoverflow.com/questions/3970795/how-do-you-create-a-random-string-in-postgresql
-- \c benchmark_talk
create or replace function random_string(length integer) returns text as 
  $$
  declare
    chars text[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
    result text := '';
    i integer := 0;
  begin
    if length < 0 then
    raise exception 'Given length cannot be less than 0';
    end if;
    for i in 1..length loop
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  end loop;
    return result;
  end;
  $$ language plpgsql;

CREATE OR REPLACE FUNCTION random_email() RETURNS VARCHAR AS
  $$
    BEGIN
      RETURN (random_string(3) || '@' || random_string(4) || '.com')
    END
  $$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION random_location() RETURNS VARCHAR AS
  $$
    BEGIN
      return (string_to_array('california,nevada,new york,oregon,washington', ','))[random_num(4)];
    END
  $$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION random_num(max INTEGER) RETURNS INTEGER AS
  $$
  BEGIN
    return trunc(random() * max);
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
  FOR i in 1..100 LOOP
    INSERT INTO users 
      (email, first_name, last_name, location, phone_number) 
      VALUES 
      ();
  END LOOP;
END
$do$;

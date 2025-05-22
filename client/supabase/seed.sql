-- seed_test_data.sql

-- 0) enable extensions
create extension if not exists postgis;
create extension if not exists pgcrypto;

-- 1) create 10 test users; trigger handle_new_user()
DO $$
DECLARE
  i      integer;
  u      uuid;
  uname  text;
BEGIN
  FOR i IN 1..10 LOOP
    u := gen_random_uuid();
    uname := format('testuser%s', i);

    INSERT INTO auth.users
      (id, aud, role, email, email_confirmed_at, raw_user_meta_data)
    VALUES
      (
        u,
        'authenticated',
        'authenticated',
        format('testuser%s@example.com', i),
        now(),
        -- supply the username so trigger can populate profiles.username
        jsonb_build_object('username', uname)
      );
  END LOOP;
END
$$;


-- 2) generate 100 random events in Canton Zürich
DO $$
DECLARE
  i           integer;
  owner_uuid  uuid;
  lat         double precision;
  lon         double precision;
  start_ts    timestamp with time zone;
  end_ts      timestamp with time zone;
BEGIN
  FOR i IN 1..100 LOOP
    -- pick a random user
    SELECT id INTO owner_uuid
      FROM auth.users
     ORDER BY random()
     LIMIT 1;

    -- random coords in approx Canton Zürich
    lon := 8.4  + random() * (8.7 - 8.4);
    lat := 47.2 + random() * (47.6 - 47.2);

    -- random start within next 1 day
    start_ts := now() + (random()|| ' days')::interval;
    -- random duration 1–5h
    end_ts   := start_ts + ((random() * 4 + 1) || ' hours')::interval;

    INSERT INTO public.events
      ( title
      , description
      , location
      , start
      , "end"
      , slot_limit
      , slots_taken
      , age_restricted
      , chat_enabled
      , user_id
      )
    VALUES
      ( format('Test Event %s', i)
      , format('This is test event %s in Canton Zürich.', i)
      , ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography
      , start_ts
      , end_ts
      , floor(random() * 10 + 2)::int    -- 2–10 slots
      , 0
      , false
      , true
      , owner_uuid
      );
  END LOOP;
END
$$;

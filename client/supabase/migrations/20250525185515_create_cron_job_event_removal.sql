-- ===========================================
-- Migration:     create_clean_expired_events_cron
-- Description:   Adds a scheduled job that deletes old events every 4 hours
-- ===========================================
create extension if not exists pg_cron with schema extensions;

create or replace function public.clean_expired_events()
returns void
language sql
as $$
    delete from events
    where "end" < now() - interval '24 hours';
$$;

select cron.schedule(
  'clean-expired-events',                     
  '0 */4 * * *',                              
  $$ select public.clean_expired_events(); $$ 
);
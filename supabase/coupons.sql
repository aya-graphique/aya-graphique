-- Aya's Graphique — discount codes (coupons)
-- Run this once in the Supabase SQL editor. Safe to re-run.
--
-- How it works:
--   * The admin dashboard (signed in) creates/edits/deletes codes in `coupons`.
--   * The storefront can NOT read that table (so codes can't be listed/leaked).
--     It only calls two functions below, which run on the server:
--       validate_coupon(code, subtotal) -> checks a code and returns the discount
--       redeem_coupon(code, subtotal)   -> same check, then atomically counts one use
--   * The discount is always calculated here in Postgres, never trusted
--     from the app.

create extension if not exists "pgcrypto";

create table if not exists coupons (
  id             uuid primary key default gen_random_uuid(),
  code           text not null unique,
  discount_type  text not null check (discount_type in ('percent', 'fixed')),
  discount_value numeric(10, 2) not null check (discount_value > 0),
  -- Minimum cart subtotal (EGP) needed for the code to work. 0 = no minimum.
  min_order      numeric(10, 2) not null default 0 check (min_order >= 0),
  -- Cap on the discount (EGP) for percent codes. NULL = no cap.
  max_discount   numeric(10, 2) check (max_discount is null or max_discount > 0),
  -- Total uses allowed. NULL = unlimited.
  max_uses       integer check (max_uses is null or max_uses > 0),
  used_count     integer not null default 0,
  start_date     date,
  end_date       date,
  is_active      boolean not null default true,
  created_at     timestamptz not null default now(),
  constraint coupons_percent_range check (discount_type <> 'percent' or discount_value <= 100),
  constraint coupons_date_order check (start_date is null or end_date is null or end_date >= start_date)
);

-- Codes are always stored trimmed + UPPERCASE, so "ramadan20" and
-- "RAMADAN20" are the same code (and the unique constraint catches dupes).
create or replace function coupons_normalize_code()
returns trigger
language plpgsql
as $$
begin
  new.code := upper(trim(new.code));
  return new;
end;
$$;

drop trigger if exists coupons_normalize_code_trg on coupons;
create trigger coupons_normalize_code_trg
  before insert or update on coupons
  for each row execute function coupons_normalize_code();

alter table coupons enable row level security;

drop policy if exists "Authenticated read coupons" on coupons;
create policy "Authenticated read coupons"
  on coupons for select using (auth.role() = 'authenticated');

drop policy if exists "Authenticated insert coupons" on coupons;
create policy "Authenticated insert coupons"
  on coupons for insert with check (auth.role() = 'authenticated');

drop policy if exists "Authenticated update coupons" on coupons;
create policy "Authenticated update coupons"
  on coupons for update using (auth.role() = 'authenticated');

drop policy if exists "Authenticated delete coupons" on coupons;
create policy "Authenticated delete coupons"
  on coupons for delete using (auth.role() = 'authenticated');

-- What the order remembers about the code that was used.
alter table orders add column if not exists coupon_code text not null default '';
alter table orders add column if not exists discount_amount numeric(10, 2) not null default 0;

-- Checks a code against a cart subtotal. Never changes anything.
-- Returns jsonb:
--   { valid: true,  code, type, value, min_order, max_discount, discount }
--   { valid: false, reason: not_found | inactive | not_started | expired
--                           | exhausted | min_order, min_order? }
create or replace function validate_coupon(p_code text, p_subtotal numeric)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  c     coupons;
  today date := (now() at time zone 'Africa/Cairo')::date;
  d     numeric;
begin
  select * into c from coupons where code = upper(trim(coalesce(p_code, '')));

  if not found then
    return jsonb_build_object('valid', false, 'reason', 'not_found');
  end if;
  if not c.is_active then
    return jsonb_build_object('valid', false, 'reason', 'inactive');
  end if;
  if c.start_date is not null and today < c.start_date then
    return jsonb_build_object('valid', false, 'reason', 'not_started');
  end if;
  if c.end_date is not null and today > c.end_date then
    return jsonb_build_object('valid', false, 'reason', 'expired');
  end if;
  if c.max_uses is not null and c.used_count >= c.max_uses then
    return jsonb_build_object('valid', false, 'reason', 'exhausted');
  end if;
  if coalesce(p_subtotal, 0) < c.min_order then
    return jsonb_build_object('valid', false, 'reason', 'min_order', 'min_order', c.min_order);
  end if;

  if c.discount_type = 'percent' then
    d := round(p_subtotal * c.discount_value / 100, 2);
    if c.max_discount is not null then
      d := least(d, c.max_discount);
    end if;
  else
    d := c.discount_value;
  end if;
  d := greatest(0, least(d, p_subtotal));  -- never more than the cart is worth

  return jsonb_build_object(
    'valid', true,
    'code', c.code,
    'type', c.discount_type,
    'value', c.discount_value,
    'min_order', c.min_order,
    'max_discount', c.max_discount,
    'discount', d
  );
end;
$$;

-- Same checks, then counts one use. Called once, when the order is placed
-- (NOT when the shopper merely tries a code). The row lock makes two
-- simultaneous checkouts unable to both take the last remaining use.
create or replace function redeem_coupon(p_code text, p_subtotal numeric)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  result jsonb;
begin
  perform 1 from coupons where code = upper(trim(coalesce(p_code, ''))) for update;

  result := validate_coupon(p_code, p_subtotal);

  if (result->>'valid')::boolean then
    update coupons
       set used_count = used_count + 1
     where code = upper(trim(p_code));
  end if;

  return result;
end;
$$;

grant execute on function validate_coupon(text, numeric) to anon, authenticated;
grant execute on function redeem_coupon(text, numeric) to anon, authenticated;

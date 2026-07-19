-- Carnet — Supabase schema
-- Run this in the Supabase SQL editor for a fresh project.

create extension if not exists "pgcrypto";

create table if not exists products (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  description text not null default '',
  price       numeric(10, 2) not null check (price >= 0),
  -- Free text, not a fixed list: the admin dashboard lets you create new
  -- categories on the fly, so there's no check constraint here.
  category    text not null,
  image_url   text not null default '',
  tags        text[] not null default '{}',
  rating      numeric(2, 1) not null default 4.8,
  stock       integer not null default 0,
  sort_order  integer not null default 0,
  -- Running total of units actually sold, summed from every order line
  -- ever placed for this product. Only ever changed by the
  -- increment_product_sales() function below (called at checkout) — never
  -- set from the admin dashboard. Powers the storefront's "Best sellers"
  -- section.
  sales_count integer not null default 0,
  -- Owner-set discount percentage (0–100). 0 means no discount. Everywhere
  -- the app shows or charges a price, it's `price` minus this percentage —
  -- see `Product.discountedPrice` in the app.
  discount_percent numeric(5, 2) not null default 0 check (discount_percent >= 0 and discount_percent <= 100),
  created_at  timestamptz not null default now()
);

-- Safe to re-run on a database that already has products from before this
-- column existed — existing rows all default to 0 (no discount).
alter table products add column if not exists discount_percent numeric(5, 2) not null default 0;

-- Safe to re-run on a database created before this column existed.
alter table products add column if not exists sales_count integer not null default 0;

alter table products enable row level security;

-- Remembers category names that have been used before, so the admin
-- dashboard can offer them in a dropdown instead of retyping. Adding a
-- brand new category is just typing a new name — this table doesn't gate
-- what `products.category` can contain, it just powers the dropdown.
-- `image_url` is optional: the owner can set a specific thumbnail for a
-- category from the dashboard; if left blank, the storefront falls back
-- to that category's first product photo instead.
create table if not exists categories (
  id          uuid primary key default gen_random_uuid(),
  name        text not null unique,
  image_url   text not null default '',
  created_at  timestamptz not null default now()
);

-- Migrating an existing database created before `image_url` existed?
-- Uncomment and run this once:
-- alter table categories add column if not exists image_url text not null default '';

alter table categories enable row level security;

create policy "Public read access to categories"
  on categories for select
  using (true);

create policy "Authenticated write access to categories"
  on categories for insert
  with check (auth.role() = 'authenticated');

-- Lets the admin dashboard set/replace a category's thumbnail image.
create policy "Authenticated update access to categories"
  on categories for update
  using (auth.role() = 'authenticated');

-- Lets the admin dashboard remove a category name from the dropdown list.
-- Existing products keep their category text either way (it's free text).
create policy "Authenticated delete access to categories"
  on categories for delete
  using (auth.role() = 'authenticated');

-- Anyone can read the catalog.
create policy "Public read access"
  on products for select
  using (true);

-- Only authenticated users (i.e. you, via the admin dashboard) can write.
create policy "Authenticated write access"
  on products for insert
  with check (auth.role() = 'authenticated');

create policy "Authenticated update access"
  on products for update
  using (auth.role() = 'authenticated');

create policy "Authenticated delete access"
  on products for delete
  using (auth.role() = 'authenticated');

-- Optional: orders + order_items, ready for when you wire up checkout to
-- write real orders instead of the simulated confirmation in the app.
create table if not exists orders (
  id             uuid primary key default gen_random_uuid(),
  full_name      text not null,
  email          text not null,
  address        text not null,
  phone_1        text not null default '',
  phone_2        text not null default '',
  payment_method text not null default 'cod',
  -- The customer-entered InstaPay name or Vodafone Cash number they paid
  -- from, so the owner can confirm the transfer without needing a
  -- screenshot. Empty for cash on delivery.
  payment_sender_info text not null default '',
  -- Marked true once the owner has fulfilled/shipped the order. Drives the
  -- "Mark done" toggle and the red pending-orders badge in the admin
  -- dashboard.
  is_completed   boolean not null default false,
  subtotal       numeric(10, 2) not null,
  shipping       numeric(10, 2) not null,
  total          numeric(10, 2) not null,
  created_at     timestamptz not null default now()
);

-- Safe to re-run on a database created before these columns existed.
alter table orders add column if not exists phone_1 text not null default '';
alter table orders add column if not exists phone_2 text not null default '';
alter table orders add column if not exists payment_method text not null default 'cod';
alter table orders add column if not exists payment_sender_info text not null default '';
alter table orders add column if not exists is_completed boolean not null default false;

create table if not exists order_items (
  id          uuid primary key default gen_random_uuid(),
  order_id    uuid not null references orders (id) on delete cascade,
  product_id  uuid references products (id) on delete set null,
  product_name text not null,
  unit_price  numeric(10, 2) not null,
  quantity    integer not null check (quantity > 0)
);

-- Postgres does NOT automatically index foreign key columns (only primary
-- keys get that). Without this, deleting an order has to full-scan
-- order_items to find the rows to cascade-delete, and AdminOrdersScreen's
-- `select('*, order_items(*)')` join has to full-scan it too — both get
-- slower as order_items grows. Safe to re-run on an existing project.
create index if not exists order_items_order_id_idx on order_items (order_id);

-- Atomically bumps products.sales_count for everything in an order, called
-- once from the checkout flow right after order_items is written (see
-- OrdersRepository._incrementSalesCounts in the app). `items` looks like
-- [{"product_id": "...", "quantity": 2}, ...]. security definer + the grant
-- below is what lets the public checkout flow (not signed in) call this
-- despite products only being publicly *readable*, not writable, per the
-- RLS policies further down.
create or replace function increment_product_sales(items jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update products p
  set sales_count = sales_count + (i->>'quantity')::int
  from jsonb_array_elements(items) as i
  where p.id = (i->>'product_id')::uuid;
end;
$$;

grant execute on function increment_product_sales(jsonb) to anon, authenticated;

alter table orders enable row level security;
alter table order_items enable row level security;

-- Storefront can create orders (checkout), but not read/list other people's.
create policy "Anyone can place an order"
  on orders for insert
  with check (true);

create policy "Anyone can add order items"
  on order_items for insert
  with check (true);

-- Only you (authenticated) can read orders in the admin dashboard.
create policy "Authenticated can read orders"
  on orders for select
  using (auth.role() = 'authenticated');

create policy "Authenticated can read order items"
  on order_items for select
  using (auth.role() = 'authenticated');

-- Lets the admin dashboard toggle an order's "done" status.
create policy "Authenticated can update orders"
  on orders for update
  using (auth.role() = 'authenticated');

-- Lets the admin dashboard permanently remove an order (e.g. once it's
-- completed and no longer needs to clutter the list). order_items rows for
-- it are removed automatically via the "on delete cascade" on their
-- order_id foreign key above.
create policy "Authenticated can delete orders"
  on orders for delete
  using (auth.role() = 'authenticated');

-- Single-row table for store-wide settings the admin can change from the
-- dashboard instead of editing code — currently just the flat shipping fee
-- (in EGP), shown at checkout.
create table if not exists store_settings (
  id                  integer primary key default 1,
  shipping_cost       numeric(10, 2) not null default 50,
  notification_email  text,
  -- Owner's WhatsApp number in international format, no "+" and no spaces
  -- (e.g. Egyptian 010xxxxxxxx -> "201xxxxxxxxx"). Used to build the
  -- wa.me link the checkout screen opens so the customer's order lands
  -- straight in the owner's WhatsApp as a pre-filled message.
  owner_whatsapp      text,
  -- Vodafone Cash number the checkout screen opens the customer's Contacts
  -- app with, pre-filled, when they pick "Vodafone Cash" instead of cash
  -- on delivery.
  payment_number      text,
  -- InstaPay payment link (e.g. an ipn.eg transfer link) the checkout
  -- screen opens directly when the customer picks "InstaPay".
  instapay_link       text,
  constraint store_settings_singleton check (id = 1)
);

insert into store_settings (id, shipping_cost)
values (1, 50)
on conflict (id) do nothing;

-- Safe to re-run on a database created before these columns existed.
alter table store_settings add column if not exists owner_whatsapp text;
alter table store_settings add column if not exists payment_number text;
alter table store_settings add column if not exists instapay_link text;

alter table store_settings enable row level security;

-- Storefront needs to read the shipping fee to show it in the cart/checkout.
create policy "Public read access to store settings"
  on store_settings for select
  using (true);

-- Only the signed-in admin can change it.
create policy "Authenticated update of store settings"
  on store_settings for update
  using (auth.role() = 'authenticated');

create policy "Authenticated insert of store settings"
  on store_settings for insert
  with check (auth.role() = 'authenticated');

-- Storage bucket the admin dashboard uploads product photos to. Public to
-- read (so photos show up on the storefront), writable only when signed in.
insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do nothing;

create policy "Public read access to product images"
  on storage.objects for select
  using (bucket_id = 'product-images');

create policy "Authenticated upload of product images"
  on storage.objects for insert
  with check (bucket_id = 'product-images' and auth.role() = 'authenticated');

create policy "Authenticated update of product images"
  on storage.objects for update
  using (bucket_id = 'product-images' and auth.role() = 'authenticated');

create policy "Authenticated delete of product images"
  on storage.objects for delete
  using (bucket_id = 'product-images' and auth.role() = 'authenticated');

-- "Who am I" page — a single-row bio/portfolio profile the owner fills in
-- from the admin dashboard so they can send the page as part of a proposal
-- when pitching for other design work. Singleton table, same pattern as
-- `store_settings` above.
create table if not exists about_me (
  id             integer primary key default 1,
  full_name      text not null default '',
  headline       text not null default '',
  bio            text not null default '',
  -- Short skill/service tags, e.g. "Branding", "Print design", "Packaging"
  -- — shown as chips on the page.
  skills         text[] not null default '{}',
  email          text not null default '',
  phone          text not null default '',
  whatsapp       text not null default '',
  location       text not null default '',
  portfolio_url  text not null default '',
  cv_url         text not null default '',
  constraint about_me_singleton check (id = 1)
);

insert into about_me (id) values (1) on conflict (id) do nothing;

-- Arabic versions of the bio content, added later. Nullable/empty by
-- default and additive (existing rows are untouched) so this is safe to
-- run against a database that already has data — the app falls back to
-- the English (original) columns whenever these are blank.
alter table about_me add column if not exists headline_ar text not null default '';
alter table about_me add column if not exists bio_ar text not null default '';
alter table about_me add column if not exists skills_ar text[] not null default '{}';

-- Extra social/contact links for the "Get in touch" section, added later.
-- Optional and additive, same as the *_ar columns above — leave any of
-- them blank in the admin dashboard and that button just doesn't show up
-- on the storefront.
alter table about_me add column if not exists instagram_url text not null default '';
alter table about_me add column if not exists facebook_url text not null default '';
alter table about_me add column if not exists tiktok_url text not null default '';
alter table about_me add column if not exists linkedin_url text not null default '';

alter table about_me enable row level security;

create policy "Public read access to about_me"
  on about_me for select
  using (true);

create policy "Authenticated update of about_me"
  on about_me for update
  using (auth.role() = 'authenticated');

create policy "Authenticated insert of about_me"
  on about_me for insert
  with check (auth.role() = 'authenticated');

-- The slideshow of photos shown at the top of the "Who am I" page. The
-- owner uploads/removes/reorders these from the admin dashboard.
create table if not exists about_slides (
  id          uuid primary key default gen_random_uuid(),
  image_url   text not null,
  sort_order  integer not null default 0,
  created_at  timestamptz not null default now()
);

alter table about_slides enable row level security;

create policy "Public read access to about_slides"
  on about_slides for select
  using (true);

create policy "Authenticated write access to about_slides"
  on about_slides for insert
  with check (auth.role() = 'authenticated');

create policy "Authenticated update access to about_slides"
  on about_slides for update
  using (auth.role() = 'authenticated');

create policy "Authenticated delete access to about_slides"
  on about_slides for delete
  using (auth.role() = 'authenticated');

-- Storage bucket for the "Who am I" slideshow photos. Public to read (so
-- the photos show up on the page), writable only when signed in.
insert into storage.buckets (id, name, public)
values ('about-images', 'about-images', true)
on conflict (id) do nothing;

create policy "Public read access to about images"
  on storage.objects for select
  using (bucket_id = 'about-images');

create policy "Authenticated upload of about images"
  on storage.objects for insert
  with check (bucket_id = 'about-images' and auth.role() = 'authenticated');

create policy "Authenticated update of about images"
  on storage.objects for update
  using (bucket_id = 'about-images' and auth.role() = 'authenticated');

create policy "Authenticated delete of about images"
  on storage.objects for delete
  using (bucket_id = 'about-images' and auth.role() = 'authenticated');

-- The promotional banner strip shown near the top of the Home page (free
-- shipping offers, seasonal promos, new drops). Same shape and same
-- owner-managed pattern as `about_slides`.
create table if not exists home_banners (
  id          uuid primary key default gen_random_uuid(),
  image_url   text not null,
  sort_order  integer not null default 0,
  -- Which strip this slide belongs to: 'hero' (top of Home) or
  -- 'most_ordered' (the strip right above the "MOST ORDERED" section).
  placement   text not null default 'hero',
  created_at  timestamptz not null default now()
);

-- Safe to re-run on a database that already has home_banners from before
-- this column existed — existing rows all become 'hero' slides, which is
-- exactly what they were before this change.
alter table home_banners add column if not exists placement text not null default 'hero';

alter table home_banners enable row level security;

create policy "Public read access to home_banners"
  on home_banners for select
  using (true);

create policy "Authenticated write access to home_banners"
  on home_banners for insert
  with check (auth.role() = 'authenticated');

create policy "Authenticated update access to home_banners"
  on home_banners for update
  using (auth.role() = 'authenticated');

create policy "Authenticated delete access to home_banners"
  on home_banners for delete
  using (auth.role() = 'authenticated');

-- Storage bucket for the Home page banner photos. Public to read (so the
-- photos show up on the storefront), writable only when signed in.
insert into storage.buckets (id, name, public)
values ('home-banner-images', 'home-banner-images', true)
on conflict (id) do nothing;

create policy "Public read access to home banner images"
  on storage.objects for select
  using (bucket_id = 'home-banner-images');

create policy "Authenticated upload of home banner images"
  on storage.objects for insert
  with check (bucket_id = 'home-banner-images' and auth.role() = 'authenticated');

create policy "Authenticated update of home banner images"
  on storage.objects for update
  using (bucket_id = 'home-banner-images' and auth.role() = 'authenticated');

create policy "Authenticated delete of home banner images"
  on storage.objects for delete
  using (bucket_id = 'home-banner-images' and auth.role() = 'authenticated');

-- Owner-editable text/pricing for the "Services" page. The categories and
-- items themselves stay fixed in the app's code (kServiceCategories) — this
-- table only stores per-item overrides, keyed by "<categoryIndex>-<itemIndex>"
-- (stable since the list of categories/items never changes). Any field left
-- blank means "keep showing the original hardcoded copy" — see
-- lib/screens/graphical_services_screen.dart's applyServiceOverride().
create table if not exists service_content (
  item_key        text primary key,
  title           text not null default '',
  title_ar        text not null default '',
  subtitle        text not null default '',
  subtitle_ar     text not null default '',
  description     text not null default '',
  description_ar  text not null default '',
  highlights      text[] not null default '{}',
  highlights_ar   text[] not null default '{}',
  price_lines     text[] not null default '{}',
  price_lines_ar  text[] not null default '{}',
  note            text not null default '',
  note_ar         text not null default '',
  updated_at      timestamptz not null default now()
);

alter table service_content enable row level security;

-- Storefront needs to read overrides to show them on the Services page.
create policy "Public read access to service_content"
  on service_content for select
  using (true);

create policy "Authenticated write access to service_content"
  on service_content for insert
  with check (auth.role() = 'authenticated');

create policy "Authenticated update access to service_content"
  on service_content for update
  using (auth.role() = 'authenticated');

-- Lets the admin dashboard's "Reset to default" button clear an override.
create policy "Authenticated delete access to service_content"
  on service_content for delete
  using (auth.role() = 'authenticated');

-- Owner-uploaded thumbnail for each of the three fixed service categories
-- (Mentoring / Designing / Private Workshop), shown on the storefront's
-- category-circles row on Home instead of the generic icon. Keyed by the
-- category's fixed index in kServiceCategories (0, 1, 2) — one row per
-- category, same stable-key idea as service_content above but per
-- category instead of per item. No row (or a blank image_url) just means
-- "keep showing the icon" — see ServiceCategoriesRepository /
-- HomeScreen's _CategoryCircles.
create table if not exists service_category_images (
  category_index integer primary key,
  image_url      text not null default '',
  updated_at     timestamptz not null default now()
);

alter table service_category_images enable row level security;

-- Storefront needs to read these to show them on the Home page circles.
create policy "Public read access to service_category_images"
  on service_category_images for select
  using (true);

create policy "Authenticated write access to service_category_images"
  on service_category_images for insert
  with check (auth.role() = 'authenticated');

create policy "Authenticated update access to service_category_images"
  on service_category_images for update
  using (auth.role() = 'authenticated');

-- The owner-managed "Illustration & Art" circles row on the Home page —
-- unlike the fixed 3-item Services row above, this is a fully open-ended
-- list the owner adds/edits/deletes/reorders from the admin dashboard.
-- Same shape and pattern as `home_banners`, just with a bilingual title
-- alongside each photo.
create table if not exists illustration_art_items (
  id          uuid primary key default gen_random_uuid(),
  title       text not null default '',
  title_ar    text not null default '',
  image_url   text not null,
  sort_order  integer not null default 0,
  created_at  timestamptz not null default now()
);

alter table illustration_art_items enable row level security;

create policy "Public read access to illustration_art_items"
  on illustration_art_items for select
  using (true);

create policy "Authenticated write access to illustration_art_items"
  on illustration_art_items for insert
  with check (auth.role() = 'authenticated');

create policy "Authenticated update access to illustration_art_items"
  on illustration_art_items for update
  using (auth.role() = 'authenticated');

create policy "Authenticated delete access to illustration_art_items"
  on illustration_art_items for delete
  using (auth.role() = 'authenticated');

-- Customer-submitted testimonials shown in the "What people say" section on
-- the Home page. Anyone (not signed in) can submit one from the storefront,
-- but it stays hidden from the public until the owner approves it from the
-- admin dashboard — same moderation-gate idea as `is_completed` on orders,
-- just named for what it does here.
create table if not exists testimonials (
  id           uuid primary key default gen_random_uuid(),
  name         text not null,
  quote        text not null,
  rating       integer not null default 5 check (rating >= 1 and rating <= 5),
  is_approved  boolean not null default false,
  created_at   timestamptz not null default now()
);

alter table testimonials enable row level security;

-- Storefront only ever needs approved testimonials for the public section.
create policy "Public read access to approved testimonials"
  on testimonials for select
  using (is_approved = true);

-- Anyone can submit a testimonial from the storefront, but it can only ever
-- be inserted as unapproved — a submitter can't mark their own review
-- approved by tampering with the request.
create policy "Anyone can submit a testimonial"
  on testimonials for insert
  with check (is_approved = false);

-- Only you (authenticated) can see pending + approved testimonials together,
-- e.g. in the admin moderation screen.
create policy "Authenticated can read all testimonials"
  on testimonials for select
  using (auth.role() = 'authenticated');

-- Lets the admin dashboard approve/unapprove a testimonial.
create policy "Authenticated can update testimonials"
  on testimonials for update
  using (auth.role() = 'authenticated');

-- Lets the admin dashboard delete spam/unwanted testimonials.
create policy "Authenticated can delete testimonials"
  on testimonials for delete
  using (auth.role() = 'authenticated');

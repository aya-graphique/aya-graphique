# Carnet — Notebooks & Stationery (Flutter Web)

A dark, gallery-style e-commerce app for notebooks and stationery, built
entirely in Dart/Flutter. It reuses the exact design system — colors,
fonts, and animations — from the Aya's Graphique brand: the same
aubergine/violet/orchid palette, the same Bricolage Grotesque / Plus
Jakarta Sans / Space Grotesk type trio, the same ambient animated
backdrop, 3D tilt cards, and scroll-reveal motion.

## What's inside

- **Home** — shimmering hero headline, scrolling category marquee,
  category filter chips, and a responsive product grid.
- **Product detail** — tilting hero image, quantity stepper, tags,
  add-to-cart.
- **Search** — live text search plus category and price filters.
- **Cart & checkout** — quantity steppers, order summary, a shipping form,
  and a simulated order-confirmation flow.
- Same **ambient animated background**, **glass nav bar** (now with
  Shop/Search/Cart tabs and a live cart badge), **3D tilt cards**,
  and **scroll-reveal** entrances as the source project.

## Fonts

Loaded at runtime via `google_fonts` — no manual font files:

- **Poppins** — used for all Latin text (headlines, body, labels).
- **Cairo** — used automatically for any Arabic text (product names,
  descriptions, categories, tags, etc. typed by the store owner). Cairo is
  the closest free/open equivalent to the commercial "Bahij TheSansArabic"
  look, since Bahij's fonts aren't available for redistribution.
- Visitors can also force the whole storefront into the Arabic typeface
  from the 🌐 icon in the nav bar (next to the light/dark toggle) — this
  overrides the automatic per-string detection.

## Color palette

Identical tokens to the Aya's Graphique brand system (see
`lib/theme/app_theme.dart`): deep aubergine background (`#0D0512`), brand
violets (`#2C1240` → `#5C3578`), electric orchid accent (`#9B3FD1`,
`#C183EE`), and near-white lilac text (`#F6EFFB`).

## Light / dark mode

The app ships with both a dark palette (the original moody aubergine look)
and a bright paper-like light palette — same brand purples, inverted
surfaces and text. People can switch with the sun/moon icon in the nav bar;
the choice is saved locally (via `shared_preferences`) so it's remembered
next launch. Everything is driven by `ThemeController` in
`lib/theme/app_theme.dart` — any widget reads the current palette with
`context.colors` instead of a hardcoded `AppColors.xxx`, so it repaints
automatically when the mode changes.

## Running it

1. Install Flutter (3.22+): https://docs.flutter.dev/get-started/install
2. This folder ships with `pubspec.yaml`, `lib/`, and `supabase/` only —
   generate the platform scaffolding once:
   ```bash
   cd carnet
   flutter create .
   flutter pub get
   flutter run -d chrome
   ```
3. To build a deployable static site:
   ```bash
   flutter build web --release
   ```
   The output lands in `build/web/` — upload it to any static host
   (Netlify, Vercel, Firebase Hosting, GitHub Pages, etc.).

### Deploying to GitHub Pages

If your repo is `github.com/you/carnet` and you're using a **project
page** (i.e. the site serves from `you.github.io/carnet/`, not a custom
domain or a `you.github.io` user/org page), build with `--base-href` set
to your repo name so assets resolve correctly:

```bash
flutter build web --release --base-href /carnet/
```

Then push the contents of `build/web/` to your `gh-pages` branch (or the
`/docs` folder on `main`, whichever you've set Pages to serve from).

Flutter web uses **hash-based URLs by default** (no extra config
needed), so once it's live:

- `https://you.github.io/carnet/#/` — the storefront
- `https://you.github.io/carnet/#/admin` — jumps straight to the admin
  login, skipping the storefront entirely. Bookmark this one for
  yourself.

Both routes are wired up in `lib/main.dart`.

## Product catalog + Supabase backend

The catalog is backed by [Supabase](https://supabase.com) (Postgres),
same as the source project, with a graceful local fallback so the app
runs perfectly well without any setup.

### 1. Create a Supabase project

Go to [supabase.com](https://supabase.com), create a free project, open
**SQL Editor**, and run everything in `supabase/schema.sql`. This creates:

- `products` — the catalog, public to read, writable only when signed in
- `orders` / `order_items` — ready for whenever you want checkout to write
  real orders instead of the current simulated confirmation

### 2. Connect the app

In **Project Settings → API**, copy the **Project URL** and **anon
public** key into `lib/config/supabase_config.dart`, or pass them at
run/build time instead:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Until you do either, `ProductsRepository` returns an empty catalog, so the
storefront will show "No products yet" until you add real products from
the admin dashboard.

### 3. Create your admin login

The dashboard doesn't have public sign-up (on purpose — you don't want
random visitors creating accounts). Create the one login you'll use
yourself in the Supabase dashboard:

**Authentication → Users → Add user**, set an email + password, and make
sure "Auto Confirm User" is checked.

### 4. Open the admin dashboard

Two ways in:

- **Direct link** — go straight to `your-site.com/#/admin` (see the
  GitHub Pages section above). This is the one to bookmark.
- **From the storefront** — scroll to the very bottom of the home page
  and tap **"Store admin →"** in the footer.

Either way, sign in with the email + password you created in step 3.

You'll land on the product list, where you can:

- **Add a product** — name, description, price, photo, category, tags,
  rating, stock, and sort order.
- **Add a photo two ways**: tap **"Upload a photo from your device"** to
  pick an image straight from your phone/computer (it uploads to Supabase
  Storage and fills in the URL for you), or paste an image URL directly
  if you already have one hosted somewhere.
- **Pick or create a category** — category isn't a fixed list. The form
  shows a dropdown of categories you've used before, plus a **"+ New
  category"** chip — type any name and it's created immediately, no code
  changes needed.
- **Edit or delete** any existing product from the list.

Everything writes straight to Supabase and is protected by the Row Level
Security policies in `supabase/schema.sql` — only a signed-in user (i.e.
you) can add, edit, or delete; anyone can browse and read the catalog.

If you're upgrading from an older version of this schema that had a
fixed `category in (...)` check constraint, drop it first:

```sql
alter table products drop constraint if exists products_category_check;
```

then run the rest of `supabase/schema.sql` to add the new `categories`
table and the `product-images` storage bucket used for photo uploads.
table.

## WhatsApp checkout + payment

Checkout now collects two phone numbers and a payment choice, and does two
things when the customer taps **"Place order"**:

1. Saves the order (name, email, phones, address, items, payment method,
   totals) to Supabase `orders`/`order_items` — this is what shows up on
   the admin **Orders** dashboard, unchanged from before.
2. Opens WhatsApp on the customer's device with the owner's chat
   pre-filled with a full order summary, using the public
   `https://wa.me/<number>?text=...` link — **no WhatsApp Business API,
   no account needed.** The customer still has to tap **Send** inside
   WhatsApp themselves; the app can't send it on their behalf.

### Set it up

In **Store admin → Store settings**, fill in:

- **Your WhatsApp number** — digits only, country code first, no `+` or
  spaces (e.g. an Egyptian `010xxxxxxxx` becomes `2010xxxxxxxx`). This is
  the number the pre-filled WhatsApp message opens to.
- **Vodafone Cash number** — when the customer chooses "Vodafone Cash" at
  checkout, we open their Contacts app with this number ready to save.
  Leave it empty to hide that option.
- **InstaPay link** — when the customer chooses "InstaPay" at checkout, we
  open this link directly (e.g. your `ipn.eg` payment link), which hands
  off straight to the InstaPay app. Leave it empty to hide that option.

These are stored in the `owner_whatsapp` / `payment_number` / `instapay_link`
columns on `store_settings` (added by `supabase/schema.sql` — re-run it if
you're on an older database, the `alter table ... add column if not exists`
lines are safe to run again).

### Payment methods

Three options are offered at checkout, no payment gateway involved:

- **Cash on delivery** — the customer pays the courier when the order
  arrives.
- **InstaPay** — placing the order opens your InstaPay link so the
  customer can send the total, then the order details go to you on
  WhatsApp to confirm.
- **Vodafone Cash** — placing the order opens the customer's Contacts app
  with your Vodafone Cash number ready to save, then the order details go
  to you on WhatsApp to confirm.

This keeps things simple for a small shop: no payment gateway fees, no
API keys, just a phone number, an InstaPay link, and a WhatsApp chat.

## Cart persistence

Cart state lives on-device for the current session
(`lib/providers/cart_provider.dart`) — no account needed to shop. If you
want the cart to follow a signed-in shopper across devices, add Supabase
Auth and back the provider with a `cart_items` table keyed by user id.

## Swapping in real product photography

Add products from the admin dashboard and set each product's `imageUrl`
to your own photos — either hosted URLs or files uploaded to Supabase
Storage (mirroring the approach the source project uses for portfolio
artwork).

-- Run this once in the Supabase SQL Editor (or `supabase db execute`) to
-- remove data for the old top-of-Home "Home banners" strip
-- (home_banners.placement = 'hero') from the LIVE database. The
-- "Most Ordered banners" strip (placement = 'most_ordered') stays — it
-- uses the same home_banners table, so the table itself is NOT dropped,
-- only the hero rows and their uploaded photos.

-- Hero and most_ordered photos both live directly in the home-banner-images
-- bucket root (no per-placement folder), so step 1 grabs the hero rows'
-- file names from image_url *before* deleting the rows, then step 2 uses
-- that list to remove just those files — most_ordered's photos are
-- untouched.

-- 1) Delete the photo files hero rows point to from the
--    home-banner-images storage bucket (must run before step 2, which
--    deletes the rows those file names come from).
delete from storage.objects
where bucket_id = 'home-banner-images'
  and name in (
    select regexp_replace(image_url, '^.*/home-banner-images/', '')
    from home_banners
    where placement = 'hero'
  );

-- 2) Delete the hero banner rows themselves.
delete from home_banners where placement = 'hero';

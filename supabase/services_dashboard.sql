-- شغّل الملف ده مرة واحدة في Supabase > SQL Editor
-- بيسمح بمسح صورة الـ category من الداشبورد (Remove photo)
drop policy if exists "Authenticated delete access to service_category_images" on service_category_images;
create policy "Authenticated delete access to service_category_images"
  on service_category_images for delete
  using (auth.role() = 'authenticated');

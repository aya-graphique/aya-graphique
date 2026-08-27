-- Adds an optional Arabic name field to about_me, same pattern as
-- headline_ar/bio_ar/skills_ar: nullable/empty by default, additive, and
-- the app falls back to the English `full_name` whenever this is blank.
alter table about_me add column if not exists full_name_ar text not null default '';

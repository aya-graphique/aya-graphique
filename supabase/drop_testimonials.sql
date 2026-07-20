-- Run this once in the Supabase SQL Editor (or `supabase db execute`) to
-- remove the testimonials table and all its data + policies from the LIVE
-- database. schema.sql no longer defines this table, but editing that file
-- alone does not touch data already sitting in your database — this script
-- is what actually does it.
drop table if exists testimonials cascade;

-- =============================================================================
-- ⭐ Farm2Home: Buyer Reviews & Farmer Ratings (run in Supabase SQL Editor)
-- Safe to re-run. Buyer app, Farmer app and Admin panel share this table.
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.marketplace_reviews (
    id TEXT PRIMARY KEY,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.marketplace_reviews ADD COLUMN IF NOT EXISTS buyer_id TEXT NOT NULL DEFAULT '';
ALTER TABLE public.marketplace_reviews ADD COLUMN IF NOT EXISTS buyer_name TEXT NOT NULL DEFAULT 'Buyer';
ALTER TABLE public.marketplace_reviews ADD COLUMN IF NOT EXISTS buyer_avatar TEXT DEFAULT '';
ALTER TABLE public.marketplace_reviews ADD COLUMN IF NOT EXISTS product_id TEXT DEFAULT '';
ALTER TABLE public.marketplace_reviews ADD COLUMN IF NOT EXISTS product_name TEXT DEFAULT '';
ALTER TABLE public.marketplace_reviews ADD COLUMN IF NOT EXISTS product_image TEXT DEFAULT '';
ALTER TABLE public.marketplace_reviews ADD COLUMN IF NOT EXISTS farmer_id TEXT NOT NULL DEFAULT '';
ALTER TABLE public.marketplace_reviews ADD COLUMN IF NOT EXISTS farmer_name TEXT NOT NULL DEFAULT '';
ALTER TABLE public.marketplace_reviews ADD COLUMN IF NOT EXISTS rating NUMERIC NOT NULL DEFAULT 5;
ALTER TABLE public.marketplace_reviews ADD COLUMN IF NOT EXISTS title TEXT DEFAULT '';
ALTER TABLE public.marketplace_reviews ADD COLUMN IF NOT EXISTS comment TEXT DEFAULT '';
ALTER TABLE public.marketplace_reviews ADD COLUMN IF NOT EXISTS quality_tag TEXT DEFAULT 'Grade-A Fresh';
ALTER TABLE public.marketplace_reviews ADD COLUMN IF NOT EXISTS farmer_reply TEXT;
ALTER TABLE public.marketplace_reviews ADD COLUMN IF NOT EXISTS farmer_reply_at TIMESTAMPTZ;
ALTER TABLE public.marketplace_reviews ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

-- Remove any old demo/mock rows and foreign keys that could block writes
DELETE FROM public.marketplace_reviews
WHERE id IN ('rev_101','rev_102','rev_103','rev_104')
   OR buyer_id IN ('buyer_chamara','buyer_nimal','buyer_dharshana');

DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT conname FROM pg_constraint
           WHERE conrelid = 'public.marketplace_reviews'::regclass AND contype = 'f'
  LOOP
    EXECUTE format('ALTER TABLE public.marketplace_reviews DROP CONSTRAINT %I', r.conname);
  END LOOP;
END $$;

ALTER TABLE public.marketplace_reviews ENABLE ROW LEVEL SECURITY;

DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT policyname FROM pg_policies
           WHERE schemaname='public' AND tablename='marketplace_reviews'
  LOOP
    EXECUTE format('DROP POLICY %I ON public.marketplace_reviews', r.policyname);
  END LOOP;
END $$;

-- Buyer, farmer & admin all read/write (prototype-open RLS)
CREATE POLICY marketplace_reviews_all_access ON public.marketplace_reviews
  FOR ALL TO public USING (true) WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_reviews_farmer ON public.marketplace_reviews(farmer_id);
CREATE INDEX IF NOT EXISTS idx_reviews_buyer ON public.marketplace_reviews(buyer_id);
CREATE INDEX IF NOT EXISTS idx_reviews_product ON public.marketplace_reviews(product_id);

-- Make sure the farmers/products tables are readable by the buyer app
-- (needed so a buyer can pick a real registered farmer to rate)
DO $$
BEGIN
  IF to_regclass('public.farmers') IS NOT NULL THEN
    ALTER TABLE public.farmers ENABLE ROW LEVEL SECURITY;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public'
                   AND tablename='farmers' AND policyname='farmers_public_read') THEN
      CREATE POLICY farmers_public_read ON public.farmers FOR SELECT TO public USING (true);
    END IF;
  END IF;
  IF to_regclass('public.products') IS NOT NULL THEN
    ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public'
                   AND tablename='products' AND policyname='products_public_read') THEN
      CREATE POLICY products_public_read ON public.products FOR SELECT TO public USING (true);
    END IF;
  END IF;
END $$;

-- =============================================================================
-- 🔨 Farm2Home: Auctions & Bidding (safe migration, run in Supabase SQL Editor)
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.auctions (
    id TEXT PRIMARY KEY,
    crop_name TEXT NOT NULL DEFAULT '',
    end_time TIMESTAMPTZ NOT NULL DEFAULT (now() + interval '1 day'),
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS farmer_id TEXT;
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS farmer_name TEXT DEFAULT 'Farmer';
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS farmer_phone TEXT DEFAULT '';
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS farmer_location TEXT DEFAULT '';
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS farmer_avatar TEXT DEFAULT '';
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'Vegetables';
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS quantity NUMERIC NOT NULL DEFAULT 0;
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS unit TEXT DEFAULT 'kg';
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS starting_price NUMERIC NOT NULL DEFAULT 0;
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS min_bid_increment NUMERIC DEFAULT 5;
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS reserve_price NUMERIC;
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS buy_now_price NUMERIC;
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS current_highest_bid NUMERIC DEFAULT 0;
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS highest_bidder_id TEXT;
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS highest_bidder_name TEXT;
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS total_bids INTEGER DEFAULT 0;
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS description TEXT DEFAULT '';
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS harvest_date TIMESTAMPTZ;
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS delivery_terms TEXT DEFAULT 'Farmgate Pickup';
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS location TEXT DEFAULT '';
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS image_url TEXT DEFAULT '';
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS start_time TIMESTAMPTZ DEFAULT now();
ALTER TABLE public.auctions ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active';

-- Remove FK on farmer_id (app farmer ids may not exist in public.farmers)
DO $$
DECLARE r record;
BEGIN
  FOR r IN
    SELECT conname FROM pg_constraint
    WHERE conrelid = 'public.auctions'::regclass AND contype = 'f'
  LOOP
    EXECUTE format('ALTER TABLE public.auctions DROP CONSTRAINT %I', r.conname);
  END LOOP;
END $$;

CREATE TABLE IF NOT EXISTS public.auction_bids (
    id TEXT PRIMARY KEY,
    auction_id TEXT NOT NULL REFERENCES public.auctions(id) ON DELETE CASCADE,
    amount NUMERIC NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE public.auction_bids ADD COLUMN IF NOT EXISTS bidder_id TEXT;
ALTER TABLE public.auction_bids ADD COLUMN IF NOT EXISTS bidder_name TEXT DEFAULT 'Anonymous Buyer';
ALTER TABLE public.auction_bids ADD COLUMN IF NOT EXISTS is_winning BOOLEAN DEFAULT false;
ALTER TABLE public.auction_bids ADD COLUMN IF NOT EXISTS notes TEXT DEFAULT '';

-- Open RLS (prototype): farmer, buyer & admin can all read/write
ALTER TABLE public.auctions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.auction_bids ENABLE ROW LEVEL SECURITY;

DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT policyname, tablename FROM pg_policies
           WHERE schemaname='public' AND tablename IN ('auctions','auction_bids')
  LOOP
    EXECUTE format('DROP POLICY %I ON public.%I', r.policyname, r.tablename);
  END LOOP;
END $$;

CREATE POLICY auctions_all_access ON public.auctions
  FOR ALL TO public USING (true) WITH CHECK (true);
CREATE POLICY auction_bids_all_access ON public.auction_bids
  FOR ALL TO public USING (true) WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_auctions_farmer ON public.auctions(farmer_id);
CREATE INDEX IF NOT EXISTS idx_auctions_status ON public.auctions(status);
CREATE INDEX IF NOT EXISTS idx_bids_auction ON public.auction_bids(auction_id);

-- =============================================================================
-- 🤝 Farm2Home Marketplace: Pre-Orders & Contract Farming Module
-- Two-Way Marketplace connecting Wholesale Buyers with Local Farmers
-- =============================================================================

-- 1. Table: pre_orders
CREATE TABLE IF NOT EXISTS public.pre_orders (
    id TEXT PRIMARY KEY,
    buyer_id TEXT NOT NULL DEFAULT '',
    buyer_name TEXT NOT NULL,
    farmer_id TEXT DEFAULT NULL,
    farmer_name TEXT DEFAULT NULL,
    crop_name TEXT NOT NULL,
    required_quantity_kg NUMERIC NOT NULL DEFAULT 0,
    offered_price_per_kg NUMERIC NOT NULL DEFAULT 0,
    expected_delivery_date TIMESTAMPTZ NOT NULL,
    quality_requirements TEXT DEFAULT '',
    delivery_location TEXT DEFAULT '',
    payment_terms TEXT DEFAULT 'Negotiable',
    packaging_requirements TEXT DEFAULT 'Standard Packaging',
    advance_payment_rs NUMERIC DEFAULT 0,
    status TEXT DEFAULT 'Pending', -- 'Pending', 'Accepted', 'In Progress', 'Completed', 'Cancelled'
    farmer_expected_harvest_date TIMESTAMPTZ,
    farmer_estimated_yield_kg NUMERIC,
    farmer_location TEXT DEFAULT '',
    farmer_notes TEXT DEFAULT '',
    farmer_rating NUMERIC,
    farmer_review TEXT,
    rated_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Ensure columns exist if table was partially created previously
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS buyer_id TEXT DEFAULT '';
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS buyer_name TEXT NOT NULL DEFAULT 'Wholesale Buyer';
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS farmer_id TEXT DEFAULT NULL;
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS farmer_name TEXT DEFAULT NULL;
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS crop_name TEXT NOT NULL DEFAULT 'Fresh Produce';
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS required_quantity_kg NUMERIC NOT NULL DEFAULT 0;
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS offered_price_per_kg NUMERIC NOT NULL DEFAULT 0;
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS expected_delivery_date TIMESTAMPTZ DEFAULT now();
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS quality_requirements TEXT DEFAULT '';
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS delivery_location TEXT DEFAULT '';
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS payment_terms TEXT DEFAULT 'Negotiable';
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS packaging_requirements TEXT DEFAULT 'Standard Packaging';
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS advance_payment_rs NUMERIC DEFAULT 0;
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'Pending';
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS farmer_expected_harvest_date TIMESTAMPTZ;
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS farmer_estimated_yield_kg NUMERIC;
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS farmer_location TEXT DEFAULT '';
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS farmer_notes TEXT DEFAULT '';
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS farmer_rating NUMERIC;
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS farmer_review TEXT;
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS rated_at TIMESTAMPTZ;
ALTER TABLE public.pre_orders ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT now();

-- Drop foreign key constraint on farmer_id if exists to allow flexible prototype farmer logins
ALTER TABLE public.pre_orders DROP CONSTRAINT IF EXISTS pre_orders_farmer_id_fkey;

-- 2. Table: pre_order_progress (Milestone Tracking)
CREATE TABLE IF NOT EXISTS public.pre_order_progress (
    id TEXT PRIMARY KEY,
    pre_order_id TEXT NOT NULL REFERENCES public.pre_orders(id) ON DELETE CASCADE,
    stage TEXT NOT NULL,
    description TEXT DEFAULT '',
    images TEXT[] DEFAULT '{}',
    date TIMESTAMPTZ DEFAULT now(),
    update_type TEXT DEFAULT 'Progress', -- 'Progress', 'Delay', 'Issue'
    new_expected_date TIMESTAMPTZ,
    issue_type TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.pre_order_progress ADD COLUMN IF NOT EXISTS update_type TEXT DEFAULT 'Progress';
ALTER TABLE public.pre_order_progress ADD COLUMN IF NOT EXISTS new_expected_date TIMESTAMPTZ;
ALTER TABLE public.pre_order_progress ADD COLUMN IF NOT EXISTS issue_type TEXT;

-- 3. Enable RLS with open policies for rapid prototype/testing
ALTER TABLE public.pre_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pre_order_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public select on pre_orders" ON public.pre_orders;
CREATE POLICY "Public select on pre_orders" ON public.pre_orders FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public insert on pre_orders" ON public.pre_orders;
CREATE POLICY "Public insert on pre_orders" ON public.pre_orders FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public update on pre_orders" ON public.pre_orders;
CREATE POLICY "Public update on pre_orders" ON public.pre_orders FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Public delete on pre_orders" ON public.pre_orders;
CREATE POLICY "Public delete on pre_orders" ON public.pre_orders FOR DELETE USING (true);

DROP POLICY IF EXISTS "Public select on pre_order_progress" ON public.pre_order_progress;
CREATE POLICY "Public select on pre_order_progress" ON public.pre_order_progress FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public insert on pre_order_progress" ON public.pre_order_progress;
CREATE POLICY "Public insert on pre_order_progress" ON public.pre_order_progress FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public update on pre_order_progress" ON public.pre_order_progress;
CREATE POLICY "Public update on pre_order_progress" ON public.pre_order_progress FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Public delete on pre_order_progress" ON public.pre_order_progress;
CREATE POLICY "Public delete on pre_order_progress" ON public.pre_order_progress FOR DELETE USING (true);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_pre_orders_buyer ON public.pre_orders(buyer_id);
CREATE INDEX IF NOT EXISTS idx_pre_orders_farmer ON public.pre_orders(farmer_id);
CREATE INDEX IF NOT EXISTS idx_pre_orders_status ON public.pre_orders(status);
CREATE INDEX IF NOT EXISTS idx_pre_order_progress_order ON public.pre_order_progress(pre_order_id);

-- 4. Realistic Seed Pre-Orders
INSERT INTO public.pre_orders (
    id, buyer_id, buyer_name, farmer_id, farmer_name, crop_name,
    required_quantity_kg, offered_price_per_kg, expected_delivery_date,
    quality_requirements, delivery_location, payment_terms,
    packaging_requirements, advance_payment_rs, status,
    farmer_expected_harvest_date, farmer_estimated_yield_kg,
    farmer_location, farmer_notes, farmer_rating, farmer_review, rated_at, created_at
)
VALUES
(
    'po_101',
    'buyer_chamara',
    'Chamara Perera (GreenMart)',
    NULL,
    NULL,
    'Organic Highland Carrots',
    500.0,
    350.0,
    NOW() + INTERVAL '25 days',
    'Grade-A, length 15-20cm, washed and sorted, zero synthetic pesticide residues',
    'Dambulla Dedicated Economic Centre, Bay 14',
    'Advance Payment (Partial)',
    '25Kg Ventilated Plastic Crates',
    50000.0,
    'Pending',
    NULL,
    NULL,
    '',
    '',
    NULL,
    NULL,
    NULL,
    NOW() - INTERVAL '2 days'
),
(
    'po_102',
    'buyer_super_fresh',
    'Lanka Fresh Markets Ltd',
    'farmer_bandara',
    'K. M. Bandara',
    'Red Onions (Dambulla Big Variety)',
    1200.0,
    420.0,
    NOW() + INTERVAL '45 days',
    'Cured bulbs, min diameter 45mm, skin intact, moisture below 14%',
    'Pettah Wholesale Produce Hub, Colombo 11',
    'Bank Transfer on Delivery',
    '50Kg Jute Gunny Bags',
    100000.0,
    'In Progress',
    NOW() + INTERVAL '40 days',
    1350.0,
    'Nuwara Eliya / Dambulla Belt',
    'Drip-irrigated seed beds prepared. High germination rate confirmed.',
    NULL,
    NULL,
    NULL,
    NOW() - INTERVAL '12 days'
),
(
    'po_103',
    'buyer_keells',
    'Keells Super Procurement',
    'farmer_bandara',
    'K. M. Bandara',
    'Green Chillies (MI-2 Variety)',
    800.0,
    650.0,
    NOW() - INTERVAL '3 days',
    'Dark green, 8-10cm, crisp texture, harvest fresh within 12 hours of dispatch',
    'Kerawalapitiya Central Logistics Centre',
    'Full Advance',
    '20Kg Aerated Corrugated Cartons',
    200000.0,
    'Completed',
    NOW() - INTERVAL '5 days',
    850.0,
    'Nuwara Eliya Agro Zone',
    'Harvest completed smoothly and packed according to supermarkets spec.',
    5.0,
    'Exceptional quality chillies, exactly as contracted. Perfectly graded and timely delivery!',
    NOW() - INTERVAL '2 days',
    NOW() - INTERVAL '30 days'
)
ON CONFLICT (id) DO NOTHING;

-- Seed Progress Updates for po_102
INSERT INTO public.pre_order_progress (
    id, pre_order_id, stage, description, images, date, update_type
)
VALUES
(
    'prog_201',
    'po_102',
    'Land Preparation',
    'Tilled 1.5 acres of red loamy soil, applied organic compost and raised nursery beds.',
    ARRAY['https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=600&auto=format&fit=crop&q=80'],
    NOW() - INTERVAL '10 days',
    'Progress'
),
(
    'prog_202',
    'po_102',
    'Seeds Planted',
    'Certified seed set planting completed across all ridges. Initial sprinkler irrigation underway.',
    ARRAY['https://images.unsplash.com/photo-1592417817098-8f3d6ef2c6e6?w=600&auto=format&fit=crop&q=80'],
    NOW() - INTERVAL '4 days',
    'Progress'
)
ON CONFLICT (id) DO NOTHING;

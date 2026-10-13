-- =============================================================================
-- 🌟 Farm2Home Marketplace: Product Reviews & Farmer Ratings Table
-- Member 1 (IT23843770 Thennakoon T.M.S.N) - Buyer Feedback CRUD
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.marketplace_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id TEXT NOT NULL,
    buyer_name TEXT NOT NULL,
    buyer_avatar TEXT DEFAULT '',
    product_id TEXT NOT NULL,
    product_name TEXT NOT NULL,
    product_image TEXT DEFAULT '',
    farmer_id TEXT NOT NULL,
    farmer_name TEXT NOT NULL,
    rating NUMERIC(2, 1) NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
    title TEXT NOT NULL,
    comment TEXT NOT NULL,
    quality_tag TEXT DEFAULT 'Grade-A Fresh',
    farmer_reply TEXT DEFAULT NULL,
    farmer_reply_at TIMESTAMPTZ DEFAULT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.marketplace_reviews ENABLE ROW LEVEL SECURITY;

-- Allow unrestricted CRUD during prototype/demo
DROP POLICY IF EXISTS "Public select on marketplace_reviews" ON public.marketplace_reviews;
CREATE POLICY "Public select on marketplace_reviews" ON public.marketplace_reviews FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public insert on marketplace_reviews" ON public.marketplace_reviews;
CREATE POLICY "Public insert on marketplace_reviews" ON public.marketplace_reviews FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public update on marketplace_reviews" ON public.marketplace_reviews;
CREATE POLICY "Public update on marketplace_reviews" ON public.marketplace_reviews FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Public delete on marketplace_reviews" ON public.marketplace_reviews;
CREATE POLICY "Public delete on marketplace_reviews" ON public.marketplace_reviews FOR DELETE USING (true);

-- Indexes for lightning fast queries
CREATE INDEX IF NOT EXISTS idx_reviews_product_id ON public.marketplace_reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_farmer_name ON public.marketplace_reviews(farmer_name);
CREATE INDEX IF NOT EXISTS idx_reviews_buyer_id ON public.marketplace_reviews(buyer_id);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON public.marketplace_reviews(created_at DESC);

-- Seed realistic sample reviews if table is empty
INSERT INTO public.marketplace_reviews (
    buyer_id, buyer_name, buyer_avatar, product_id, product_name, product_image,
    farmer_id, farmer_name, rating, title, comment, quality_tag, farmer_reply, farmer_reply_at
)
SELECT 
    'buyer_chamara',
    'Chamara Perera',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
    'prod_1',
    'Nuwara Eliya Highland Carrots',
    'https://images.unsplash.com/photo-1598170845058-32b9d6a5c317?w=600&auto=format&fit=crop&q=80',
    'farmer_bandara',
    'K. M. Bandara',
    5.0,
    'Unbeatable Highland Sweetness & Crunch',
    'The carrots arrived fresh from Hakgala valley within 10 hours. Sweet, crunchy and 100% soil-washed. Highly recommended for hotel salads!',
    'Grade-A Fresh',
    'Thank you Chamara! We harvested this lot at 5:30 AM before morning mist cleared.',
    NOW() - INTERVAL '1 day'
WHERE NOT EXISTS (SELECT 1 FROM public.marketplace_reviews LIMIT 1);

INSERT INTO public.marketplace_reviews (
    buyer_id, buyer_name, buyer_avatar, product_id, product_name, product_image,
    farmer_id, farmer_name, rating, title, comment, quality_tag, farmer_reply, farmer_reply_at
)
SELECT 
    'buyer_nimal',
    'Nimal Senanayake',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80',
    'prod_3',
    'Hakgala Crispy Organic Leeks',
    'https://images.unsplash.com/photo-1524179091875-bf99a9a6fa57?w=600&auto=format&fit=crop&q=80',
    'farmer_bandara',
    'K. M. Bandara',
    4.9,
    'Certified Organic & Extremely Tender',
    'Cooked soup with these leeks. The aroma is distinct from store-bought ones. Clean packaging and zero damage during refrigerated van transit.',
    '100% Organic',
    NULL,
    NULL
WHERE (SELECT COUNT(*) FROM public.marketplace_reviews) < 2;

INSERT INTO public.marketplace_reviews (
    buyer_id, buyer_name, buyer_avatar, product_id, product_name, product_image,
    farmer_id, farmer_name, rating, title, comment, quality_tag, farmer_reply, farmer_reply_at
)
SELECT 
    'buyer_dharshana',
    'Dharshana Silva',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop&q=80',
    'prod_5',
    'Dambulla Vine-Ripened Red Tomatoes',
    'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop&q=80',
    'farmer_sunil',
    'Sunil Perera',
    4.8,
    'Plump, Juicy & Perfect for Curries',
    'No bruises on arrival. Sun-ripened flavor is rich and tangy. Great direct price with no retail markup.',
    'Crisp & Sweet',
    'Appreciate your trust Dharshana! Packed in aerated crates to prevent transit heat.',
    NOW() - INTERVAL '3 days'
WHERE (SELECT COUNT(*) FROM public.marketplace_reviews) < 3;

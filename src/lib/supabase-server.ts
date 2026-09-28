import { createClient } from "@supabase/supabase-js";

// Cliente solo para leer datos publicos desde el servidor en (SSR)
// persistSession en false el servido no guarda las sesiones de nadie

export const supabaseServer = createClient(
    import.meta.env.PUBLIC_SUPABASE_URL,
    import.meta.env.PUBLIC_SUPABASE_ANON_KEY,
    { auth: { persistSession: false, autoRefreshToken: false}},
);
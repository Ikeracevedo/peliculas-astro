create table public.peliculas (
    id bigint generated always as identity primary key,
    nombre text not null check (char_length(nombre) between 1 and 200),
    imagen text not null,
    sinopsis text,
    estreno integer check (estreno between 1888 and 2100),
    creada_en timestamptz not null default now()
);

alter table public.peliculas enable row level security;

create policy "peliculas_select_publico"
    on public.peliculas for select 
    to anon, authenticated
    using (true);

create policy "peliculas_insert_autenticado"
    on public.peliculas for insert
    to authenticated
    with check (true);

create policy "peliculas_update_autenticado"
    on public.peliculas for update
    to authenticated
    using (true);

create policy "peliculas_delete_autenticado"
    on public.peliculas for delete
    to authenticated
    using (true);

-- ─── Reseñas ────────────────────────────────────────────────────────────────

create table public.resenas (
    id bigint generated always as identity primary key,
    pelicula_id bigint not null references public.peliculas(id) on delete cascade,
    user_id uuid not null default auth.uid(),
    user_email text not null default '',
    comentario text not null check (char_length(comentario) between 1 and 1000),
    calificacion smallint not null check (calificacion between 1 and 5),
    creada_en timestamptz not null default now()
);

alter table public.resenas enable row level security;

-- Cualquiera puede leer reseñas
create policy "resenas_select_publico"
    on public.resenas for select
    to anon, authenticated
    using (true);

-- Solo usuarios autenticados pueden crear reseñas (se asigna su user_id automáticamente)
create policy "resenas_insert_autenticado"
    on public.resenas for insert
    to authenticated
    with check (auth.uid() = user_id);

-- Solo el autor puede editar su reseña
create policy "resenas_update_autor"
    on public.resenas for update
    to authenticated
    using (auth.uid() = user_id);

-- Solo el autor puede borrar su reseña
create policy "resenas_delete_autor"
    on public.resenas for delete
    to authenticated
    using (auth.uid() = user_id);

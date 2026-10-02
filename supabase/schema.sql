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

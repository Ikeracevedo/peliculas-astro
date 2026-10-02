-- Parche para una base de datos que YA tiene la tabla `resenas` creada con la versión anterior
-- de schema.sql (donde el cliente enviaba user_email). Ejecutar una sola vez en el SQL Editor.
-- Instalaciones nuevas no lo necesitan: schema.sql ya incluye estos cambios.

-- 1. El correo del autor lo pone la base de datos a partir del JWT.
alter table public.resenas
    alter column user_email set default coalesce(auth.jwt() ->> 'email', '');

-- 2. Las políticas rechazan cualquier correo que no sea el del usuario autenticado.
drop policy if exists "resenas_insert_autenticado" on public.resenas;
create policy "resenas_insert_autenticado"
    on public.resenas for insert
    to authenticated
    with check (
        auth.uid() = user_id
        and user_email = coalesce(auth.jwt() ->> 'email', '')
    );

drop policy if exists "resenas_update_autor" on public.resenas;
create policy "resenas_update_autor"
    on public.resenas for update
    to authenticated
    using (auth.uid() = user_id)
    with check (
        auth.uid() = user_id
        and user_email = coalesce(auth.jwt() ->> 'email', '')
    );

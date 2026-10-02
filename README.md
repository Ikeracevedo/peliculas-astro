<div align="center">
  <img src="docs/logo-upb.png" alt="Universidad Pontificia Bolivariana" width="340"/>

  <h1>CineVault — Catálogo de Películas</h1>

  <p>Un catálogo público de películas con búsqueda y paginación generadas en el servidor,<br>
  y un panel de administración protegido por autenticación para gestionar el catálogo.<br>
  Continuación del Taller #1: el mismo modelo, ahora sobre una <b>arquitectura híbrida</b><br>
  con Astro, Supabase y Cloudflare Workers.</p>

  <p><sub>Un solo proyecto Astro que mezcla páginas SSR (dinámicas) y SSG (pre-renderizadas).</sub></p>

  <p>
    <img src="https://img.shields.io/badge/Astro-7-FF5D01?logo=astro&logoColor=white" />
    <img src="https://img.shields.io/badge/Cloudflare-Workers-F38020?logo=cloudflare&logoColor=white" />
    <img src="https://img.shields.io/badge/Supabase-Postgres%20%2B%20Auth-3ECF8E?logo=supabase&logoColor=white" />
    <img src="https://img.shields.io/badge/Tailwind-4-06B6D4?logo=tailwindcss&logoColor=white" />
    <img src="https://img.shields.io/badge/TypeScript-strict-3178C6?logo=typescript&logoColor=white" />
    <img src="https://img.shields.io/badge/pnpm-package%20manager-F69220?logo=pnpm&logoColor=white" />
  </p>

  <p><strong>Plataforma de Programación Empresarial — Ingeniería de Sistemas e Informática · Universidad Pontificia Bolivariana</strong></p>
</div>

---

## 🌐 Sitio desplegado

**URL pública en Cloudflare:** <https://peliculas-astro.ikeracevedo.workers.dev>

---

## ¿Qué puedes hacer?

- 🔎 **Explorar** el catálogo de películas con imagen, nombre y año de estreno, sin necesidad de cuenta.
- 🧭 **Buscar por nombre** (sin distinguir mayúsculas) y **paginar** los resultados; ambos se resuelven en el servidor.
- 👤 **Registrarte e iniciar sesión** con Supabase Auth.
- 🛠️ **Administrar el catálogo** (crear, editar y eliminar películas) desde un panel que exige sesión activa.
- 🎬 Ver el **detalle de cada película** y leer sus **reseñas** (con calificación de 1 a 5 estrellas); con sesión, escribir, editar y borrar las propias.
- ℹ️ Consultar la página pública **"Acerca de"** con la información del proyecto.

---

## Tecnologías

| Capa | Tecnología | Rol |
|---|---|---|
| Framework | Astro 7 | Generación de páginas SSR y SSG en el mismo proyecto |
| Despliegue | Cloudflare Workers (`@astrojs/cloudflare`) | Ejecuta el sitio en la red de Cloudflare |
| Base de datos | Supabase (PostgreSQL) | Persistencia y API REST autogenerada |
| Autenticación | Supabase Auth | Registro, login y sesión |
| Seguridad de datos | Row Level Security (RLS) | Quién puede leer y escribir cada fila |
| Estilos | Tailwind CSS 4 | Diseño oscuro estilo CineVault |
| Navegación | Astro View Transitions (`<ClientRouter />`) | Transiciones sin recargar la página |
| Gestor de paquetes | pnpm | Instalación estricta de dependencias |

---

## Arquitectura

El proyecto usa **`output: 'server'`**: toda página es SSR por defecto, y las páginas que se pueden generar de antemano lo declaran explícitamente con `export const prerender = true`. Así, olvidar la declaración falla de forma segura (la página funciona, solo se renderiza en cada request).

### Qué es SSR y qué es SSG en este proyecto

| | ⚡ SSR (dinámico) | 🏗️ SSG (estático) |
|---|---|---|
| **Páginas** | Listado público `/` | `/login`, `/registro`, `/admin`, `/acerca` |
| **Cuándo se genera el HTML** | En el servidor, en cada request | Una sola vez, en el build |
| **De dónde vienen los datos** | Supabase, consultado **desde el servidor** | Supabase, consultado **desde el navegador** tras autenticarse |
| **Por qué** | El contenido es público y debe estar siempre en el HTML (SEO, funciona sin JavaScript) | El HTML es idéntico para todos; lo que cambia depende de la sesión de cada usuario |

### Flujo de una petición al listado

```
Navegador  →  GET /?q=the&page=1
                  ↓
Cloudflare Worker (Astro, SSR)
   · lee q y page de la URL
   · valida page (si no es un entero positivo, usa 1)
   · consulta Supabase con la anon key (ilike + range + count)
                  ↓
Supabase (PostgREST + RLS: la política permite SELECT a cualquiera)
                  ↓
Worker arma el HTML con las películas ya dentro
                  ↓
Navegador recibe HTML completo (sin fetch desde el cliente)
```

---

## Estructura del proyecto

```
peliculas-astro/
├── docs/
│   └── logo-upb.png          # Logo de la universidad (usado en este README)
├── public/                   # Archivos estáticos (favicon)
├── src/
│   ├── layouts/
│   │   └── Layout.astro      # Layout común: <title> por página + <ClientRouter />
│   ├── lib/
│   │   ├── supabase-server.ts   # Cliente sin sesión, para leer datos públicos en SSR
│   │   └── supabase-browser.ts  # Cliente del navegador, con sesión (Auth y CRUD)
│   ├── pages/
│   │   ├── index.astro            # Listado público SSR con búsqueda y paginación
│   │   ├── peliculas/[id].astro   # Detalle + reseñas (SSR)
│   │   ├── acerca.astro           # SSG
│   │   ├── registro.astro         # SSG
│   │   ├── login.astro            # SSG
│   │   └── admin/index.astro      # CRUD de películas (SSG, datos desde el navegador)
│   └── styles/
│       └── global.css        # Tailwind
├── supabase/
│   ├── schema.sql            # Tablas peliculas y resenas + políticas RLS
│   ├── seed.sql              # 20 películas de ejemplo
│   └── patch-resenas-email.sql  # Parche para bases creadas con la versión anterior de resenas
├── astro.config.mjs          # output: 'server' + adaptador de Cloudflare + Tailwind
├── wrangler.jsonc            # Configuración del Worker de Cloudflare
├── .env.example              # Variables de entorno necesarias (sin valores)
└── package.json
```

---

## Rutas

| Ruta | Render | Acceso | Descripción |
|---|---|---|---|
| `/` | SSR | Público | Catálogo con búsqueda `?q=` y paginación `?page=` |
| `/peliculas/:id` | SSR | Público (reseñar requiere sesión) | Detalle de la película y sus reseñas |
| `/acerca` | SSG | Público | Información del proyecto y del equipo |
| `/registro` | SSG | Público | Crear cuenta |
| `/login` | SSG | Público | Iniciar sesión |
| `/admin` | SSG | 🔒 Sesión | CRUD de películas desde el navegador |

Comportamiento del listado ante entradas inusuales:

| URL | Resultado |
|---|---|
| `/?q=the` | Películas cuyo nombre contiene "the", sin distinguir mayúsculas |
| `/?page=abc` o `/?page=0` | Se trata como página 1 |
| `/?page=9999` | Redirige al catálogo (página fuera de rango) |
| `/?q=zzzz` | Mensaje "No hay películas para esta búsqueda" |

---

## Base de datos (Supabase)

Tabla `peliculas`, definida en [`supabase/schema.sql`](supabase/schema.sql):

| Columna | Tipo | Notas |
|---|---|---|
| `id` | `bigint` identity | Clave primaria autogenerada |
| `nombre` | `text` | Obligatorio, entre 1 y 200 caracteres |
| `imagen` | `text` | Obligatorio (URL del póster) |
| `sinopsis` | `text` | Opcional |
| `estreno` | `integer` | Opcional, entre 1888 y 2100 |
| `creada_en` | `timestamptz` | Por defecto `now()` |

### Seguridad con RLS

La tabla tiene **Row Level Security activado**. Políticas actuales:

| Operación | Quién puede |
|---|---|
| `SELECT` | Cualquiera (`anon` y `authenticated`) |
| `INSERT`, `UPDATE`, `DELETE` | Solo usuarios autenticados |

> **Por qué la anon key puede ser pública:** la anon key solo identifica una petición como "anónima". No abre nada por sí sola: todo lo que puede hacer lo define RLS. Por eso se incluye en el código del navegador sin comprometer los datos.

> **Limitación conocida:** con las políticas actuales, cualquier usuario registrado puede modificar el catálogo. Es más débil que el rol `ADMIN` del Taller #1. Endurecerlo con un rol en `app_metadata` está identificado como mejora.

### Tabla `resenas`

| Columna | Tipo | Notas |
|---|---|---|
| `id` | `bigint` identity | Clave primaria |
| `pelicula_id` | `bigint` | FK a `peliculas`, `on delete cascade` |
| `user_id` | `uuid` | Por defecto `auth.uid()`: lo pone la base, no el cliente |
| `user_email` | `text` | Por defecto el correo del JWT; la política rechaza cualquier otro valor |
| `comentario` | `text` | Entre 1 y 1000 caracteres |
| `calificacion` | `smallint` | Entre 1 y 5 |

RLS: lectura pública; crear, editar y borrar **solo el autor** (`auth.uid() = user_id`). Como `user_id` y `user_email` salen del JWT, nadie puede publicar una reseña a nombre de otra persona.

> **Sanitización:** el panel `/admin` construye el DOM con `textContent` (no `innerHTML`), porque cualquier usuario autenticado puede crear películas y el contenido se muestra a los demás: así se evita XSS almacenado. En las páginas Astro, `{variable}` ya escapa el HTML.

La llave `service_role` de Supabase **nunca** se usa en este proyecto ni debe subirse al repositorio.

---

## Variables de entorno

Copia `.env.example` a `.env` y completa los valores desde **Supabase → Project Settings → API**:

```bash
PUBLIC_SUPABASE_URL=
PUBLIC_SUPABASE_ANON_KEY=
```

- El prefijo `PUBLIC_` hace que Astro incluya la variable en el código del navegador. Es seguro **solo** porque la anon key es pública por diseño.
- `.env` está en `.gitignore` y **no se sube** al repositorio.
- Estas variables se **incrustan en el código durante el build** (`astro build`); por eso el `.env` debe existir cuando se construye el proyecto para desplegar.

---

## Cómo levantar el proyecto

**Requisitos:** Node.js `>=22.12` y pnpm.

### 1. Preparar Supabase (una sola vez)

1. Crea un proyecto en [supabase.com](https://supabase.com).
2. En **SQL Editor**, ejecuta [`supabase/schema.sql`](supabase/schema.sql) y después [`supabase/seed.sql`](supabase/seed.sql).
3. En **Authentication → Sign In / Providers → Email**, desactiva **Confirm email** mientras se desarrolla.

### 2. Instalar y ejecutar

```bash
git clone https://github.com/Ikeracevedo/peliculas-astro.git
cd peliculas-astro
pnpm install
cp .env.example .env    # y completa las dos variables
pnpm dev                # http://localhost:4321
```

### Scripts útiles

```bash
pnpm dev        # servidor de desarrollo
pnpm build      # genera dist/ (Worker + estáticos)
pnpm preview    # sirve el build localmente
```

---

## Despliegue en Cloudflare Workers

1. Crea una cuenta en Cloudflare y **verifica tu correo** (sin eso, Cloudflare rechaza publicar Workers).
2. Autoriza Wrangler: `pnpm wrangler login`. Comprueba con `pnpm wrangler whoami`.
3. Con el `.env` presente, construye y despliega:

```bash
pnpm build
pnpm wrangler deploy
```

> `wrangler deploy` sube lo que hay en `dist/`, **no** el código fuente. Después de editar código hay que volver a ejecutar `pnpm build`.

**Notas de la configuración** ([`wrangler.jsonc`](wrangler.jsonc)):

- El adaptador de Cloudflare declara un binding `SESSION` (KV) por defecto. El proyecto no usa sesiones de Astro, pero el binding está declarado con su ID para que el despliegue sea **idempotente** (correrlo varias veces da el mismo resultado y no intenta recrear el recurso).
- Este proyecto no tiene secretos de servidor. Si se agregaran, se cargarían con `wrangler secret put`, nunca como variables `PUBLIC_*`.

---

## Verificación del SSR

Sobre el sitio desplegado:

1. Abre la URL pública y presiona **`Ctrl + U`** (ver código fuente).
2. Los **nombres de las películas deben aparecer en el HTML**, aun con JavaScript deshabilitado.
3. Prueba `?q=the` y `?page=2`: el resultado cambia y sigue estando en el HTML.
4. En el panel de administración (SSG), el HTML es el mismo para todos los usuarios: los datos llegan desde el navegador después de autenticarse.

Comprobación por terminal (`curl` no ejecuta JavaScript):

```bash
curl -s "https://peliculas-astro.ikeracevedo.workers.dev/?q=the" | grep -o '<h2 class="font-semibold">[^<]*'
```

---

## Decisiones clave

- **`output: 'server'` + `prerender = true` explícito en las páginas estáticas:** el enunciado pide páginas SSG con esa declaración; con el modo `server` por defecto, esa línea tiene significado y olvidarla no rompe nada.
- **Dos clientes de Supabase:** el del servidor **no guarda sesión** (`persistSession: false`), porque un Worker reutiliza el módulo entre peticiones de distintos usuarios y una sesión guardada podría filtrarse de un visitante a otro. El del navegador sí maneja sesión.
- **`ilike` en la búsqueda:** `LIKE` distingue mayúsculas; `ILIKE` no. PostgREST envía el valor como parámetro, así que no hay inyección SQL.
- **Paginación por `range` (offset):** con un catálogo pequeño es simple y suficiente. Para catálogos muy grandes convendría paginación por cursor (*keyset*).
- **Esquema en `snake_case` y plural:** convención SQL estándar (`peliculas`, `creada_en`). Cambia respecto al Taller #1 (`creadaEn`).
- **Reseñas como extra:** el enunciado pide el CRUD de un solo modelo (`peliculas`). Las reseñas se añadieron como continuación natural del Taller #1; son un extra y no sustituyen ningún requisito.
- **Seguridad en la base de datos, no en el cliente:** `user_id` y `user_email` los fija Postgres desde el JWT y las políticas RLS rechazan valores ajenos; el frontend no es de confianza.

---

## Equipo

| Integrante |
|---|
| Iker Acevedo |
| Jose Mejía |

Ingeniería de Sistemas e Informática · Universidad Pontificia Bolivariana
Plataforma de Programación Empresarial

# CXY Wigs Offline Sales App Deployment

## Architecture

- GitHub Pages hosts the front-end app.
- Supabase provides authentication, roles, product data, client data, and media URLs.
- Sales users see shared products but only their own clients and reports.
- Admin users can see the Admin section, manage products, and view team-level client data.

## Setup

1. Create a Supabase project.
2. Run `docs/supabase-schema.sql` in Supabase SQL Editor.
3. Create users in Supabase Auth.
4. Insert matching rows into `profiles`.
5. Set one or more users to `role = 'admin'`.
6. Upload product images/videos to Supabase Storage or another CDN.
7. Add the public URLs to products.

## Front-End Config

Edit `config.js` before deployment or inject it during deployment:

```js
window.CXY_APP_CONFIG = {
  supabaseUrl: "https://YOUR_PROJECT.supabase.co",
  supabaseAnonKey: "YOUR_SUPABASE_ANON_KEY"
};
```

The anon key is safe for browser use only when Row Level Security policies are enabled.
Do not place service-role keys in GitHub or the front end.

## GitHub Pages

The workflow `.github/workflows/deploy-offline-sales-app.yml` publishes:

```text
tools/offline-sales-app
```

If the repository remains private, GitHub Pages availability depends on the GitHub plan.

## Local Demo Mode

When `config.js` is empty, the app runs in local demo mode:

- Sales Demo: sales role, Admin hidden.
- Admin Demo: admin role, Admin visible.
- Product and client data are stored in browser localStorage.

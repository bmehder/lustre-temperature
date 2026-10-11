# Lustre temperature converter

A small Celsius ↔ Fahrenheit experiment built with Lustre and Tailwind CSS.
It follows your system's light or dark appearance preference.

[Try the app](https://lustre-temperature.vercel.app).

Edit either number input, then press Enter or leave the field to convert.
Values display to one decimal place. The model stores one temperature in the
unit of the latest edit and derives the other value, avoiding conversion loops.

## Run locally

Requires Gleam, Erlang/OTP, and Bun on your PATH. Lustre downloads the standalone
Tailwind compiler on the first build.

```sh
gleam run -m lustre/dev --target erlang start app
```

Open [localhost:1234](http://localhost:1234).

For the development-only time travel inspector, run:

```sh
gleam run -m lustre/dev --target erlang start app_dev
```

Then open **Time Travel** in the lower-right corner.

## Test and build

```sh
gleam test
gleam run -m lustre/dev --target erlang build app
```

The build produces a static app in `dist/`, without the time travel inspector.

## Deploy to Vercel

Requires Node.js and a signed-in Vercel account. Link the project once:

```sh
npx --yes vercel@latest link --yes --project lustre-temperature
```

Build locally and deploy the production app:

```sh
sh scripts/deploy.sh
```

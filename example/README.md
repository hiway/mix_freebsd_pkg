# Example

Replicate this example:
 
  * Run `mix phx.new --no-ecto --no-dashboard --no-mailer example` to create new Phoenix app
  * Run `cd example` to switch working directory to newly created app.
  * Add `{:phx_tailwind_freebsd, "~> 0.2.1", runtime: Mix.env() == :dev}` 
    under `deps()` to enable workaround for Tailwind binary on FreeBSD.
  * Run `mix deps.get` to download dependencies.
  * Run `mix tailwind.install_freebsd` to apply the workaround.

Add `mix_freebsd_pkg` as dependency:

  * Add `{:mix_freebsd_pkg, path: "../../mix_freebsd_pkg", runtime: Mix.env() == :dev}` 
    for this example residing within the `mix_freebsd_pkg` repo.
    In your own project, you'll want to follow the instructions in README of `mix_freebsd_pkg`.

Add required metadata to `mix.exs`:
  * Under `project`, add these two fields:
    - `description: "Awesome FreeBSD App",`
    - `maintainer: "your.name@example.com",`

Add an alias to build release and then a FreeBSD package:

  * Under `aliases` in `mix.exs`, add this line:
    - `"package.freebsd": ["compile", "assets.deploy", "release --overwrite", "freebsd.pkg"]`
  * You can change `package.freebsd` to any memorable word.

Create FreeBSD package:
  * Run `mix package.freebsd`

Install FreeBSD package:
  * Run `pkg install -U example-0.1.0.pkg`

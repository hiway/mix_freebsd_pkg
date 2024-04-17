# Mix FreeBSD Package

Mix Task to create FreeBSD package from an Elixir / Phoenix project.

> Status (17 Apr 2024): I'm currently implementing 
  the functionality described in the readme below. 
  Everything is in flux and you annot use this project to create packages just yet.
  It should be ready in a few days as I work on it here and there between 
  managing my small farm and a whole bunch of animals.


## Installation

The package can be installed by adding `mix_freebsd_pkg`
to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mix_freebsd_pkg, "~> 0.1.0", runtime: Mix.env() == :dev}
  ]
end
```


## Configuration

Add required metadata to `mix.exs`:

  * Under `project()`, add these fields:

```elixir
# mix.exs

  def project do
    [
      app: :example,
      ...
      description: "Awesome FreeBSD App",
      homepage_url: "https://example.com",
      maintainer: "your.name@example.com",
      ...
    ]
  end
```


## Usage

Create FreeBSD package:

  * Run `mix freebsd.pkg`


## Profit??

Install FreeBSD package:

  * Run `pkg install -U example-0.1.0.pkg`


## Customise


### Package name

  * Modify `project()` in `mix.exs` to add `freebsd_pkg: []` 
  * Add `pkg_name` with template as shown below or `<%= @name %>-latest.pkg`

```elixir
# mix.exs

  def project do
    [
      app: :example,
      ...
      freebsd_pkg: [
        # Add build env to name: "app_name-0.1.0-amd64-14.0-rel.pkg"
        pkg_name: "<%= @name %>-<%= @version %>-<%= @arch %><%= @freebsd_version_short %>.pkg"
      ]
    ]
  end
```


### Package dependencies

  * Modify `project()` in `mix.exs` to add `freebsd_pkg: []` 
  * Add dependencies under `freebsd_pkg[:deps]` 

```elixir
# mix.exs

  def project do
    [
      app: :example,
      ...
      freebsd_pkg: [
        deps: [
          {origin: "databases/sqlite3", version: "3.45.1,1"}
        ]
      ]
    ]
  end
```


### Configuration files

  * Modify `project()` in `mix.exs` to add `freebsd_pkg: []` 
  * Add `use_conf: true`
    * This will create a `<name>.conf.sample` file in project root dir
    * It is an EEx template that you can modify
    * Run `mix freebsd.render_conf` to generate a `<name>.conf` file in project root dir
    * The sample template will be installed at `/usr/local/etc/<name>.conf.sample`
      * It will be copied as `/usr/local/etc/<name>.conf`
      * Users can modify `/usr/local/etc/<name>.conf`
  * Another configuration file `<name>.env.sample` is automatically created 
    and installed with defaults to enable a phoenix project to run without modifications.
    * Add `use_env: false` to disable this behaviour
    * Adapt `config/runtime.exs` to work without environment variables

```elixir
# mix.exs

  def project do
    [
      app: :example,
      ...
      freebsd_pkg: [
        use_conf: true,  # default is false
        use_env: false  # default is true
      ]
    ]
  end
```


### Service user

By default the service is run as an unprivileged user created based on the app name.

  * Modify `project()` in `mix.exs` to add `freebsd_pkg: []`
  * Add `user` under `freebsd_pkg`
  * Group with the same name as user is automatically created

```elixir
# mix.exs

  def project do
    [
      app: :example,
      ...
      freebsd_pkg: [
        user: "example",
      ]
    ]
  end
```


### Service extra-commands

You can use built-in extra commands available via `service` on FreeBSD, or create your own.

  * Run `mix freebsd.command list` to see available extra commands

Available extra commands for service:

  * `init` - Generates secret_key_base and self-signed keys to enable https

To use a built-in extra command:

  * Run `mix freebsd.command use init` to create the template file at `priv/freebsd/service_init.sh.eex`
  * Modify `project()` in `mix.exs` to add `freebsd_pkg: []`
  * Add `service_commands` under `freebsd_pkg`.

```elixir
# mix.exs

  def project do
    [
      app: :example,
      ...
      freebsd_pkg: [
        service_commands: ["init"]
      ]
    ]
  end
```

To create a custom extra command:

  * Run `mix freebsd.command create <name>`

Then add it to `freebsd_pkg[:service][:commands]` as above.


### Override service, *-install scripts and configuration

Create a copy of built-in templates to modify them as needed:

  * Run `mix freebsd.template list` to see available templates.
  * Run `mix freebsd.template use post-install` to create a template in your project at `priv/freebsd/post-install.sh.eex`

Available templates for `mix freebsd.template <name>`:

  * `service`
  * `pre-install`
  * `post-install`
  * `pre-deinstall`
  * `post-deinstall`

Shortcut to customise all templates: `mix freebsd.template all`


### More metadata

  * Modify `project()` in `mix.exs` to add `freebsd_pkg: []`
  * Add the configuration values as needed (all optional)
  * Choose approprite category: https://docs.freebsd.org/en/books/porters-handbook/book/#makefile-categories

```elixir
# mix.exs

  def project do
    [
      app: :example,
      ...
      freebsd_pkg: [
        category: "devel",  # default is "misc"
        template_dir: "priv/templates/pkg", # default is "priv/freebsd"
      ]
    ]
  end
```
# Mix FreeBSD Package

Mix Task to create FreeBSD package from an Elixir / Phoenix project.


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

Add required metadata to `confix.exs`:

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
        # Add build env to name: "app_name-0.1.0-amd64-14.0-rel-p6.pkg"
        pkg_name: "<%= @name %>-<%= @version %>-<%= @arch %><%= @freebsd_version %>.pkg"
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
  * Add `service` under `freebsd_pkg`.
  * Add `commands` under `service`

```elixir
# mix.exs

  def project do
    [
      app: :example,
      ...
      freebsd_pkg: [
        service: [
          commands: ["init"]
        ]
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
  * `env`
  * `conf`

Shortcut to customise all templates: `mix freebsd.template all`

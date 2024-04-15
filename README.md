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
  * Add `rename_pkg` with a template as shown below or `<%= @app_name %>-latest`

```elixir
# mix.exs

  def project do
    [
      app: :example,
      ...
      freebsd_pkg: [
        # Explicit build env: "app_name-0.1.0-amd64-14.0-rel-p6.pkg"
        rename_pkg: "<%= @app_name %>-<%= @app_version %>-<%= @arch %><%= @freebsd_version %>.pkg"
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
          {"sqlite3", version: "3.45.1,1"}
        ]
      ]
    ]
  end
```


### Service user/ groups

By default the service is run as a unprivileged user created based on the app name.

  * Modify `project()` in `mix.exs` to add `freebsd_pkg: []`
  * Add `user` and/or `groups` under `freebsd_pkg`. 
  * Group with the same name as user is automatically created if missing.
  * The `groups` section specifies any extra groups the user must be a member.
  * The extra groups must already exist on the system, think `www`, `operator`, `wheel` etc.
  * You can omit `user` if default is fine and only specify `groups`.
  * You can omit `groups` if not needed and only specify user name.

```elixir
# mix.exs

  def project do
    [
      app: :example,
      ...
      freebsd_pkg: [
        user: "example",
        groups: ["www"]
      ]
    ]
  end
```

### Service commands

You can use built-in extra commands available via the service cli on FreeBSD, or create your own.

  * Run `mix freebsd.command list` to see available commands.
  * Run `mix freebsd.command use` to use one of the available commands.
  * Run `mix freebsd.command add` to create a custom service command.

Available extra commands for service:

  * `init` - Generates secret_key_base and self-signed keys to enable https

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

# Mix FreeBSD Package

Mix Task to create FreeBSD package from an Elixir / Phoenix project.

> Status (18 Apr 2024): Works as advertised below, but tested on only my machine.
  Give it a whirl, submit any bug reports and if you're up for it, pull requests to fix.

## Installation

The package can be installed by adding `mix_freebsd_pkg`
to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mix_freebsd_pkg, github: "hiway/mix_freebsd_pkg", runtime: Mix.env() == :dev}
  ]
end
```


## Configuration

Add required metadata to `mix.exs`:

  * Under `project`, add these fields:

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

Add an alias to build release and then a FreeBSD package:

  * Under `aliases` in `mix.exs`, add this line:
    - `"package.freebsd": ["compile", "assets.deploy", "release --overwrite", "freebsd.pkg"]`
  * You can change `package.freebsd` to any memorable word.

```elixir
# mix.exs 

  defp aliases do
    [
      ...
      "package.freebsd": ["compile", "assets.deploy", "release --overwrite", "freebsd.pkg"]
    ]
  end

```

## Usage

Create FreeBSD package:

  * Run `env MIX_ENV=prod mix package.freebsd`


## Profit??

Install FreeBSD package:

  * Run `pkg install -U example-0.1.0.pkg`


## Customise


### Package name

  * Modify `project` in `mix.exs` to add `freebsd_pkg: []` 
  * Add `pkg_name` with template as shown below or a simple `<%= @name %>-latest.pkg`

```elixir
# mix.exs

  def project do
    [
      app: :example,
      ...
      freebsd_pkg: [
        # "app_name-0.1.0-amd64-14.0-rel.pkg"
        pkg_name: "<%= @name %>-<%= @version %>-<%= @arch %>-<%= @freebsd_version_short %>.pkg"
      ]
    ]
  end
```


### Package dependencies

  * Modify `project` in `mix.exs` to add `freebsd_pkg: []` 
  * Add dependencies under `freebsd_pkg[:deps]` 

```elixir
# mix.exs

  def project do
    [
      app: :example,
      ...
      freebsd_pkg: [
        deps: %{
          "sqlite3" => %{origin: "databases/sqlite3", version: "3.45.1,1"}
        }
      ]
    ]
  end
```


### Configuration files

  * Modify `project` in `mix.exs` to add `freebsd_pkg: []` 
  * Add `use_conf: true`
    * This will create a `<name>.conf.sample` file in project root dir
    * It is an EEx template that you can modify
    * Run `mix freebsd.render conf` to generate a `<name>.conf.sample` file in project root dir
    * The sample template will be installed at `/usr/local/etc/<name>.conf.sample`
      * It will be copied as `/usr/local/etc/<name>.conf`
      * Users can modify `/usr/local/etc/<name>.conf`
  * Another configuration file `<name>.env.sample` is automatically created 
    and installed with defaults to enable a Phoenix project to run without modifications.
    * Add `use_env: false` to disable this behaviour
    * Delete the generated `<name>.env.sample` file (can be added with `mix freebsd.render conf`)
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

  * Modify `project` in `mix.exs` to add `freebsd_pkg: []`
  * Add `user` under `freebsd_pkg`
  * Group with the same name as user is automatically created
  * Specify `group` if default behaviour is not suitable

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

The commands can be run as `service <name> <command>`

Available extra commands for service:

  * `init` - Generates secret_key_base and self-signed keys to enable https

To use a built-in extra command:

  * Modify `project` in `mix.exs` to add `freebsd_pkg: []`
  * Add `service_commands` under `freebsd_pkg`.
  * Add `init` under `service_commands`
  * Run `mix freebsd.render service_commands`
    * Creates the template file at `priv/freebsd/service_init.sh.eex`

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

  * Add the preferred name to `freebsd_pkg[:service][:service_commands]` as above.
  * Run `mix freebsd.render service_commands`


### Override service and *-install scripts

Available templates:

  * `service`
  * `pre-install`
  * `post-install`
  * `pre-deinstall`
  * `post-deinstall`

Run `mix freebsd.render service` etc.

Shortcut to render all above templates: `mix freebsd.render all`

These files are automatically generated at the time of creating package 
if you've not already rendered and customized them.

### More metadata

  * Modify `project` in `mix.exs` to add `freebsd_pkg: []`
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
# Mix FreeBSD Package

Elixir Mix Task to create FreeBSD package from an Elixir / Phoenix project.


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
  * Under `project()`, add these two fields:
    - `description: "Awesome FreeBSD App",`
    - `maintainer: "your.name@example.com",`

## Usage

Create FreeBSD package:
  * Run `mix freebsd.pkg`

## Profit??

Install FreeBSD package:
  * Run `pkg install -U example-0.1.0.pkg`

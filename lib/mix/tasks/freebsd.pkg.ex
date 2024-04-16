defmodule Mix.Tasks.Freebsd.Pkg do
  @moduledoc """

  """
  use Mix.Task
  alias MixFreebsdPkg.Config
  alias MixFreebsdPkg.Pkg
  alias MixFreebsdPkg.Platform
  alias MixFreebsdPkg.Templates

  def run(_) do
    if Platform.freebsd?() do
      config = Config.config()
      templates = Templates.render(config)
      _pkg_name = Pkg.create(config, templates)
      IO.inspect(config)
      # Mix.shell().info("Package created: #{pkg_name}")
    else
      Mix.shell().error("This task is only available on FreeBSD.")
    end
  end
end

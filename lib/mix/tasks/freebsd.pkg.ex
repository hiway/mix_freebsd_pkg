defmodule Mix.Tasks.Freebsd.Pkg do
  @moduledoc """

  """
  use Mix.Task
  alias MixFreebsdPkg.Config
  alias MixFreebsdPkg.Pkg
  alias MixFreebsdPkg.Platform
  alias MixFreebsdPkg.Template

  def run(_) do
    if Platform.freebsd?() do
      config = Config.config()
      templates = Template.render(config)
      pkg_file = Pkg.create(config, templates)
      Mix.shell().info("Created #{inspect(pkg_file)}")
    else
      Mix.shell().error("This task is only available on FreeBSD.")
    end
  end
end

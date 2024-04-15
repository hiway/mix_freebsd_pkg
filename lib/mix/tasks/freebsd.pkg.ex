defmodule Mix.Tasks.Freebsd.Pkg do
  @moduledoc """

  """
  use Mix.Task

  def run(_) do
    if MixFreebsdPkg.Platform.freebsd?() do
      Mix.shell().info("Hello from freebsd.pkg!")
    else
      Mix.shell().error("This task is only available on FreeBSD.")
    end
  end
end

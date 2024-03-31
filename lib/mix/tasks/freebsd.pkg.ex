defmodule Mix.Tasks.Freebsd.Pkg do
  use Mix.Task

  @impl Mix.Task
  @spec run(OptionParser.argv()) :: nil
  def run(argv) do
    if MixFreebsdPkg.Platform.freebsd?() do
      config = MixFreebsdPkg.config(argv)
      IO.inspect(config)
    else
      IO.puts("Please run this task on FreeBSD.")
    end
  end
end

defmodule Mix.Tasks.Freebsd.Pkg do
  use Mix.Task

  @impl Mix.Task
  @spec run(OptionParser.argv()) :: nil
  def run(argv) do
    if MixFreebsdPkg.freebsd?() do
      config = MixFreebsdPkg.merge_config_with_argv(argv)
      IO.inspect(config)
    else
      IO.puts("Please run this task on FreeBSD.")
    end
  end
end

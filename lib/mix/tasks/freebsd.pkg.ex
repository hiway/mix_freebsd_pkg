defmodule Mix.Tasks.Freebsd.Pkg do
  use Mix.Task

  @impl Mix.Task
  @spec run(OptionParser.argv()) :: nil
  def run(args) do
    if Mix.Tasks.Freebsd.freebsd?() do
      config = Mix.Tasks.Freebsd.parse_args(args)
      IO.inspect(config)
    else
      IO.puts("Please run this task on FreeBSD.")
    end
  end
end

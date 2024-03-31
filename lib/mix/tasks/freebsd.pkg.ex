defmodule Mix.Tasks.Freebsd.Pkg do
  use Mix.Task
  alias MixFreebsdPkg.Config
  alias MixFreebsdPkg.Platform
  alias MixFreebsdPkg.Templates

  @impl Mix.Task
  @spec run(OptionParser.argv()) :: :ok
  def run(argv) do
    if Platform.freebsd?() do
      config = Config.config(argv)
      # IO.inspect(config)

      service_rc = Templates.Service.render(config)
      IO.puts("\nService rc file: \n\n#{service_rc}\n")

      conf_files = Templates.ConfFile.render(config)
      IO.inspect(conf_files)
    else
      IO.puts("Please run this task on FreeBSD.")
    end
  end
end

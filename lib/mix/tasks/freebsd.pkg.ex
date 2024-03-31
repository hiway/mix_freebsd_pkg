defmodule Mix.Tasks.Freebsd.Pkg do
  use Mix.Task

  @impl Mix.Task
  @spec run(OptionParser.argv()) :: :ok
  def run(argv) do
    if MixFreebsdPkg.Platform.freebsd?() do
      config = MixFreebsdPkg.Config.config(argv)
      # IO.inspect(config)

      service_rc = MixFreebsdPkg.Templates.Service.render(config)
      IO.puts("\nService rc file: \n\n#{service_rc}\n")

      conf_files = MixFreebsdPkg.Templates.ConfFile.render(config)
      IO.inspect(conf_files)
    else
      IO.puts("Please run this task on FreeBSD.")
    end
  end
end

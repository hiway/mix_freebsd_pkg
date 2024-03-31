defmodule Mix.Tasks.Freebsd.Pkg do
  use Mix.Task

  @impl Mix.Task
  @spec run(OptionParser.argv()) :: :ok
  def run(argv) do
    if MixFreebsdPkg.Platform.freebsd?() do
      config = MixFreebsdPkg.Config.config(argv)
      # IO.inspect(config)

      service_rc = MixFreebsdPkg.Service.default_rc(config)
      IO.puts("\nService rc file: \n\n#{service_rc}\n")

      conf_files = config[:conf_files]

      conf_files = conf_files
      |> Enum.map(fn conf_file ->
        conf_file_content = MixFreebsdPkg.Templates.ConfFile.render(config, conf_file)
        %{name: conf_file |> Path.basename(), content: conf_file_content}
      end)

      IO.inspect(conf_files)
    else
      IO.puts("Please run this task on FreeBSD.")
    end
  end
end

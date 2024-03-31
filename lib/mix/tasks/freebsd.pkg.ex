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

      # service_rc = Templates.Service.render(config)
      # IO.puts("\nService rc file: \n\n#{service_rc}\n")

      # conf_files = Templates.ConfFile.render(config)
      # IO.inspect(conf_files)

      pre_install_script = Templates.InstallScript.render(config, config[:pre_install])
      IO.puts("\nPre-install script: \n\n#{pre_install_script}\n")

      post_install_script = Templates.InstallScript.render(config, config[:post_install])
      IO.puts("\nPost-install script: \n\n#{post_install_script}\n")

      pre_deinstall_script = Templates.InstallScript.render(config, config[:pre_deinstall])
      IO.puts("\nPre-deinstall script: \n\n#{pre_deinstall_script}\n")

      post_deinstall_script = Templates.InstallScript.render(config, config[:post_deinstall])
      IO.puts("\nPost-deinstall script: \n\n#{post_deinstall_script}\n")
    else
      IO.puts("Please run this task on FreeBSD.")
    end
  end
end

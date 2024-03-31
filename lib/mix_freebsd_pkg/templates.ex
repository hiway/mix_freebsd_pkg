defmodule MixFreebsdPkg.Templates do
  @app :mix_freebsd_pkg

  def ensure_template_exists(
        templates_dir,
        template_name,
        config_template_path,
        pkg_template_path
      ) do
    if config_template_path != nil do
      if File.exists?(config_template_path) do
        config_template_path
      else
        raise """
        Template file not found: #{config_template_path}
        """
      end
    else
      app_template = Path.join([templates_dir, template_name])

      if File.exists?(app_template) do
        app_template
      else
        lib_dir = Application.app_dir(@app, ["priv", "templates"])
        lib_template = Path.join([lib_dir, template_name])

        if File.exists?(lib_template) do
          File.mkdir_p!(templates_dir)
          File.cp!(lib_template, app_template)
          app_template
        else
          if pkg_template_path != nil and File.exists?(pkg_template_path) do
            File.mkdir_p!(templates_dir)
            File.cp!(pkg_template_path, app_template)
            app_template
          else
            raise """
            Template file not found: #{app_template}
            """
          end
        end
      end
    end
  end
end

defmodule MixFreebsdPkg.Templates.ConfFile do
  def render(config) do
    config[:conf_files]
      |> Enum.map(fn conf_file ->
        conf_file_content = conf_file |> EEx.eval_file(assigns: %{config: config})
        %{name: conf_file |> Path.basename(), content: conf_file_content}
      end)
  end
end

defmodule MixFreebsdPkg.Templates.Service do
  @spec render(MixFreebsdPkg.Config.t()) :: String.t()
  def render(config) do
    rc_template = config[:rc_template]
    rc_template |> EEx.eval_file(assigns: %{config: config})
  end
end

defmodule MixFreebsdPkg.Templates.InstallScript do
  @spec render(MixFreebsdPkg.Config.t(), String.t()) :: String.t()
  def render(config, install_script_name) do
    Mix.shell().info("Rendering install script: #{install_script_name}")
    install_script_name |> EEx.eval_file(assigns: %{config: config})
  end
end

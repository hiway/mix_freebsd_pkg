defmodule MixFreebsdPkg.Template do
  def render(config) do
    %{
      service: render_service(config),
      service_commands: render_service_commands(config),
      conf: render_conf(config),
      env: render_env(config),
      pre_install: render_pre_install(config),
      post_install: render_post_install(config),
      pre_deinstall: render_pre_deinstall(config),
      post_deinstall: render_post_deinstall(config)
    }
  end

  def render_service(config) do
    case MixFreebsdPkg.Template.Pipeline.call(%{
           name: "service",
           project_path: config.service_template,
           library_path: config.lib_service_template,
           config: config
         }) do
      {:ok, service} ->
        service

      {:error, reason} ->
        raise "Failed to render service template: #{IO.inspect(reason)}"
    end
  end

  def render_service_commands(config) do
    config.service_commands
    |> Enum.map(fn command ->
      project_path = config.service_command_templates |> List.keyfind(command, 0) |> elem(1)
      library_path = config.lib_service_command_templates |> List.keyfind(command, 0) |> elem(1)
      case MixFreebsdPkg.Template.Pipeline.call(%{
             name: command,
             project_path: project_path,
             library_path: library_path,
             config: config |> Map.put(:skip_library_path, true)
           }) do
        {:ok, service_command} ->
          {command, service_command}

        {:error, reason} ->
          raise "Failed to render service command template: #{IO.inspect(reason)}"
      end
    end)
  end

  def render_pre_install(config) do
    case MixFreebsdPkg.Template.Pipeline.call(%{
           name: "pre-install",
           project_path: config.pre_install_template,
           library_path: config.lib_pre_install_template,
           config: config
         }) do
      {:ok, pre_install} ->
        pre_install

      {:error, reason} ->
        raise "Failed to render service template: #{IO.inspect(reason)}"
    end
  end

  def render_post_install(config) do
    case MixFreebsdPkg.Template.Pipeline.call(%{
           name: "post-install",
           project_path: config.post_install_template,
           library_path: config.lib_post_install_template,
           config: config
         }) do
      {:ok, post_install} ->
        post_install

      {:error, reason} ->
        raise "Failed to render service template: #{IO.inspect(reason)}"
    end
  end

  def render_pre_deinstall(config) do
    case MixFreebsdPkg.Template.Pipeline.call(%{
           name: "pre-deinstall",
           project_path: config.pre_deinstall_template,
           library_path: config.lib_pre_deinstall_template,
           config: config
         }) do
      {:ok, pre_deinstall} ->
        pre_deinstall

      {:error, reason} ->
        raise "Failed to render service template: #{IO.inspect(reason)}"
    end
  end

  def render_post_deinstall(config) do
    case MixFreebsdPkg.Template.Pipeline.call(%{
           name: "post-deinstall",
           project_path: config.post_deinstall_template,
           library_path: config.lib_post_deinstall_template,
           config: config
         }) do
      {:ok, post_deinstall} ->
        post_deinstall

      {:error, reason} ->
        raise "Failed to render service template: #{IO.inspect(reason)}"
    end
  end

  def render_env(config) do
    case config.use_env do
      true ->
        case MixFreebsdPkg.Template.Pipeline.call(%{
               name: "env",
               project_path: config.env_template,
               library_path: config.lib_env_template,
               config: config
             }) do
          {:ok, env} ->
            env

          {:error, reason} ->
            raise "Failed to render service template: #{IO.inspect(reason)}"
        end

      false ->
        ""
    end
  end

  def render_conf(config) do
    case config.use_conf do
      true ->
        case MixFreebsdPkg.Template.Pipeline.call(%{
               name: "conf",
               project_path: config.conf_template,
               library_path: config.lib_conf_template,
               config: config
             }) do
          {:ok, conf} ->
            conf

          {:error, reason} ->
            raise "Failed to render service template: #{IO.inspect(reason)}"
        end

      false ->
        ""
    end
  end
end

defmodule MixFreebsdPkg.Template.Pipeline do
  use Opus.Pipeline

  check(:template_exists_in_library, unless: & &1.skip_library_path)

  # step(:generate_empty_template, if: & &1.skip_library_path != nil)
  # , if: & &1.skip_library_path)
  step(:ensure_template_exists_in_project)
  step(:render_template)

  def template_exists_in_library(%{
        name: _name,
        project_path: _project_path,
        library_path: library_path,
        config: _config
      }) do
    File.exists?(library_path)
  end

  def ensure_template_exists_in_project(%{
        name: name,
        project_path: project_path,
        library_path: library_path,
        config: config
      }) do
    case File.exists?(project_path) do
      true ->
        %{name: name, project_path: project_path, library_path: library_path, config: config}

      false ->
        File.mkdir_p!(Path.dirname(project_path))

        case File.cp(library_path, project_path) do
          :ok ->
            %{name: name, project_path: project_path, library_path: library_path, config: config}

          {:error, _} ->
            if config.skip_library_path do
              Mix.shell().error(
                "Template #{name} does not exist in project. Generating empty template."
              )

              File.write!(project_path, "# #{name}")

              %{
                name: name,
                project_path: project_path,
                library_path: library_path,
                config: config
              }
            else
              {:error, "Failed to copy template #{name} to project"}
            end
        end
    end
  end

  def generate_empty_template(%{
        name: name,
        project_path: project_path,
        library_path: library_path,
        config: config
      }) do
    Mix.shell().error(
      "Template #{name} does not exist in project or library. Generating empty template."
    )

    File.write!(project_path, "# #{name}")

    %{name: name, project_path: project_path, library_path: library_path, config: config}
  end

  def render_template(%{
        name: _name,
        project_path: project_path,
        library_path: _library_path,
        config: config
      }) do
    EEx.eval_file(project_path, assigns: config)
  end
end

defmodule MixFreebsdPkg.Pkg do
  @moduledoc """

  """

  @spec create(map, map) :: String.t()
  def create(config, templates) do
    case MixFreebsdPkg.Pkg.Pipeline.call(%{
           config: config,
           templates: templates
         }) do
      {:ok, pkg_file} ->
        pkg_file

      {:error, reason} ->
        raise "Failed to create package: #{IO.inspect(reason)}"
    end
  end

  @spec manifest(map, map) :: String.t()
  def manifest(config, templates) do
    manifest = %{
      name: config.name,
      version: config.version,
      origin: "#{config.category}/#{config.name}",
      comment: config.description,
      www: config.homepage_url,
      maintainer: config.maintainer,
      prefix: config.prefix,
      desc: config.description,
      users: [config.user],
      groups: [config.group],
      scripts: %{
        "pre-install" => templates.pre_install,
        "post-install" => templates.post_install,
        "pre-deinstall" => templates.pre_deinstall,
        "post-deinstall" => templates.post_deinstall
      }
    }

    manifest = manifest |> deps(config.deps)
    Jason.encode!(manifest)
  end

  @spec deps(map, map) :: map
  def deps(manifest, deps) do
    if deps do
      manifest |> Map.put(:deps, deps)
    else
      manifest
    end
  end

  @spec release_files(map) :: Stream.t()
  def release_files(config) do
    "#{config.stage_dir}/**/*"
    |> Path.wildcard()
    |> Stream.filter(&Enum.member?([:regular, :symlink], File.lstat!(&1).type))
    |> Stream.map(&String.replace(&1, "#{config.stage_dir}#{config.prefix}/", ""))
    |> Stream.map(&add_plist_mode(&1, config))
  end

  defp add_plist_mode(path, config) do
    if String.ends_with?(path, ".sh") do
      "@(,,0755) #{path}"
    else
      case String.split(path, "/") do
        ["etc", "rc.d" | _] -> "@(,,0755) #{path}"
        ["etc" | _] -> "@sample(,,0644) #{path}"
        ["libexec" | _] -> "@(#{config.user},#{config.group},) #{path}"
        _ -> path
      end
    end
  end
end

defmodule MixFreebsdPkg.Pkg.Pipeline do
  use Opus.Pipeline

  step(:clean_package_build_dir)
  step(:create_dir_structure)
  step(:copy_release_to_stage)
  step(:write_conf_file_to_stage, if: & &1.config.use_conf)
  step(:write_env_file_to_stage, if: & &1.config.use_env)
  step(:write_service_file_to_stage)
  step(:write_service_command_files_to_stage)
  step(:write_manifest_to_build_pkg_dir)
  step(:write_plist_to_build_pkg_dir)
  step(:build_package)

  def clean_package_build_dir(%{config: config, templates: templates}) do
    # Mix.shell().info("Cleaning package build directory: #{config.build_pkg_dir}")

    File.rm_rf!(config.build_pkg_dir)
    File.mkdir_p!(config.build_pkg_dir)

    %{config: config, templates: templates}
  end

  def create_dir_structure(%{config: config, templates: templates}) do
    # Mix.shell().info("Creating package directory structure")

    File.mkdir_p!(config.stage_dir)
    File.mkdir_p!(config.stage_app_dir)
    File.mkdir_p!(config.stage_conf_dir)
    File.mkdir_p!(config.stage_service_dir)
    File.mkdir_p!(config.stage_data_dir)
    File.mkdir_p!(config.stage_log_dir)
    File.mkdir_p!(config.stage_run_dir)

    %{config: config, templates: templates}
  end

  def copy_release_to_stage(%{config: config, templates: templates}) do
    # Mix.shell().info("Copying release to stage directory: #{config.stage_app_dir}")

    File.cp_r!(config.build_rel_dir, config.stage_app_dir)

    %{config: config, templates: templates}
  end

  def write_conf_file_to_stage(%{config: config, templates: templates}) do
    # Mix.shell().info("Writing configuration file to stage directory: #{config.stage_conf_dir}")

    File.write!(config.stage_conf_file, templates.conf)

    %{config: config, templates: templates}
  end

  def write_env_file_to_stage(%{config: config, templates: templates}) do
    # Mix.shell().info("Writing environment file to stage directory: #{config.stage_conf_dir}")

    File.write!(config.stage_env_file, templates.env)

    %{config: config, templates: templates}
  end

  def write_service_file_to_stage(%{config: config, templates: templates}) do
    # Mix.shell().info("Writing service file to stage directory: #{config.stage_service_dir}")

    File.write!(config.stage_service_file, templates.service)

    %{config: config, templates: templates}
  end

  def write_service_command_files_to_stage(%{config: config, templates: templates}) do
    # Mix.shell().info("Writing service command files to stage directory: #{config.stage_app_dir}")

    Enum.each(templates.service_commands, fn {name, content} ->
      File.write!(Path.join([config.stage_app_dir, "#{name}.sh"]), content)
    end)

    %{config: config, templates: templates}
  end

  def write_manifest_to_build_pkg_dir(%{config: config, templates: templates}) do
    # Mix.shell().info("Writing manifest file to stage directory: #{config.stage_dir}")

    File.write!(
      Path.join([config.build_pkg_dir, "manifest.json"]),
      MixFreebsdPkg.Pkg.manifest(config, templates)
    )

    %{config: config, templates: templates}
  end

  def write_plist_to_build_pkg_dir(%{config: config, templates: templates}) do
    # Mix.shell().info("Writing plist file to stage directory: #{config.stage_dir}")
    plist_file_path = Path.join([config.build_pkg_dir, "pkg-plist"])

    # Include directories outside of prefix
    # TODO: Set ownership and permissions
    # https://docs.freebsd.org/en/books/porters-handbook/plist/#plist-cleaning
    extra__dirs = [
      "@dir(#{config.user},#{config.group},0755) #{config.data_dir}",
      "@dir(#{config.user},#{config.group},0755) #{config.log_dir}",
      "@dir(#{config.user},#{config.group},0755) #{config.run_dir}"
    ]

    File.write!(plist_file_path, extra__dirs |> Enum.join("\n"))
    File.write!(plist_file_path, "\n", [:append])

    plist_file = File.stream!(plist_file_path, [:append])

    :ok =
      MixFreebsdPkg.Pkg.release_files(config)
      |> Stream.map(&"#{&1}\n")
      |> Stream.into(plist_file)
      |> Stream.run()

    %{config: config, templates: templates}
  end

  def build_package(%{config: config, templates: _templates}) do
    package_name = EEx.eval_string(config.package_name, assigns: config)
    Mix.shell().info("Building package: #{package_name}")

    pkg_args = [
      "create",
      "-M",
      "#{config.build_pkg_dir}/manifest.json",
      "-r",
      "#{config.stage_dir}",
      "-p",
      "#{config.build_pkg_dir}/pkg-plist"
    ]

    case System.cmd("pkg", pkg_args) do
      {_, 0} ->
        File.rename!(config.package_name_default, package_name)
        package_name

      {output, _} ->
        {:error, error: output}
    end
  end
end

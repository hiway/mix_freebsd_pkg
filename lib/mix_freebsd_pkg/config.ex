defmodule MixFreebsdPkg.Config do
  @moduledoc """
  Builds and returns a map with configuration
  values from various sources populated and validated.
  """

  # alias MixFreebsdPkg.Platform

  @spec config() :: map
  def config() do
    # arch = Platform.arch()
    # freebsd_version = Platform.freebsd_version()
    # freebsd_version_short = Platform.freebsd_version_short()

    mix_config = Mix.Project.config()
    pkg_config = mix_config[:freebsd_pkg] || %{}

    name = mix_config[:app] |> to_string()
    version = mix_config[:version]

    prefix = "/usr/local"
    app_dir = Path.join([prefix, "libexec", name])
    conf_dir = Path.join([prefix, "etc", name])
    service_dir = Path.join([prefix, "etc/rc.d"])
    data_dir = Path.join(["/var/db", name])
    log_dir = Path.join(["/var/log", name])
    run_dir = Path.join(["/var/run", name])

    build_dir = Path.join(["_build", to_string(Mix.env())])
    build_rel_dir = Path.join([build_dir, "rel", name])
    build_pkg_dir = Path.join(["_build", "pkg"])

    stage_dir = Path.join([build_pkg_dir, "stage"])
    stage_app_dir = Path.join([stage_dir, app_dir])
    stage_conf_dir = Path.join([stage_dir, conf_dir])
    stage_service_dir = Path.join([stage_dir, service_dir])
    stage_data_dir = Path.join([stage_dir, data_dir])
    stage_log_dir = Path.join([stage_dir, log_dir])
    stage_run_dir = Path.join([stage_dir, run_dir])

    template_dir = pkg_config[:template_dir] || Path.join(["priv", "freebsd"])

    lib_template_dir =
      Application.app_dir(:mix_freebsd_pkg, ["priv", "templates"])
      |> Path.relative_to(File.cwd!())

    config = %{
      name: name,
      version: version,
      description: mix_config[:description],
      homepage_url: mix_config[:homepage_url],
      maintainer: mix_config[:maintainer],
      category: pkg_config[:category] || "misc",
      user: pkg_config[:user] || name,
      group: pkg_config[:group] || name,
      deps: mix_config[:deps] || [],
      service_commands: pkg_config[:service_commands] || [],

      # Paths for installation
      prefix: prefix,
      app_dir: app_dir,
      conf_dir: conf_dir,
      service_dir: service_dir,
      data_dir: data_dir,
      log_dir: log_dir,
      run_dir: run_dir,
      env_file: Path.join([conf_dir, "#{name}.env"]),
      conf_file: Path.join([conf_dir, "#{name}.conf"]),
      service_file: Path.join([service_dir, name]),

      # Build directories
      build_dir: build_dir,
      build_rel_dir: build_rel_dir,
      build_pkg_dir: build_pkg_dir,

      # Stage directories
      stage_dir: stage_dir,
      stage_app_dir: stage_app_dir,
      stage_conf_dir: stage_conf_dir,
      stage_service_dir: stage_service_dir,
      stage_data_dir: stage_data_dir,
      stage_log_dir: stage_log_dir,
      stage_run_dir: stage_run_dir,
      stage_env_file: Path.join([stage_conf_dir, "#{name}.env"]),
      stage_conf_file: Path.join([stage_conf_dir, "#{name}.conf"]),
      stage_service_file: Path.join([stage_service_dir, name]),

      # Project templates
      template_dir: template_dir,
      env_template: Path.join(["#{name}.env.sample"]),
      conf_template: Path.join(["#{name}.conf.sample"]),
      service_template: Path.join([template_dir, "service.sh.eex"]),
      pre_install_template: Path.join([template_dir, "pre-install.sh.eex"]),
      post_install_template: Path.join([template_dir, "post-install.sh.eex"]),
      pre_deinstall_template: Path.join([template_dir, "pre-deinstall.sh.eex"]),
      post_deinstall_template: Path.join([template_dir, "post-deinstall.sh.eex"]),

      # Source templates (used to fill in the project templates)
      lib_template_dir: lib_template_dir,
      lib_env_template: Path.join([lib_template_dir, "config.env.sample.eex"]),
      lib_conf_template: Path.join([lib_template_dir, "config.conf.sample.eex"]),
      lib_service_template: Path.join([lib_template_dir, "service.sh.eex"]),
      lib_pre_install_template: Path.join([lib_template_dir, "pre-install.sh.eex"]),
      lib_post_install_template: Path.join([lib_template_dir, "post-install.sh.eex"]),
      lib_pre_deinstall_template: Path.join([lib_template_dir, "pre-deinstall.sh.eex"]),
      lib_post_deinstall_template: Path.join([lib_template_dir, "post-deinstall.sh.eex"]),
    }

    case MixFreebsdPkg.Config.Pipeline.call(config) do
      {:ok, result} -> result |> Enum.sort()
      {:error, reason} -> Mix.shell().error("Failed to create package: #{inspect(reason.error)}")
    end
  end
end

defmodule MixFreebsdPkg.Config.Pipeline do
  use Opus.Pipeline

  check(:config_has_name,
    with: &(String.trim(&1.name) not in [nil, ""])
  )

  check(:config_has_version,
    with: &(String.trim(&1.version) not in [nil, ""])
  )

  check(:config_has_description,
    with: &(String.trim(&1.description) not in [nil, ""])
  )

  check(:config_has_homepage_url,
    with: &(String.trim(&1.homepage_url) not in [nil, ""])
  )

  check(:config_has_maintainer,
    with: &(String.trim(&1.maintainer) not in [nil, ""])
  )

  check(:config_has_category,
    with: &(String.trim(&1.category) not in [nil, ""])
  )
end

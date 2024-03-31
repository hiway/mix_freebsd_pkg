defmodule MixFreebsdPkg do
  @moduledoc """
  Documentation for `MixFreebsdPkg`.
  """
  @app :mix_freebsd_pkg

  @spec merge_config_with_argv(OptionParser.argv()) :: Keyword.t()
  def merge_config_with_argv(argv) do
    options = [
      strict: [
        name: :string,
        version: :string,
        description: :string,
        homepage_url: :string,
        maintainer: :string,
        comment: :string,
        # requires: :list,
        user: :string,
        user_id: :integer,
        group: :string,
        group_id: :integer,
        # groups: :list,
        app_dir: :string,
        data_dir: :string,
        run_dir: :string,
        log_dir: :string,
        # log_files: :list,
        conf_dir: :string,
        # conf_files: :list,
        # port_acl_tcp: :list,
        # port_acl_udp: :list,
        rc_script: :string,
        rc_template: :string,
        # rc_extra_commands: :list,
        pre_install: :string,
        post_install: :string,
        pre_deinstall: :string,
        post_deinstall: :string,
        pkg_file: :string
      ]
    ]

    {overrides, _} = OptionParser.parse!(argv, options)
    mix_config = Mix.Project.config()
    create_config(mix_config, overrides)
  end

  @spec create_config(Keyword.t(), Keyword.t()) :: Keyword.t()
  defp create_config(mix_config, overrides) do
    name = mix_config[:app] |> to_string()
    templates_dir = Path.join(["priv", "freebsd_pkg"])

    validate_config(mix_config[:description], "description", "description: \"Example Package\"")

    validate_config(
      mix_config[:homepage_url],
      "homepage_url",
      "homepage_url: \"https://example.com\""
    )

    validate_config(
      mix_config[:mix_freebsd_pkg][:maintainer],
      "mix_freebsd_pkg[:maintainer]",
      "mix_freebsd_pkg: [\n\tmaintainer: \"maintainer@example.com\"\n\t]"
    )

    pre_install_template =
      ensure_template_exists(
        templates_dir,
        "pre_install.sh",
        mix_config[:mix_freebsd_pkg][:pre_install]
      )

    post_install_template =
      ensure_template_exists(
        templates_dir,
        "post_install.sh",
        mix_config[:mix_freebsd_pkg][:post_install]
      )

    pre_deinstall_template =
      ensure_template_exists(
        templates_dir,
        "pre_deinstall.sh",
        mix_config[:mix_freebsd_pkg][:pre_deinstall]
      )

    post_deinstall_template =
      ensure_template_exists(
        templates_dir,
        "post_deinstall.sh",
        mix_config[:mix_freebsd_pkg][:post_deinstall]
      )

    defaults = [
      name: name,
      version: mix_config[:version],
      description: mix_config[:description],
      homepage_url: mix_config[:homepage_url],
      maintainer: mix_config[:mix_freebsd_pkg][:maintainer],
      comment: mix_config[:mix_freebsd_pkg][:comment] || mix_config[:description],
      # https://docs.freebsd.org/en/books/porters-handbook/book/#porting-categories
      category: "www",
      # https://docs.freebsd.org/en/books/porters-handbook/book/#porting-prefix
      prefix: "/usr/local",
      requires: [],
      user: name,
      user_id: nil,
      group: name,
      group_id: nil,
      groups: [],
      # https://docs.freebsd.org/en/books/handbook/basics/#dirstructure
      app_dir: Path.join(["/usr/local/libexec", name]),
      data_dir: Path.join(["/var/db", name]),
      run_dir: Path.join(["/var/run", name]),
      log_dir: Path.join(["/var/log", name]),
      log_files: [
        Path.join(["/var/log", name, "#{name}.log"])
      ],
      conf_dir: Path.join(["/usr/local/etc", name]),
      conf_files: [
        "#{name}.env.sample"
      ],
      port_acl_tcp: [],
      port_acl_udp: [],
      rc_script: Path.join(["/usr/local/etc/rc.d", name]),
      rc_template: Path.join([templates_dir, "zycelium.sh"]),
      rc_extra_commands: [
        init: Path.join([templates_dir, "init.sh"])
      ],
      pre_install: pre_install_template,
      post_install: post_install_template,
      pre_deinstall: pre_deinstall_template,
      post_deinstall: post_deinstall_template,
      pkg_file: "#{name}-#{mix_config[:version]}.pkg",
      freebsd_version: freebsd_version(),
      arch: arch()
    ]

    config = defaults |> Keyword.merge(mix_config[:mix_freebsd_pkg]) |> Keyword.merge(overrides)

    if overrides[:pkg_file] != nil and !String.ends_with?(overrides[:pkg_file], [".pkg"]) do
      config |> Keyword.merge(pkg_file: "#{overrides[:pkg_file]}.pkg")
    else
      config
    end
  end

  def ensure_template_exists(templates_dir, template_name, config_template_path) do
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
          raise """
          Template file not found: #{app_template}
          """
        end
      end
    end
  end

  def validate_config(value, key, suggestion) do
    if value == nil do
      raise """
      Please set #{key} under mix.exs project configuration.

      def project do
        [
          ...
          #{suggestion}
          ...
        ]
      end

      """
    end
  end

  def freebsd? do
    System.find_executable("freebsd-version") != nil
  end

  def freebsd_version do
    {output, _} = System.cmd("freebsd-version", [])
    output |> String.trim()
  end

  def arch do
    {output, _} = System.cmd("uname", ["-m"])
    output |> String.trim()
  end
end

defmodule MixFreebsdPkg do
  @moduledoc """
  Documentation for `MixFreebsdPkg`.
  """
  @spec merge_config_with_argv(OptionParser.argv()) :: Keyword.t()
  def merge_config_with_argv(argv) do
    options = [strict: [pkg_file: :string]]
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
      pre_install: Path.join([templates_dir, "pre_install.sh"]),
      post_install: Path.join([templates_dir, "post_install.sh"]),
      pre_deinstall: Path.join([templates_dir, "pre_deinstall.sh"]),
      post_deinstall: Path.join([templates_dir, "post_deinstall.sh"]),
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

defmodule Mix.Tasks.Freebsd.Render do
  @moduledoc """

  """
  use Mix.Task
  alias MixFreebsdPkg.Config
  alias MixFreebsdPkg.Platform
  alias MixFreebsdPkg.Template

  def run(argv) do
    names = argv |> Enum.map(&String.downcase/1) |> Enum.uniq() |> Enum.reject(&(&1 == ""))

    if Platform.freebsd?() do
      config = Config.config()

      for name <- names do
        case name do
          "conf" ->
            if config.use_conf do
              Template.render_conf(config)
            else
              Mix.shell().error(
                "Please add `use_conf: true` under `project[:freebsd_pkg]` in `mix.exs`."
              )
            end

          "env" ->
            if config.use_env do
              Template.render_env(config)
            else
              Mix.shell().error(
                "Please add `use_env: true` under `project[:freebsd_pkg]` in `mix.exs`."
              )
            end

          "service" ->
            Template.render_service(config)

          "service_commands" ->
            if config.service_commands != [] do
              Template.render_service_commands(config)
            else
              Mix.shell().error(
                "Please add `service_commands: [\"command1\", \"command2\"]` under `project[:freebsd_pkg]` in `mix.exs`."
              )
            end

          "pre-install" ->
            Template.render_pre_install(config)

          "post-install" ->
            Template.render_post_install(config)

          "pre-deinstall" ->
            Template.render_pre_deinstall(config)

          "post-deinstall" ->
            Template.render_post_deinstall(config)

          "all" ->
            Template.render_service(config)
            Template.render_pre_install(config)
            Template.render_post_install(config)
            Template.render_pre_deinstall(config)
            Template.render_post_deinstall(config)
        end
      end
    else
      Mix.shell().error("This task is only available on FreeBSD.")
    end
  end
end

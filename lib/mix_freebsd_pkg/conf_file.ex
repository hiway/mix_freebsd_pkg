defmodule MixFreebsdPkg.ConfFile do
  def render(config, template) do
    template |> EEx.eval_file(assigns: %{config: config})
  end
end

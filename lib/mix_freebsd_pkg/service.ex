defmodule MixFreebsdPkg.Service do
  @moduledoc """
  This module provides functions to generate service files.
  """

  @spec default_rc(MixFreebsdPkg.Config.t()) :: String.t()
  def default_rc(config) do
    rc_template = config[:rc_template]
    rc_template |> EEx.eval_file(assigns: %{config: config})
  end
end

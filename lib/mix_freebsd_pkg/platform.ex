defmodule MixFreebsdPkg.Platform do
  @moduledoc """
  Documentation for `MixFreebsdPkg.Platform`.
  """
  @spec freebsd?() :: boolean()
  def freebsd? do
    System.find_executable("freebsd-version") != nil
  end

  @spec freebsd_version() :: binary()
  def freebsd_version do
    {output, _} = System.cmd("freebsd-version", [])
    output |> String.trim()
  end

  @spec arch() :: binary()
  def arch do
    {output, _} = System.cmd("uname", ["-m"])
    output |> String.trim()
  end
end

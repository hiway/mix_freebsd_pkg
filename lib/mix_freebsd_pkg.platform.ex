defmodule MixFreebsdPkg.Platform do
  @moduledoc """
  Documentation for `MixFreebsdPkg.Platform`.
  """
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

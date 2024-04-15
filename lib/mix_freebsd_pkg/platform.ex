defmodule MixFreebsdPkg.Platform do
  @moduledoc """

  """

  @doc """
  Returns true if the current platform is FreeBSD.

  ## Examples

      iex> MixFreebsdPkg.Platform.freebsd?()
      true
  """
  @spec freebsd?() :: boolean()
  def freebsd? do
    System.find_executable("freebsd-version") != nil
  end

  @doc """
  Returns the FreeBSD version.

  ## Examples

      iex> MixFreebsdPkg.Platform.freebsd_version()
      "14.0-RELEASE-p6
  """
  @spec freebsd_version() :: binary()
  def freebsd_version do
    {output, _} = System.cmd("freebsd-version", [])
    output |> String.trim()
  end

  @doc """
  Returns machine architecture.

  ## Examples

      iex> MixFreebsdPkg.Platform.arch()
      "amd64"
  """
  @spec arch() :: binary()
  def arch do
    {output, _} = System.cmd("uname", ["-m"])
    output |> String.trim()
  end
end

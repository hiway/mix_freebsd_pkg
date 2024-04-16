defmodule MixFreebsdPkg.Platform do
  @moduledoc """

  """

  @doc """
  Returns true if the current platform is FreeBSD.

  ## Example

    iex> MixFreebsdPkg.Platform.freebsd?()
    true
  """
  @spec freebsd?() :: boolean()
  def freebsd? do
    System.find_executable("freebsd-version") != nil
  end

  @doc """
  Returns the FreeBSD version.

  ## Example

    iex> MixFreebsdPkg.Platform.freebsd_version()
    "14.0-RELEASE-p6
  """
  @spec freebsd_version() :: binary()
  def freebsd_version do
    {output, _} = System.cmd("freebsd-version", [])
    output |> String.trim()
  end

  @doc """
  Returns a shortened FreeBSD version.

  ## Example

      iex> MixFreebsdPkg.Platform.freebsd_version_short()
      "14.0-rel"
  """
  @spec freebsd_version_short() :: binary()
  def freebsd_version_short do
    case freebsd_version() |> String.split("-") do
      [version, branch, _patch_level] -> version <> "-" <> shorten_branch(branch)
      [version, branch] -> version <> "-" <> shorten_branch(branch)
    end
  end

  defp shorten_branch(branch) do
    branch |> String.downcase() |> String.slice(0..2)
  end

  @doc """
  Returns machine architecture.

  ## Example

    iex> MixFreebsdPkg.Platform.arch()
    "amd64"
  """
  @spec arch() :: binary()
  def arch do
    {output, _} = System.cmd("uname", ["-m"])
    output |> String.trim()
  end
end

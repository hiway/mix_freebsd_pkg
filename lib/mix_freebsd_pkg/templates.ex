defmodule MixFreebsdPkg.Templates do
  @moduledoc """

  """

  @spec render(map) :: map
  def render(_config) do
    %{
      "service.sh.eex" => "echo 'Hello, world!'\n",
      "service_init.sh.eex" => "echo 'Hello, world!'\n",
      "config.env.sample.eex" => "HELLO='World'\n",
      "config.conf.sample.eex" => "hello = \"World\"\n",
      "pre-install.sh.eex" => "echo 'pre-install script'\n",
      "post-install.sh.eex" => "echo 'post-install script'\n",
      "pre-deinstall.sh.eex" => "echo 'pre-deinstall script'\n",
      "post-deinstall.sh.eex" => "echo 'post-deinstall script'\n"
    }
  end
end

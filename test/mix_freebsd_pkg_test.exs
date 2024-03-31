defmodule MixFreebsdPkgTest do
  use ExUnit.Case
  doctest MixFreebsdPkg

  test "config defaults" do
    config = Mix.Tasks.Freebsd.parse_args([])
    assert config[:name] == "mix_freebsd_pkg"
    assert config[:version] != nil
    assert config[:description] == "Example FreeBSD Package"
    assert config[:homepage_url] != nil
    assert config[:maintainer] == "harshad@sharma.io"
    assert config[:comment] == "Example FreeBSD Package"
    assert config[:category] == "www"
    assert config[:prefix] == "/usr/local"
    assert config[:requires] == []

    assert config[:user] == "mix_freebsd_pkg"
    assert config[:user_id] == nil
    assert config[:group] == "mix_freebsd_pkg"
    assert config[:group_id] == nil
    assert config[:groups] == []

    assert config[:app_dir] == "/usr/local/libexec/mix_freebsd_pkg"
    assert config[:data_dir] == "/var/db/mix_freebsd_pkg"
    assert config[:run_dir] == "/var/run/mix_freebsd_pkg"
    assert config[:log_dir] == "/var/log/mix_freebsd_pkg"
    assert config[:log_files] == ["/var/log/mix_freebsd_pkg/mix_freebsd_pkg.log"]
    assert config[:conf_dir] == "/usr/local/etc/mix_freebsd_pkg"
    assert config[:conf_files] == ["mix_freebsd_pkg.env.sample"]

    assert config[:port_acl_tcp] == []
    assert config[:port_acl_udp] == []
    assert config[:rc_script] == "/usr/local/etc/rc.d/mix_freebsd_pkg"
    assert config[:rc_template] == "priv/freebsd_pkg/zycelium.sh"
    assert config[:rc_extra_commands] == [init: "priv/freebsd_pkg/init.sh"]

    assert config[:pre_install] == "priv/freebsd_pkg/pre_install.sh"
    assert config[:post_install] == "priv/freebsd_pkg/post_install.sh"
    assert config[:pre_deinstall] == "priv/freebsd_pkg/pre_deinstall.sh"
    assert config[:post_deinstall] == "priv/freebsd_pkg/post_deinstall.sh"

    assert config[:pkg_file] == "mix_freebsd_pkg-#{config[:version]}.pkg"
    assert config[:freebsd_version] != nil
    assert config[:arch] != nil
  end

  test "override pkg_file with extension" do
    config = Mix.Tasks.Freebsd.parse_args(["--pkg-file", "my-pkg-file.pkg"])
    assert config[:pkg_file] == "my-pkg-file.pkg"
  end

  test "override pkg_file without extension" do
    config = Mix.Tasks.Freebsd.parse_args(["--pkg-file", "my-pkg-file"])
    assert config[:pkg_file] == "my-pkg-file.pkg"
  end
end

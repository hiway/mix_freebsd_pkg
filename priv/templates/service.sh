#!bin/sh

# PROVIDE: <%= @config[:name] %>
# REQUIRE: LOGIN
# KEYWORD: shutdown

. /etc/rc.subr

name=<%= @config[:name] %>
rcvar=<%= @config[:name] %>_enable

load_rc_config $name
run_rc_command "$1"

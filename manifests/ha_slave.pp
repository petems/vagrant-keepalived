# == Node: default
#
#  Defines the default node for ha slave
#
# === Parameters
#
#
#
# === Variables
#
#
# === Examples
#
# include default
#
# === Authors
#
# PeteMS
#
node default {

  include keepalived

  keepalived::vrrp::instance { 'VI_50':
    interface         => 'eth1',
    state             => 'SLAVE',
    virtual_router_id => '50',
    priority          => '100',
    auth_type         => 'PASS',
    auth_pass         => 'secret',
    virtual_ipaddress => ['192.168.10.77'],
  }

}
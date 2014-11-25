# Keepalived Vagrant and Puppet setup

[Keepalived](http://www.keepalived.org/) is routing software written in C, that provides a facilities for loadbalancing and high-availability. There's some excellent resources out ther for setting it up manually, but not much for using configuration management.

Here is a simple keepalived setup with 2 Vagrant boxes, provisioned with Vagrant.

First, boot up both virtual machines with the command

```
$ vagrant up ha1 ha2
```

This will create the two vagrant boxes, then provision them using the puppet code found in `modules`, mainly using the [keepalived puppet module](https://github.com/arioch/puppet-keepalived).

Both have a private permanent IP address:

* ha1 - `192.168.10.50`
* ha2 - `192.168.10.51`

You should be able to ping both boxes after the initial setup:

```
ping 172.16.10.50
ping 172.16.10.51
```

Then, the clever part: keepalived is running a virtual IP of `172.16.10.77`, which you should be able to ping with

```
ping 192.168.10.77
```

Now, with that running that in one terminal window, in another run:

```
vagrant halt ha1
```

At this point, keepalived will failover, and you should again be getting answers to your ping.

Bring `ha1` up again with the command

```
vagrant up ha1
```

At this point, `ha1` should take over the master role again, and the pings should be hitting it again.

You can SSH into either of the machines with the command

```
vagrant ssh ha1
vagrant ssh ha2
```

You can follow what `keepalived` is doing by tailing the file `/var/log/syslog`. It should look something like this:

```
Apr  9 16:04:04 ha2 Keepalived: Terminating on signal
Apr  9 16:04:04 ha2 Keepalived: Stopping Keepalived v1.2.2 (12/23,2011)
Apr  9 16:04:04 ha2 Keepalived_healthcheckers: Terminating Healthchecker child process on signal
Apr  9 16:04:04 ha2 Keepalived_vrrp: Terminating VRRP child process on signal
Apr  9 16:04:04 ha2 Keepalived: Starting Keepalived v1.2.2 (12/23,2011)
Apr  9 16:04:04 ha2 Keepalived: Starting Healthcheck child process, pid=1505
Apr  9 16:04:04 ha2 Keepalived: Starting VRRP child process, pid=1506
Apr  9 16:04:04 ha2 Keepalived_healthcheckers: Initializing ipvs 2.6
Apr  9 16:04:04 ha2 Keepalived_vrrp: Registering Kernel netlink reflector
Apr  9 16:04:04 ha2 Keepalived_healthcheckers: Registering Kernel netlink reflector
Apr  9 16:04:04 ha2 Keepalived_vrrp: Registering Kernel netlink command channel
Apr  9 16:04:04 ha2 Keepalived_healthcheckers: Registering Kernel netlink command channel
Apr  9 16:04:04 ha2 Keepalived_vrrp: Registering gratutious ARP shared channel
Apr  9 16:04:04 ha2 Keepalived_vrrp: Initializing ipvs 2.6
Apr  9 16:04:04 ha2 Keepalived_healthcheckers: Opening file '/etc/keepalived/keepalived.conf'.
Apr  9 16:04:04 ha2 Keepalived_healthcheckers: Configuration is using : 4507 Bytes
Apr  9 16:04:04 ha2 Keepalived_vrrp: Opening file '/etc/keepalived/keepalived.conf'.
Apr  9 16:04:04 ha2 Keepalived_vrrp: Configuration is using : 60129 Bytes
Apr  9 16:04:04 ha2 Keepalived_vrrp: Using LinkWatch kernel netlink reflector...
Apr  9 16:04:04 ha2 Keepalived_vrrp: VRRP_Instance(VI_50) Entering BACKUP STATE
Apr  9 16:04:04 ha2 Keepalived_healthcheckers: Using LinkWatch kernel netlink reflector...
```
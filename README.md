<a href="https://github.com/jonnystorm/giraphe"><img src="https://raw.githubusercontent.com/jonnystorm/giraphe/master/giraphe-title.png" height="300px" /></a>

[![Build Status](https://travis-ci.org/jonnystorm/giraphe.svg?branch=master)](https://travis-ci.org/jonnystorm/giraphe)

Discover and visualize layer-2 and layer-3 network topology.

See the [API documentation](https://jonnystorm.github.io/giraphe).

## Installation

To use giraphe as an escript:

  1. Install Erlang/OTP 19

  1. Install GraphViz

  1. Install nmap

  1. Clone the giraphe repository

    ```sh
    git clone https://github.com/jonnystorm/giraphe.git
    ```

  1. Add nmap command to sudoers

    ```sh
    Cmnd_Alias NMAP = /usr/bin/nmap -n -oG - -sU -p *

    %wheel ALL=(root) NOPASSWD: NMAP

    Defaults!NMAP !requiretty
    ```

  1. Run from within the giraphe directory

    ```sh
    $ cd giraphe
    $ ./giraphe
    Usage: giraphe [-qv] -c <credentials_path> -o <output_file>
                   [-2 <gateway_ip> [<subnet_cidr>]] [-3 [<router_ip> ...]]

      -q: quiet
      -v: verbose ('-vv' is more verbose)

      -o: output file (must end in .png or .svg)

      -c: Specify file containing credentials
        <credentials_path>: path to file containing credentials

        Valid lines in this file will look like one of the following:
          snmp v2c 'r34D0n1Y!'
          snmp v3 noAuthNoPriv 'admin'
          snmp v3 authNoPriv 'admin' md5 '$3cR3t!'
          snmp v3 authPriv 'admin' sha '$3crR3t!' aes 'pR1v473!'

      -2: generate layer-2 topology
         <gateway_ip>: IP address of target subnet gateway
        <subnet_cidr>: Specifies switch subnet to graph

      -3: generate layer-3 topology
        <router_ip>: IP address of seed target router; with no seed specified,
                     this machines's default gateway is used

    ```

To use giraphe as a library:

  1. Add giraphe to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:giraphe, git: "https://github.com/jonnystorm/giraphe.git"}]
    end
    ```

  1. Ensure giraphe is started before your application:

    ```elixir
    def application do
      [applications: [:giraphe]]
    end
    ```

## Example

### L3

    $ ./giraphe -c ~/creds -o ~/new-l3-diagram.png -3 198.51.100.1
    Seeding targets 198.51.100.1/32
    New routers discovered: R1
    Next targets: 192.0.2.2/31, 198.51.100.2/32, 198.51.100.3/32

    12:50:25.494 [warn]  Unable to query target '198.51.100.3/32' for object 'routes': :etimedout
    
    12:50:31.524 [warn]  Unable to query target '198.51.100.3/32' for object 'addresses': :etimedout
    
    12:50:37.553 [warn]  Unable to query target '198.51.100.3/32' for object 'sysname': :etimedout
    New routers discovered: 192.0.2.2, R2, 198.51.100.3
    Next targets: 198.51.100.4/32, 198.51.100.5/32
    New routers discovered: R4, R5
    Next targets: 
    Done!

### L2

    $ ./giraphe -c ~/creds -o ~/new-l2-diagram.svg -2 192.0.2.1
    Found subnet '192.0.2.0/24' for gateway '192.0.2.1/32'.
    Inducing ARP entries on '192.0.2.0/24'...
    Retrieving ARP entries for '192.0.2.0/24'...
    Found the following hosts: 192.0.2.1, 192.0.2.2, 192.0.2.3, 192.0.2.4, 192.0.2.5, 192.0.2.6, 192.0.2.7, 192.0.2.8

    12:36:57.896 [warn]  Unable to query target '192.0.2.5/32' for object 'fdb': :etimedout
    
    12:37:04.112 [warn]  Unable to query target '192.0.2.7/32' for object 'sysname': :etimedout
    
    12:37:11.680 [warn]  Unable to query target '192.0.2.8/32' for object 'sysname': :snmperr_unknown_user_name
    Done!


# puppet-slurm_providers

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/slurm_providers.svg)](https://forge.puppetlabs.com/treydock/slurm_providers)
[![CI Status](https://github.com/treydock/puppet-slurm_providers/workflows/CI/badge.svg?branch=master)](https://github.com/treydock/puppet-slurm_providers/actions?query=workflow%3ACI)

#### Table of Contents

1. [Overview](#overview)
    * [Supported versions of SLURM](#supported-versions-of-slurm)
1. [Setup - The basics of getting started](#setup)
1. [Reference - An under-the-hood peek at what the module is doing](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)

## Overview

The SLURM providers module lets you manage various SLURM resources with Puppet.

### Supported versions of SLURM

Currenlty this module supports version 19.05 of SLURM

## Setup

This module requires that `sacctmgr` be in `PATH`.

If SLURM binaries are is not in path then then you must configure Puppet with a valid path to `sacctmgr` and `scontrol`.
Below is an example of configuring Puppet if SLURM install prefix is `/opt/slurm`.

```puppet
slurm_config { 'puppet':
  sacctmgr_path => '/opt/slurm/bin/sacctmgr',
  scontrol_path => '/opt/slurm/bin/scontrol',
}
```

## Reference

[http://treydock.github.io/puppet-slurm_providers/](http://treydock.github.io/puppet-slurm_providers/)

## Limitations

This module has been tested using the following versions of SLURM

* 20.02.x
* 20.11.x
* 21.08.x

The following operating systems have been tested

* RHEL/CentOS 7 x86_64
* RHEL/Rocky 8 x86_64

## Development

### Testing

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake spec

The following environment variables can be used to modify the behavior of the beaker tests:

* **SLURM\_BEAKER\_version** - Version of SLURM to install.  Defaults to **20.02.3**

Example of running beaker tests using an internal repository, and leaving VMs running after the tests.

    export BEAKER_destroy=no
    export BEAKER_PUPPET_COLLECTION=puppet5
    export PUPPET_INSTALL_TYPE=agent
    export BEAKER_set=centos-7
    bundle exec rake beaker

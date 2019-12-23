# puppet-slurm_providers

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/slurm_providers.svg)](https://forge.puppetlabs.com/treydock/slurm_providers)
[![Build Status](https://travis-ci.org/treydock/puppet-slurm_providers.svg?branch=master)](https://travis-ci.org/treydock/puppet-slurm_providers)

####Table of Contents

1. [Overview](#overview)
    * [Supported versions of SLURM](#supported-versions-of-slurm)
3. [Setup - The basics of getting started](#setup)
4. [Usage - Configuration and customization options](#usage)
5. [Reference - An under-the-hood peek at what the module is doing](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)

## Overview

The SLURM providers module lets you manage various SLURM resources with Puppet.

### Supported versions of SLURM

Currenlty this module supports version 19.05 of SLURM

## Setup

This module requires that `sacctmgr` be in `PATH`.

## Usage

TODO

## Reference

[http://treydock.github.io/puppet-slurm_providers/](http://treydock.github.io/puppet-slurm_providers/)

## Limitations

This module has been tested using the following versions of SLURM

* 19.05.03-3

The following operating systems have been tested

* RHEL/CentOS 7 x86_64

## Development

### Testing

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake spec

The following environment variables can be used to modify the behavior of the beaker tests:

* *SLURM\_BEAKER\\_version* - Version of SLURM to install.  Defaults to **19.05.4**

Example of running beaker tests using an internal repository, and leaving VMs running after the tests.

    export BEAKER_destroy=no
    export BEAKER_PUPPET_COLLECTION=puppet5
    export PUPPET_INSTALL_TYPE=agent
    export BEAKER_set=centos-7
    bundle exec rake beaker

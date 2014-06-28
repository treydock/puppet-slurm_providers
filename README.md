# puppet-slurm_providers

[![Build Status](https://travis-ci.org/treydock/puppet-slurm_providers.png)](https://travis-ci.org/treydock/puppet-slurm_providers)

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started](#setup)
4. [Usage - Configuration and customization options](#usage)
5. [Reference - An under-the-hood peek at what the module is doing](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
    * [Tests - Running regression tests](#tests)
8. [TODO](#todo)
9. [Additional Information](#additional-information)

## Overview

The SLURM providers module lets you manage various SLURM resources with Puppet.

## Module Description

TODO

## Setup

TODO

## Usage

TODO

## Reference

Types:

* [slurm_cluster](#type-slurm_cluster)
* [slurm_qos](#type-slurm_qos)

### Type: slurm_cluster

TODO

### Type: slurm_qos

TODO

## Limitations

This module has been tested using the following versions of SLURM

* 14.03.3

The following operating systems have been tested

* CentOS 6 x86_64

## Development

### Tests

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake test

## TODO

* Finalize module for release
* Add beaker-rspec acceptance tests

## Additional Information

* [sacctmgr](http://slurm.schedmd.com/sacctmgr.html)

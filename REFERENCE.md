# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Resource types

* [`slurm_account`](#slurm_account): Puppet type that manages a SLURM account
* [`slurm_cluster`](#slurm_cluster): Puppet type that manages a SLURM cluster
* [`slurm_config`](#slurm_config): Abstract type to configure other SLURM types
* [`slurm_license`](#slurm_license): Puppet type that manages a SLURM software resource
* [`slurm_qos`](#slurm_qos): Puppet type that manages a SLURM QOS
* [`slurm_reservation`](#slurm_reservation): Puppet type that manages a SLURM Reservation
* [`slurm_user`](#slurm_user): Puppet type that manages a SLURM user
* [`slurmctld_conn_validator`](#slurmctld_conn_validator): Verify that a connection can be successfully established between a node and the slurmctld server.  Its primary use is as a precondition to pr
* [`slurmdbd_conn_validator`](#slurmdbd_conn_validator): Verify that a connection can be successfully established between a node and the slurmdbd server.  Its primary use is as a precondition to pre

## Resource types

### <a name="slurm_account"></a>`slurm_account`

Puppet type that manages a SLURM account

#### Examples

##### Add SLURM account

```puppet
slurm_account { 'staff on cluster':
  ensure    => 'present',
  max_jobs  => 1000,
  priority  => 9999,
}

@example Add SLURM account
  slurm_account { 'staff:cluster':
    ensure    => 'present',
    max_jobs  => 1000,
    priority  => 9999,
  }
```

#### Properties

The following properties are available in the `slurm_account` type.

##### `default_qos`

DefaultQOS

##### `description`

Description

##### `ensure`

Valid values: `present`, `absent`

The basic property that the resource should be in.

Default value: `present`

##### `fairshare`

Fairshare number or "parent"

Default value: `1`

##### `grp_jobs`

GrpJobs

Default value: `absent`

##### `grp_jobs_accrue`

GrpJobsAccrue

Default value: `absent`

##### `grp_submit_jobs`

GrpSubmitJobs

Default value: `absent`

##### `grp_tres`

GrpTRES

Default value: `absent`

##### `grp_tres_mins`

GrpTRESMins

Default value: `absent`

##### `grp_tres_run_mins`

GrpTRESRunMins

Default value: `absent`

##### `grp_wall`

GrpWall

Default value: `absent`

##### `max_jobs`

MaxJobs

Default value: `absent`

##### `max_jobs_accrue`

MaxJobsAccrue

Default value: `absent`

##### `max_submit_jobs`

MaxSubmitJobs

Default value: `absent`

##### `max_tres_mins_per_job`

MaxTresMinsPerJob

Default value: `absent`

##### `max_tres_per_job`

MaxTresPerJob

Default value: `absent`

##### `max_tres_per_node`

MaxTresPerJob

Default value: `absent`

##### `max_wall_duration_per_job`

MaxWallDurationPerJob

Default value: `absent`

##### `organization`

Organization

##### `parent_name`

Account parent name

##### `priority`

Priority

##### `qos`

QOS, undefined will inherit parent QOS

#### Parameters

The following parameters are available in the `slurm_account` type.

* [`account`](#-slurm_account--account)
* [`cluster`](#-slurm_account--cluster)
* [`name`](#-slurm_account--name)
* [`provider`](#-slurm_account--provider)

##### <a name="-slurm_account--account"></a>`account`

Account name

##### <a name="-slurm_account--cluster"></a>`cluster`

Cluster name

##### <a name="-slurm_account--name"></a>`name`

namevar

Account name

##### <a name="-slurm_account--provider"></a>`provider`

The specific backend to use for this `slurm_account` resource. You will seldom need to specify this --- Puppet will
usually discover the appropriate provider for your platform.

### <a name="slurm_cluster"></a>`slurm_cluster`

Puppet type that manages a SLURM cluster

#### Examples

##### Add a SLURM cluster

```puppet
slurm_cluster { 'test':
  ensure => 'present',
}
```

#### Properties

The following properties are available in the `slurm_cluster` type.

##### `ensure`

Valid values: `present`, `absent`

The basic property that the resource should be in.

Default value: `present`

##### `features`

Features

Default value: `absent`

##### `fed_state`

Valid values: `active`, `inactive`, `drain`, `drain_remove`

FedState

##### `federation`

Federation

Default value: `absent`

#### Parameters

The following parameters are available in the `slurm_cluster` type.

* [`flags`](#-slurm_cluster--flags)
* [`name`](#-slurm_cluster--name)
* [`provider`](#-slurm_cluster--provider)

##### <a name="-slurm_cluster--flags"></a>`flags`

Flags

##### <a name="-slurm_cluster--name"></a>`name`

namevar

cluster name

##### <a name="-slurm_cluster--provider"></a>`provider`

The specific backend to use for this `slurm_cluster` resource. You will seldom need to specify this --- Puppet will
usually discover the appropriate provider for your platform.

### <a name="slurm_config"></a>`slurm_config`

Abstract type to configure other SLURM types

#### Parameters

The following parameters are available in the `slurm_config` type.

* [`install_prefix`](#-slurm_config--install_prefix)
* [`name`](#-slurm_config--name)

##### <a name="-slurm_config--install_prefix"></a>`install_prefix`

The path to SLURM install prefix

##### <a name="-slurm_config--name"></a>`name`

namevar

The name of the resource

### <a name="slurm_license"></a>`slurm_license`

Puppet type that manages a SLURM software resource

#### Examples

##### Add SLURM software resource

```puppet
slurm_license { 'matlab@host':
  ensure  => 'present',
  count   => 100,
}
slurm_license { 'matlab@host for linux':
  ensure          => 'present',
  percent_allowed => 100,
}
```

#### Properties

The following properties are available in the `slurm_license` type.

##### `count`

Count

##### `description`

Description

##### `ensure`

Valid values: `present`, `absent`

The basic property that the resource should be in.

Default value: `present`

##### `percent_allowed`

PercentAllowed

##### `server_type`

ServerType

Default value: `absent`

#### Parameters

The following parameters are available in the `slurm_license` type.

* [`cluster`](#-slurm_license--cluster)
* [`name`](#-slurm_license--name)
* [`provider`](#-slurm_license--provider)
* [`resource_name`](#-slurm_license--resource_name)
* [`server`](#-slurm_license--server)
* [`type`](#-slurm_license--type)

##### <a name="-slurm_license--cluster"></a>`cluster`

Cluster

##### <a name="-slurm_license--name"></a>`name`

namevar

Resource name

##### <a name="-slurm_license--provider"></a>`provider`

The specific backend to use for this `slurm_license` resource. You will seldom need to specify this --- Puppet will
usually discover the appropriate provider for your platform.

##### <a name="-slurm_license--resource_name"></a>`resource_name`

Resource name

##### <a name="-slurm_license--server"></a>`server`

Server

##### <a name="-slurm_license--type"></a>`type`

Resource type, read-only

Default value: `License`

### <a name="slurm_qos"></a>`slurm_qos`

Puppet type that manages a SLURM QOS

#### Examples

##### Add SLURM QOS

```puppet
slurm_qos { 'high':
  ensure            => 'present',
  flags             => ['DenyOnLimit','RequiresReservation'],
  grace_time        => 300,
  grp_tres          => { 'node' => 40 },
  max_tres_per_user => { 'node' => 20 },
  max_wall          => '2-00:00:00',
  priority          => 2000000,
}
```

#### Properties

The following properties are available in the `slurm_qos` type.

##### `description`

Description

##### `ensure`

Valid values: `present`, `absent`

The basic property that the resource should be in.

Default value: `present`

##### `flags`

Valid values: `DenyOnLimit`, `EnforceUsageThreshold`, `NoReserve`, `PartitionMaxNodes`, `PartitionMinNodes`, `OverPartQOS`, `PartitionTimeLimit`, `RequiresReservation`, `NoDecay`, `UsageFactorSafe`

Flags

Default value: `absent`

##### `grace_time`

GraceTime

Default value: `0`

##### `grp_jobs`

GrpJobs

Default value: `absent`

##### `grp_jobs_accrue`

GrpJobsAccrue

Default value: `absent`

##### `grp_submit_jobs`

GrpSubmitJobs

Default value: `absent`

##### `grp_tres`

GrpTRES

Default value: `absent`

##### `grp_tres_mins`

GrpTRESMins

Default value: `absent`

##### `grp_tres_run_mins`

GrpTRESRunMins

Default value: `absent`

##### `grp_wall`

GrpWall

Default value: `absent`

##### `max_jobs_per_account`

MaxJobsPerAccount

Default value: `absent`

##### `max_jobs_per_user`

MaxJobsPerUser

Default value: `absent`

##### `max_submit_jobs_per_account`

MaxSubmitJobsPerAccount

Default value: `absent`

##### `max_submit_jobs_per_user`

MaxSubmitJobsPerUser

Default value: `absent`

##### `max_tres_mins`

MaxTresMins

Default value: `absent`

##### `max_tres_per_account`

MaxTresPerAccount

Default value: `absent`

##### `max_tres_per_job`

MaxTresPerJob

Default value: `absent`

##### `max_tres_per_node`

MaxTresPerNode

Default value: `absent`

##### `max_tres_per_user`

MaxTresPerUser

Default value: `absent`

##### `max_tres_run_mins_per_account`

MaxTRESRunMinsPerAccount

Default value: `absent`

##### `max_tres_run_mins_per_user`

MaxTRESRunMinsPerUser

Default value: `absent`

##### `max_wall`

MaxWall

Default value: `absent`

##### `min_prio_threshold`

MinPrioThreshold

Default value: `absent`

##### `min_tres_per_job`

MinTRESPerJob

Default value: `absent`

##### `preempt`

Preempt

Default value: `absent`

##### `preempt_exempt_time`

PreemptExemptTime

Default value: `absent`

##### `preempt_mode`

Valid values: `cluster`, `cancel`, `checkpoint`, `requeue`

PreemptMode

Default value: `cluster`

##### `priority`

Priority

Default value: `0`

##### `usage_factor`

UsageFactor

Default value: `1.000000`

##### `usage_threshold`

UsageThreshold

Default value: `absent`

#### Parameters

The following parameters are available in the `slurm_qos` type.

* [`name`](#-slurm_qos--name)
* [`provider`](#-slurm_qos--provider)

##### <a name="-slurm_qos--name"></a>`name`

namevar

QOS name

##### <a name="-slurm_qos--provider"></a>`provider`

The specific backend to use for this `slurm_qos` resource. You will seldom need to specify this --- Puppet will usually
discover the appropriate provider for your platform.

### <a name="slurm_reservation"></a>`slurm_reservation`

Puppet type that manages a SLURM Reservation

#### Examples

##### Add SLURM Reservation

```puppet
slurm_reservation { 'maint':
  ensure     => 'present',
  start_time => 'now',
  duration   => '02:00:00',
  users      => ['root'],
  flags      => ['maint','ignore_jobs'],
  nodes      => 'ALL',
}
```

#### Properties

The following properties are available in the `slurm_reservation` type.

##### `accounts`

Accounts

##### `burst_buffer`

BurstBuffer

##### `core_cnt`

CoreCnt

##### `duration`

Duration

##### `end_time`

EndTime

##### `ensure`

Valid values: `present`, `absent`

The basic property that the resource should be in.

Default value: `present`

##### `flags`

Flags

##### `licenses`

Licenses

##### `node_cnt`

NodeCnt

##### `nodes`

Nodes

##### `partition_name`

PartitionName

##### `start_time`

StartTime

##### `tres`

TRES

##### `users`

Users

#### Parameters

The following parameters are available in the `slurm_reservation` type.

* [`features`](#-slurm_reservation--features)
* [`name`](#-slurm_reservation--name)
* [`provider`](#-slurm_reservation--provider)
* [`timezone`](#-slurm_reservation--timezone)

##### <a name="-slurm_reservation--features"></a>`features`

Features

##### <a name="-slurm_reservation--name"></a>`name`

namevar

Reservation name

##### <a name="-slurm_reservation--provider"></a>`provider`

The specific backend to use for this `slurm_reservation` resource. You will seldom need to specify this --- Puppet will
usually discover the appropriate provider for your platform.

##### <a name="-slurm_reservation--timezone"></a>`timezone`

TZ environment variable value

### <a name="slurm_user"></a>`slurm_user`

Puppet type that manages a SLURM user

#### Examples

##### Add SLURM user under account 'bar' on cluster 'test'

```puppet
slurm_user { 'foo under bar on test':
  ensure    => 'present',
  max_jobs  => 1000,
  priority  => 9999,
}
```

##### Add SLURM user under account 'bar' on cluster 'test'

```puppet
slurm_user { 'foo:bar:test':
  ensure    => 'present',
  max_jobs  => 1000,
  priority  => 9999,
}
```

#### Properties

The following properties are available in the `slurm_user` type.

##### `admin_level`

Valid values: `None`, `Operator`, `Administrator`

AdminLevel

Default value: `None`

##### `default_account`

DefaultAccount

##### `default_qos`

DefaultQOS

##### `ensure`

Valid values: `present`, `absent`

The basic property that the resource should be in.

Default value: `present`

##### `fairshare`

Fairshare number or "parent"

Default value: `1`

##### `grp_jobs`

GrpJobs

Default value: `absent`

##### `grp_jobs_accrue`

GrpJobsAccrue

Default value: `absent`

##### `grp_submit_jobs`

GrpSubmitJobs

Default value: `absent`

##### `grp_tres`

GrpTRES

Default value: `absent`

##### `grp_tres_mins`

GrpTRESMins

Default value: `absent`

##### `grp_tres_run_mins`

GrpTRESRunMins

Default value: `absent`

##### `grp_wall`

GrpWall

Default value: `absent`

##### `max_jobs`

MaxJobs

Default value: `absent`

##### `max_jobs_accrue`

MaxJobsAccrue

Default value: `absent`

##### `max_submit_jobs`

MaxSubmitJobs

Default value: `absent`

##### `max_tres_mins_per_job`

MaxTresMinsPerJob

Default value: `absent`

##### `max_tres_per_job`

MaxTresPerJob

Default value: `absent`

##### `max_tres_per_node`

MaxTresPerJob

Default value: `absent`

##### `max_wall_duration_per_job`

MaxWallDurationPerJob

Default value: `absent`

##### `priority`

Priority

##### `qos`

QOS, undefined will inherit parent QOS

#### Parameters

The following parameters are available in the `slurm_user` type.

* [`account`](#-slurm_user--account)
* [`cluster`](#-slurm_user--cluster)
* [`name`](#-slurm_user--name)
* [`partition`](#-slurm_user--partition)
* [`provider`](#-slurm_user--provider)
* [`user`](#-slurm_user--user)

##### <a name="-slurm_user--account"></a>`account`

Account name

##### <a name="-slurm_user--cluster"></a>`cluster`

Cluster name

##### <a name="-slurm_user--name"></a>`name`

namevar

User name

##### <a name="-slurm_user--partition"></a>`partition`

Partition name

Default value: `absent`

##### <a name="-slurm_user--provider"></a>`provider`

The specific backend to use for this `slurm_user` resource. You will seldom need to specify this --- Puppet will usually
discover the appropriate provider for your platform.

##### <a name="-slurm_user--user"></a>`user`

User name

### <a name="slurmctld_conn_validator"></a>`slurmctld_conn_validator`

Verify that a connection can be successfully established between a node
and the slurmctld server.  Its primary use is as a precondition to
prevent configuration changes from being applied if the slurmctld
server cannot be reached.

#### Properties

The following properties are available in the `slurmctld_conn_validator` type.

##### `ensure`

Valid values: `present`, `absent`

The basic property that the resource should be in.

Default value: `present`

#### Parameters

The following parameters are available in the `slurmctld_conn_validator` type.

* [`name`](#-slurmctld_conn_validator--name)
* [`provider`](#-slurmctld_conn_validator--provider)
* [`timeout`](#-slurmctld_conn_validator--timeout)

##### <a name="-slurmctld_conn_validator--name"></a>`name`

namevar

An arbitrary name used as the identity of the resource.

##### <a name="-slurmctld_conn_validator--provider"></a>`provider`

The specific backend to use for this `slurmctld_conn_validator` resource. You will seldom need to specify this ---
Puppet will usually discover the appropriate provider for your platform.

##### <a name="-slurmctld_conn_validator--timeout"></a>`timeout`

The max number of seconds that the validator should wait before giving up and deciding that slurmctld is not running;
defaults to 30 seconds.

Default value: `30`

### <a name="slurmdbd_conn_validator"></a>`slurmdbd_conn_validator`

Verify that a connection can be successfully established between a node
and the slurmdbd server.  Its primary use is as a precondition to
prevent configuration changes from being applied if the slurmdbd
server cannot be reached.

#### Properties

The following properties are available in the `slurmdbd_conn_validator` type.

##### `ensure`

Valid values: `present`, `absent`

The basic property that the resource should be in.

Default value: `present`

#### Parameters

The following parameters are available in the `slurmdbd_conn_validator` type.

* [`name`](#-slurmdbd_conn_validator--name)
* [`provider`](#-slurmdbd_conn_validator--provider)
* [`timeout`](#-slurmdbd_conn_validator--timeout)

##### <a name="-slurmdbd_conn_validator--name"></a>`name`

namevar

An arbitrary name used as the identity of the resource.

##### <a name="-slurmdbd_conn_validator--provider"></a>`provider`

The specific backend to use for this `slurmdbd_conn_validator` resource. You will seldom need to specify this --- Puppet
will usually discover the appropriate provider for your platform.

##### <a name="-slurmdbd_conn_validator--timeout"></a>`timeout`

The max number of seconds that the validator should wait before giving up and deciding that slurmdbd is not running;
defaults to 30 seconds.

Default value: `30`


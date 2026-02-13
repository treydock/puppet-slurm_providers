# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v0.16.0](https://github.com/treydock/puppet-slurm_providers/tree/v0.16.0) (2026-02-13)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.15.0...v0.16.0)

### Changed

- Drop EL7 and Puppet 7 support [\#42](https://github.com/treydock/puppet-slurm_providers/pull/42) ([treydock](https://github.com/treydock))

### Added

- Allow coordinator to be ignored on slurm\_user [\#44](https://github.com/treydock/puppet-slurm_providers/pull/44) ([treydock](https://github.com/treydock))
- Test against Slurm 25.11 and 25.05 [\#43](https://github.com/treydock/puppet-slurm_providers/pull/43) ([treydock](https://github.com/treydock))
- Add support for Account Coordinators [\#40](https://github.com/treydock/puppet-slurm_providers/pull/40) ([optiz0r](https://github.com/optiz0r))
- Improve handling of slurm\_user partitions [\#39](https://github.com/treydock/puppet-slurm_providers/pull/39) ([optiz0r](https://github.com/optiz0r))

## [v0.15.0](https://github.com/treydock/puppet-slurm_providers/tree/v0.15.0) (2024-12-26)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.14.1...v0.15.0)

### Added

- Support Slurm 24.05.x [\#41](https://github.com/treydock/puppet-slurm_providers/pull/41) ([treydock](https://github.com/treydock))

## [v0.14.1](https://github.com/treydock/puppet-slurm_providers/tree/v0.14.1) (2024-03-25)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.14.0...v0.14.1)

### Fixed

- Support Slurm 23.11 [\#36](https://github.com/treydock/puppet-slurm_providers/pull/36) ([treydock](https://github.com/treydock))

## [v0.14.0](https://github.com/treydock/puppet-slurm_providers/tree/v0.14.0) (2023-12-28)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.13.0...v0.14.0)

### Changed

- MAJOR UPDATES: Read description [\#34](https://github.com/treydock/puppet-slurm_providers/pull/34) ([treydock](https://github.com/treydock))

### Added

- Support Slurm 23.02.x [\#35](https://github.com/treydock/puppet-slurm_providers/pull/35) ([treydock](https://github.com/treydock))

## [v0.13.0](https://github.com/treydock/puppet-slurm_providers/tree/v0.13.0) (2022-10-06)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.12.4...v0.13.0)

### Added

- Support hourly reservations [\#33](https://github.com/treydock/puppet-slurm_providers/pull/33) ([treydock](https://github.com/treydock))

## [v0.12.4](https://github.com/treydock/puppet-slurm_providers/tree/v0.12.4) (2022-08-08)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.12.3...v0.12.4)

### Fixed

- Fix parsing of reservation with no flags [\#32](https://github.com/treydock/puppet-slurm_providers/pull/32) ([treydock](https://github.com/treydock))

## [v0.12.3](https://github.com/treydock/puppet-slurm_providers/tree/v0.12.3) (2021-10-05)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.12.2...v0.12.3)

### Fixed

- Fix slurm\_qos having preempt changed to absent [\#31](https://github.com/treydock/puppet-slurm_providers/pull/31) ([treydock](https://github.com/treydock))

## [v0.12.2](https://github.com/treydock/puppet-slurm_providers/tree/v0.12.2) (2021-07-28)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.12.1...v0.12.2)

### Fixed

- slurm\_qos will autorequire QOS it preempts [\#30](https://github.com/treydock/puppet-slurm_providers/pull/30) ([treydock](https://github.com/treydock))

## [v0.12.1](https://github.com/treydock/puppet-slurm_providers/tree/v0.12.1) (2021-07-21)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.12.0...v0.12.1)

### Fixed

- Improved handling of setting properties to absent [\#29](https://github.com/treydock/puppet-slurm_providers/pull/29) ([treydock](https://github.com/treydock))

## [v0.12.0](https://github.com/treydock/puppet-slurm_providers/tree/v0.12.0) (2021-03-17)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.11.1...v0.12.0)

### Changed

- Drop Puppet 5 support, add Puppet 7 [\#28](https://github.com/treydock/puppet-slurm_providers/pull/28) ([treydock](https://github.com/treydock))

## [v0.11.1](https://github.com/treydock/puppet-slurm_providers/tree/v0.11.1) (2021-01-29)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.11.0...v0.11.1)

### Fixed

- Improved property validation for slurm\_license [\#27](https://github.com/treydock/puppet-slurm_providers/pull/27) ([treydock](https://github.com/treydock))

## [v0.11.0](https://github.com/treydock/puppet-slurm_providers/tree/v0.11.0) (2021-01-12)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.10.0...v0.11.0)

### Added

- Support SLURM 20.11 [\#25](https://github.com/treydock/puppet-slurm_providers/pull/25) ([treydock](https://github.com/treydock))

### Fixed

- Fix slurmdbd\_conn\_validator to not exit early on error [\#26](https://github.com/treydock/puppet-slurm_providers/pull/26) ([treydock](https://github.com/treydock))

## [v0.10.0](https://github.com/treydock/puppet-slurm_providers/tree/v0.10.0) (2021-01-04)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.9.0...v0.10.0)

### Added

- Support user association by partition [\#23](https://github.com/treydock/puppet-slurm_providers/pull/23) ([treydock](https://github.com/treydock))

## [v0.9.0](https://github.com/treydock/puppet-slurm_providers/tree/v0.9.0) (2020-10-09)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.8.0...v0.9.0)

### Added

- Improved error handling [\#22](https://github.com/treydock/puppet-slurm_providers/pull/22) ([treydock](https://github.com/treydock))

## [v0.8.0](https://github.com/treydock/puppet-slurm_providers/tree/v0.8.0) (2020-09-16)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.7.3...v0.8.0)

### Added

- Support timezone parameter for slurm\_reservation [\#21](https://github.com/treydock/puppet-slurm_providers/pull/21) ([treydock](https://github.com/treydock))

### Fixed

- Fix autorequires for slurm\_reservation [\#20](https://github.com/treydock/puppet-slurm_providers/pull/20) ([treydock](https://github.com/treydock))

## [v0.7.3](https://github.com/treydock/puppet-slurm_providers/tree/v0.7.3) (2020-09-15)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.7.2...v0.7.3)

### Fixed

- Numerous bug fixes for slurm\_reservation [\#19](https://github.com/treydock/puppet-slurm_providers/pull/19) ([treydock](https://github.com/treydock))

## [v0.7.2](https://github.com/treydock/puppet-slurm_providers/tree/v0.7.2) (2020-08-26)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.7.1...v0.7.2)

### Fixed

- Fix handling of slurm\_qos description to always be lower case [\#18](https://github.com/treydock/puppet-slurm_providers/pull/18) ([treydock](https://github.com/treydock))

## [v0.7.1](https://github.com/treydock/puppet-slurm_providers/tree/v0.7.1) (2020-07-29)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.7.0...v0.7.1)

### Fixed

- Properly handle changes to AdminLevel for users [\#17](https://github.com/treydock/puppet-slurm_providers/pull/17) ([treydock](https://github.com/treydock))

## [v0.7.0](https://github.com/treydock/puppet-slurm_providers/tree/v0.7.0) (2020-07-22)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.6.1...v0.7.0)

### Added

- Add slurmctld\_conn\_validator type [\#16](https://github.com/treydock/puppet-slurm_providers/pull/16) ([treydock](https://github.com/treydock))

## [v0.6.1](https://github.com/treydock/puppet-slurm_providers/tree/v0.6.1) (2020-07-13)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.6.0...v0.6.1)

### Fixed

- Fix for slurmdbd\_conn\_validator [\#15](https://github.com/treydock/puppet-slurm_providers/pull/15) ([treydock](https://github.com/treydock))

## [v0.6.0](https://github.com/treydock/puppet-slurm_providers/tree/v0.6.0) (2020-07-13)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.5.0...v0.6.0)

### Added

- Add slurmdbd\_conn\_validator type [\#14](https://github.com/treydock/puppet-slurm_providers/pull/14) ([treydock](https://github.com/treydock))
- Add slurm\_license type/provider [\#13](https://github.com/treydock/puppet-slurm_providers/pull/13) ([treydock](https://github.com/treydock))

## [v0.5.0](https://github.com/treydock/puppet-slurm_providers/tree/v0.5.0) (2020-06-23)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.4.2...v0.5.0)

### Added

- Add slurm\_user type and some misc fixes for other types [\#12](https://github.com/treydock/puppet-slurm_providers/pull/12) ([treydock](https://github.com/treydock))

## [v0.4.2](https://github.com/treydock/puppet-slurm_providers/tree/v0.4.2) (2020-06-22)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.4.1...v0.4.2)

### Fixed

- Remove defaults for slurm\_account for default\_qos and priority [\#11](https://github.com/treydock/puppet-slurm_providers/pull/11) ([treydock](https://github.com/treydock))

## [v0.4.1](https://github.com/treydock/puppet-slurm_providers/tree/v0.4.1) (2020-06-22)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.4.0...v0.4.1)

### Fixed

- Remove default from slurm\_account description and organization [\#10](https://github.com/treydock/puppet-slurm_providers/pull/10) ([treydock](https://github.com/treydock))

## [v0.4.0](https://github.com/treydock/puppet-slurm_providers/tree/v0.4.0) (2020-06-22)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.3.0...v0.4.0)

### Added

- Support more condensed composite names for slurm\_account [\#9](https://github.com/treydock/puppet-slurm_providers/pull/9) ([treydock](https://github.com/treydock))

## [v0.3.0](https://github.com/treydock/puppet-slurm_providers/tree/v0.3.0) (2020-06-22)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.2.0...v0.3.0)

### Added

- Improvements to slurm\_account type [\#8](https://github.com/treydock/puppet-slurm_providers/pull/8) ([treydock](https://github.com/treydock))
- Add slurm\_account type/provider [\#6](https://github.com/treydock/puppet-slurm_providers/pull/6) ([treydock](https://github.com/treydock))

## [v0.2.0](https://github.com/treydock/puppet-slurm_providers/tree/v0.2.0) (2019-12-27)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.1.1...v0.2.0)

### Changed

- Change slurm\_config to only need install\_prefix parameter [\#4](https://github.com/treydock/puppet-slurm_providers/pull/4) ([treydock](https://github.com/treydock))

### Added

- Add support for managing reservations [\#3](https://github.com/treydock/puppet-slurm_providers/pull/3) ([treydock](https://github.com/treydock))

### Fixed

- Fix acceptance tests [\#5](https://github.com/treydock/puppet-slurm_providers/pull/5) ([treydock](https://github.com/treydock))

## [v0.1.1](https://github.com/treydock/puppet-slurm_providers/tree/v0.1.1) (2019-12-23)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/v0.1.0...v0.1.1)

### Fixed

- Fix how sacctmgr default path is detected [\#2](https://github.com/treydock/puppet-slurm_providers/pull/2) ([treydock](https://github.com/treydock))

## [v0.1.0](https://github.com/treydock/puppet-slurm_providers/tree/v0.1.0) (2019-12-23)

[Full Changelog](https://github.com/treydock/puppet-slurm_providers/compare/95eb2b16671af77adcb63774093513be694ba6ff...v0.1.0)

### Changed

- Full rewrite of module [\#1](https://github.com/treydock/puppet-slurm_providers/pull/1) ([treydock](https://github.com/treydock))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*

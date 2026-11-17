# frozen_string_literal: true

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  c.add_setting :slurm_version
  c.slurm_version = ENV['BEAKER_slurm_version'] || '26.05.6'

  c.add_setting :timezone_offset

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    install_local_module_on(hosts, File.join(proj_root, 'spec/fixtures/site_slurm'))

    on hosts, 'timedatectl set-timezone America/New_York'
    on hosts, "timedatectl | grep 'Time zone:'" do |result|
      c.timezone_offset = if result.stdout =~ %r{EDT}
                            -4
                          else
                            -5
                          end
    end

    # Add dependencies
    install_puppet_module_via_pmt_on(hosts, 'puppetlabs-stdlib', '>= 5.0.0 < 10.0.0')
    install_puppet_module_via_pmt_on(hosts, 'puppetlabs-concat')
    install_puppet_module_via_pmt_on(hosts, 'puppetlabs-mysql')
    install_puppet_module_via_pmt_on(hosts, 'puppet-epel')
    install_puppet_module_via_pmt_on(hosts, 'puppet-collections')
    install_puppet_module_via_pmt_on(hosts, 'puppet-augeasproviders_sysctl')
    install_puppet_module_via_pmt_on(hosts, 'saz-limits')
    install_puppet_module_via_pmt_on(hosts, 'puppet-archive')
    install_puppet_module_via_pmt_on(hosts, 'puppet-logrotate')
    install_puppet_module_via_pmt_on(hosts, 'treydock-munge')
    install_puppet_module_via_pmt_on(hosts, 'puppet-systemd')
    install_puppet_module_via_pmt_on(hosts, 'puppet-alternatives')
    on hosts, 'yum -y install git'
    on hosts, 'rm -rf /etc/puppetlabs/code/modules/slurm ; git clone --branch "master" https://github.com/treydock/puppet-slurm.git /etc/puppetlabs/code/modules/slurm'

    hiera_yaml = <<-HIERA
---
version: 5
defaults:
  datadir: data
  data_hash: yaml_data
hierarchy:
  - name: virtual
    path: "%{facts.virtual}.yaml"
  - name: "Munge"
    path: "munge.yaml"
  - name: "common"
    path: "common.yaml"
    HIERA
    common_yaml = <<-HIERA
munge::munge_key_source: 'puppet:///modules/site_slurm/munge.key'
slurm::install_method: source
slurm::version: '#{RSpec.configuration.slurm_version}'
slurm::client: true
slurm::slurmd: true
slurm::slurmctld: true
slurm::slurmdbd: true
slurm::database: true
slurm::slurmctld_host: 'slurm'
slurm::slurmdbd_host: 'slurm'
slurm::manage_firewall: false
slurm::partitions:
  general:
    default: 'YES'
    nodes: 'slurm'
slurm::nodes:
  slurm:
    cpus: 1
    features:
    - foo
    - bar
    HIERA
    docker_yaml = <<-HIERA
slurm::manage_firewall: false
slurm::slurm_conf_override:
  JobAcctGatherType: 'jobacct_gather/linux'
  ProctrackType: 'proctrack/linuxproc'
  TaskPlugin: 'task/affinity'
    HIERA
    create_remote_file(hosts, '/etc/puppetlabs/puppet/hiera.yaml', hiera_yaml)
    on hosts, 'mkdir -p /etc/puppetlabs/puppet/data'
    create_remote_file(hosts, '/etc/puppetlabs/puppet/data/common.yaml', common_yaml)
    create_remote_file(hosts, '/etc/puppetlabs/puppet/data/docker.yaml', docker_yaml)

    controller_pp = <<-PP
    class { 'slurm':
      slurmctld => true,
      slurmdbd  => false,
      database  => false,
    }
    Slurmdbd_conn_validator <| |> -> Class['slurm::slurmctld']
    PP
    db_pp = <<-PP
    include mysql::server
    class { 'slurm':
      slurmctld => false,
      slurmdbd  => true,
      database  => true,
    }
    PP
    apply_manifest_on(hosts, db_pp, catch_failures: true)
    apply_manifest_on(hosts, controller_pp, catch_failures: true)
  end
end

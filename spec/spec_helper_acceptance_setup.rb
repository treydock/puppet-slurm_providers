RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  c.add_setting :slurm_version
  c.slurm_version = ENV['SLURM_BEAKER_version'] || '20.02.3'

  c.add_setting :timezone_offset

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    copy_module_to(hosts, source: File.join(proj_root, 'spec/fixtures/site_slurm'), module_name: 'site_slurm', ignore_list: [])

    on hosts, 'timedatectl set-timezone America/New_York'
    on hosts, "timedatectl | grep 'Time zone:'" do
      c.timezone_offset = if stdout =~ %r{EDT}
                            -4
                          else
                            -5
                          end
    end

    # Add dependencies
    on hosts, puppet('module', 'install', 'puppetlabs-stdlib'), acceptable_exit_codes: [0, 1]
    on hosts, puppet('module', 'install', 'puppetlabs-concat'), acceptable_exit_codes: [0, 1]
    on hosts, puppet('module', 'install', 'puppetlabs-mysql'), acceptable_exit_codes: [0, 1]
    on hosts, puppet('module', 'install', 'puppet-epel'), acceptable_exit_codes: [0, 1]
    on hosts, puppet('module', 'install', 'herculesteam-augeasproviders_sysctl'), acceptable_exit_codes: [0, 1]
    on hosts, puppet('module', 'install', 'saz-limits'), acceptable_exit_codes: [0, 1]
    on hosts, puppet('module', 'install', 'puppet-archive'), acceptable_exit_codes: [0, 1]
    on hosts, puppet('module', 'install', 'puppet-logrotate'), acceptable_exit_codes: [0, 1]
    on hosts, puppet('module', 'install', 'treydock-munge'), acceptable_exit_codes: [0, 1]
    on hosts, puppet('module', 'install', 'camptocamp-systemd'), acceptable_exit_codes: [0, 1]
    on hosts, 'yum -y install git'
    on hosts, 'rm -rf /etc/puppetlabs/code/modules/slurm ; git clone https://github.com/treydock/puppet-slurm.git /etc/puppetlabs/code/modules/slurm'

    hiera_yaml = <<-EOS
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
EOS
    common_yaml = <<-EOS
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
    feature:
    - foo
    - bar
EOS
    docker_yaml = <<-EOS
slurm::manage_firewall: false
slurm::slurm_conf_override:
  JobAcctGatherType: 'jobacct_gather/linux'
  ProctrackType: 'proctrack/linuxproc'
  TaskPlugin: 'task/affinity'
slurm::manage_slurm_user: false
slurm::slurm_user: root
slurm::slurm_user_group: root
EOS
    create_remote_file(hosts, '/etc/puppetlabs/puppet/hiera.yaml', hiera_yaml)
    on hosts, 'mkdir -p /etc/puppetlabs/puppet/data'
    create_remote_file(hosts, '/etc/puppetlabs/puppet/data/common.yaml', common_yaml)
    create_remote_file(hosts, '/etc/puppetlabs/puppet/data/docker.yaml', docker_yaml)

    # Hack to work around issues with recent systemd and docker and running services as non-root
    if fact('os.family') == 'RedHat' && fact('os.release.major').to_i >= 7
      service_hack = <<-EOS
[Service]
User=root
Group=root
    EOS

      on hosts, 'mkdir -p /etc/systemd/system/munge.service.d'
      create_remote_file(hosts, '/etc/systemd/system/munge.service.d/hack.conf', service_hack)

      munge_yaml = <<-EOS
---
munge::manage_user: false
munge::user: root
munge::group: root
munge::lib_dir: /var/lib/munge
munge::log_dir: /var/log/munge
munge::conf_dir: /etc/munge
munge::run_dir: /run/munge
    EOS

      create_remote_file(hosts, '/etc/puppetlabs/puppet/data/munge.yaml', munge_yaml)

      pp = <<-EOS
      include mysql::server
      include slurm
      EOS
      apply_manifest_on(hosts, pp, catch_failures: true)
    end
  end
end

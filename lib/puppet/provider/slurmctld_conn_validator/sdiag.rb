# frozen_string_literal: true

Puppet::Type.type(:slurmctld_conn_validator).provide(:sdiag) do
  desc 'Connection validator for slurmctld'

  commands sdiag_cmd: 'sdiag'

  class << self
    attr_accessor :install_prefix
  end

  def sdiag(args, options = {})
    sdiag_path = nil
    unless @install_prefix.nil?
      sdiag_path = File.join(@install_prefix, 'bin', 'sdiag')
    end
    if sdiag_path.nil?
      sdiag_path = which('sdiag')
      Puppet.debug("Used which to find sdiag: path=#{sdiag_path}")
    end
    if sdiag_path.nil?
      [
        '/bin',
        '/usr/bin',
        '/usr/local/bin'
      ].each do |dir|
        path = File.join(dir, 'sdiag')
        next unless File.exist?(path)

        sdiag_path = path
        Puppet.debug("Used static search to find sdiag: path=#{sdiag_path}")
        break
      end
    end
    raise Puppet::Error, 'Unable to find sdiag executable' if sdiag_path.nil?

    cmd = [sdiag_path] + args
    execute(cmd, options)
  end

  def attempt_connection
    output = sdiag([], failonfail: false)
    output.exitstatus.zero?
  end

  def exists?
    start_time = Time.now
    timeout = resource[:timeout]

    success = attempt_connection

    while success == false && ((Time.now - start_time) < timeout)
      Puppet.notice('Failed to connect to slurmctld; sleeping 2 seconds before retry')
      sleep 2
      success = attempt_connection
    end

    unless success
      Puppet.notice("Failed to connect to slurmctld within timeout window of #{timeout} seconds; giving up.")
    end

    success
  end

  def create
    # If `#create` is called, that means that `#exists?` returned false, which
    # means that the connection could not be established... so we need to
    # cause a failure here.
    raise Puppet::Error, 'Unable to connect to slurmctld server!'
  end
end

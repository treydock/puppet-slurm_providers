# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sacctmgr'))

Puppet::Type.type(:slurmdbd_conn_validator).provide(:sacctmgr, parent: Puppet::Provider::Sacctmgr) do
  desc 'Connection validator for slurmdbd'

  def attempt_connection
    output = sacctmgr(['show', 'stats'], failonfail: false)
    # `sacctmgr show stats 2>/dev/null 1>/dev/null`
    output.exitstatus.zero?
  end

  def exists?
    start_time = Time.now
    timeout = resource[:timeout]

    success = attempt_connection

    while success == false && ((Time.now - start_time) < timeout)
      Puppet.notice('Failed to connect to slurmdbd; sleeping 2 seconds before retry')
      sleep 2
      success = attempt_connection
    end

    unless success
      Puppet.notice("Failed to connect to slurmdbd within timeout window of #{timeout} seconds; giving up.")
    end

    success
  end

  def create
    # If `#create` is called, that means that `#exists?` returned false, which
    # means that the connection could not be established... so we need to
    # cause a failure here.
    raise Puppet::Error, 'Unable to connect to slurmdbd server!'
  end
end

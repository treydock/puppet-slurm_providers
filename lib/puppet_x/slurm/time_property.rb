require_relative './util'
# Class to share among time properties
class PuppetX::SLURM::TimeProperty < Puppet::Property
  validate do |value|
    time = PuppetX::SLURM::Util.parse_time(value)
    if time.nil? && value.to_s != 'absent'
      raise "#{name} should be an valid time, must be [DD]-[HH]:MM:SS"
    end
    return true if value.to_s == 'absent'
    hours = time[1].to_i
    minutes = time[2].to_i
    seconds = time[3].to_i
    if hours >= 24
      raise "#{name} should not have hours greater than or equal to 24, increase days"
    end
    if minutes >= 60
      raise "#{name} should not have minutes greater than or equal to 60, increase hours"
    end
    if seconds >= 60
      raise "#{name} should not have seconds greater than or equal to 60, increase minutes"
    end
  end
end

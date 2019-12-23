require_relative './util'
# Class to share among time properties
class PuppetX::SLURM::TimeProperty < Puppet::Property
  validate do |value|
    time = PuppetX::SLURM::Util.parse_time(value)
    if time.nil? && value.to_s != 'absent'
      raise "#{name} should be an valid time"
    end
    return true if value.to_s == 'absent'
    hours = time[1]
    minutes = time[2]
    seconds = time[3]
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

  #   munge do |value|
  #     return value if value.to_s == 'absent'
  #     m = value.match(%r{^(?:([0-9]+)-)?(?:([0-9]+):)?([0-9]+):([0-9]+)$})
  #     days = m[1].nil? ? 0 : m[1].to_i
  #     extra_days =
  #     hours = m[2].nil? ? 0 : m[2].to_i
  #     minutes = m[3].to_i
  #     seconds = m[4].to_i
  #
  #   end
end

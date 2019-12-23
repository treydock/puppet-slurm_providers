# Class to share among float properties
class PuppetX::SLURM::FloatProperty < Puppet::Property
  validate do |value|
    if value.to_s !~ %r{^[0-9\.]+$} && value.to_s != 'absent'
      raise "#{name} should be a float"
    end
  end

  munge do |value|
    return value if value.to_s == 'absent'
    '%.6f' % value.to_s
  end
end

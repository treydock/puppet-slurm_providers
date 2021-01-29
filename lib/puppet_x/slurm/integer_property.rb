# Class to share among integer properties
class PuppetX::SLURM::IntegerProperty < Puppet::Property
  validate do |value|
    if value.to_s !~ %r{^[-]?[0-9]+$} && value.to_s != 'absent'
      raise "#{name} should be an integer"
    end
  end

  munge do |value|
    return value if value == :absent
    value.to_s
  end
end

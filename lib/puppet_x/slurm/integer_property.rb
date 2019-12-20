# Class to share among array properties
class PuppetX::SLURM::IntegerProperty < Puppet::Property
  validate do |value|
    if value.to_s !~ /^[0-9]+$/ && value.to_s != 'absent'
      fail "#{self.name.to_s} should be an integer"
    end
  end

  munge do |value|
    return value if value == :absent
    value.to_s
  end

#  def insync?(is)
#    is_conv = sprintf "%.6f", is.to_s
#    should_conv = sprintf "%.6f", @should.to_s
#    is_conv == should_conv
#  end
end

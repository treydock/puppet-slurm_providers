# Class to share among array properties
class PuppetX::SLURM::HashProperty < Puppet::Property
  validate do |value|
    unless value.is_a?(::Hash) || value == :absent
      fail "#{self.name.to_s} should be a Hash"
    end
  end

  def insync?(is)
    Array(is).sort == Array(@should).sort
  end

  def change_to_s(currentvalue, newvalue)
    if currentvalue != :absent
      currentvalue = currentvalue.map {|k,v| "#{k}=#{v}"}.join(',')
    end
    if newvalue != :absent
      newvalue = newvalue.map {|k,v| "#{k}=#{v}"}.join(',')
    end
    super(currentvalue, newvalue)
  end

  def is_to_s(currentvalue) # rubocop:disable Style/PredicateName
    if currentvalue != :absent
      currentvalue = currentvalue.map {|k,v| "#{k}=#{v}"}.join(',')
    end
    currentvalue
  end
  alias should_to_s is_to_s
end

# Class to share among hash properties
class PuppetX::SLURM::HashProperty < Puppet::Property
  validate do |value|
    unless value.is_a?(::Hash) || value == :absent
      raise "#{name} should be a Hash"
    end
  end

  def insync?(is)
    should = if @should.is_a?(Array)
               @should[0]
             else
               @should
             end
    if is.is_a?(Hash) && should.is_a?(Hash)
      is_sorted = Hash[is.map { |k, v| [k, v.to_s] }].sort_by { |k, _v| k }
      should_sorted = Hash[should.map { |k, v| [k, v.to_s] }].sort_by { |k, _v| k }
      return is_sorted == should_sorted
    end
    Array(is).sort == Array(should).sort
  end

  def change_to_s(currentvalue, newvalue)
    if currentvalue != :absent && currentvalue.is_a?(Hash)
      currentvalue = currentvalue.map { |k, v| "#{k}=#{v}" }.join(',')
    end
    if newvalue != :absent && newvalue.is_a?(Hash)
      newvalue = newvalue.map { |k, v| "#{k}=#{v}" }.join(',')
    end
    super(currentvalue, newvalue)
  end

  def is_to_s(currentvalue) # rubocop:disable Style/PredicateName
    if currentvalue != :absent && currentvalue.is_a?(Hash)
      currentvalue = currentvalue.map { |k, v| "#{k}=#{v}" }.join(',')
    end
    currentvalue
  end
  alias should_to_s is_to_s
end

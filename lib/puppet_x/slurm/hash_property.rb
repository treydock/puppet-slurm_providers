# Class to share among array properties
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
    Puppet.debug("DEBUG: is=#{is.class} should=#{should.class}")
    if is.is_a?(Hash) && should.is_a?(Hash)
      is.each_pair do |is_k, is_v|
        unless should.key?(is_k)
          Puppet.debug("should missing key #{is_k}")
          return false
        end
        unless should[is_k].to_s == is_v.to_s
          Puppet.debug("should != is #{should[is_k]} != #{is_v}")
          return false
        end
      end
      return true
    end
    Puppet.debug("DEBUG: #{is} == #{should}")
    Puppet.debug("DEBUG: #{Array(is)} == #{Array(should)}")
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

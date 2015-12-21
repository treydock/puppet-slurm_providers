module Puppet::Util::Slurm
  def format_tres_values(values, cpu='-1')
    values ||= ''
    tres_values = {
      'cpu'    => cpu,
      'energy' => '-1',
      'mem'    => '-1',
      'node'   => '-1',
    }
    values.split(',').each do |tres|
      tres_parts = tres.split('=')
      tres_name = tres_parts[0]
      tres_value = tres_parts[1]
      tres_values[tres_name] = tres_value
    end

    tres_values.map{ |k,v| "#{k}=#{v}" }.sort.join(',')
  end
end

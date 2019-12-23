module PuppetX # rubocop:disable Style/ClassAndModuleChildren
  module SLURM # rubocop:disable Style/ClassAndModuleChildren
    # Module for shared type configs
    module Util
      def self.parse_time(value)
        m = value.match(%r{^(?:([0-9]+)-)?(?:([0-9]+):)?([0-9]+):([0-9]+)$})
        return nil if m.nil?
        days = m[1].nil? ? 0 : m[1].to_i
        hours = m[2].nil? ? 0 : m[2].to_i
        minutes = m[3].to_i
        seconds = m[4].to_i
        time = [days, hours, minutes, seconds]
        time
      end
    end
  end
end

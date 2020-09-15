module PuppetX # rubocop:disable Style/ClassAndModuleChildren
  module SLURM # rubocop:disable Style/ClassAndModuleChildren
    # Module for shared type configs
    module Util
      def self.parse_time(value)
        m = value.match(%r{^(?:([0-9]+)-)?(?:([0-9]+):)?([0-9]+):([0-9]+)$})
        return nil if m.nil?
        days = m[1].nil? ? 0 : m[1].to_i
        hours = m[2].nil? ? 0 : m[2]
        minutes = m[3]
        seconds = m[4]
        time = [days, hours, minutes, seconds]
        time
      end

      def self.parse_datetime(value)
        m = value.match(%r{^([0-9]{4})-([0-9]{2})-([0-9]{2})(?:T([0-9]{2}):([0-9]{2})(?::([0-9]{2})?)?)?$})
        return nil if m.nil?
        year = m[1]
        month = m[2]
        day = m[3]
        hour = m[4]
        minute = m[5]
        seconds = m[6]
        datetime = [year, month, day, hour, minute, seconds]
        datetime
      end
    end
  end
end

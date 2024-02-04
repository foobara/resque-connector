require "resque"

require "foobara/all"
require "foobara/command_connectors"

module Foobara
  module ResqueConnector
    class << self
      def reset_all
        if CommandConnectors::ResqueConnector.instance_variable_defined?(:@all)
          CommandConnectors::ResqueConnector.all.clear
        end

        # TODO: protect against this in production
        Resque.redis.flushdb
      end
    end
  end
end

Foobara::Util.require_directory("#{__dir__}/../../src")

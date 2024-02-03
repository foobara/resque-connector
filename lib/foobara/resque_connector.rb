require "resque"

require "foobara/all"

module Foobara
  module ResqueConnector
    class << self
      def reset_all
        # TODO: protect against this in production
        Resque.redis.flushdb
      end
    end
  end
end

Foobara::Util.require_directory("#{__dir__}/../../src")

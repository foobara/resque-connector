module Foobara
  module CommandConnectors
    class ResqueConnector < CommandConnector
      class RunCommandAsync < Command
        class << self
          attr_accessor :target_command_class, :resque_connector
        end

        # TODO: set result type to job

        def execute
          enqueue_command

          job
        end

        attr_accessor :job

        def enqueue_command
          self.job = resque_connector.enqueue(full_command_name, raw_inputs)
        end

        def full_command_name
          target_command_class.full_command_name
        end

        def resque_connector
          self.class.resque_connector
        end

        def target_command_class
          self.class.target_command_class
        end
      end
    end
  end
end

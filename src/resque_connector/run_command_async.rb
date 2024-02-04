module Foobara
  module CommandConnectors
    class ResqueConnector < CommandConnector
      class RunCommandAsync < Command
        class << self
          attr_writer :default_resque_connector

          def default_resque_connector
            @default_resque_connector ||= ResqueConnector[nil]
          end
        end

        inputs do
          command_name :string
          # TODO: what we really want here would be :attributes, :allow_nil
          # but currently this fails because attributes are expected to have well-defined attribute types.
          command_inputs :associative_array, :allow_nil, key_type_declaration: :symbol
          # TODO: create a catch-all handler for Ruby classes
          resque_connector :duck, :allow_nil
        end

        # TODO: set result type to job

        def execute
          enqueue_command

          job
        end

        attr_accessor :job

        def enqueue_command
          self.job = resque_connector.enqueue(command_name, command_inputs)
        end

        def full_command_name
          target_command_class.full_command_name
        end

        def resque_connector
          binding.pry
        end
      end
    end
  end
end

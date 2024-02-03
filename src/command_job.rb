module Foobara
  module CommandConnectors
    class ResqueConnector < CommandConnector
      class CommandJob
        class << self
          def perform(job_data)
            job_data = job_data.transform_keys(&:to_sym)

            allowed_keys = %i[command_name inputs connector_name]

            invalid_keys = job_data.keys - allowed_keys

            if invalid_keys.any?
              # :nocov:
              raise ArgumentError, "Invalid keys: #{invalid_keys.join(", ")}"
              # :nocov:
            end

            command_name = job_data[:command_name]
            inputs = job_data[:inputs]
            connector_name = job_data[:connector_name]

            connector = ResqueConnector[connector_name]

            command_class = connector.transformed_command_from_name(command_name)
            command = command_class.new(inputs)
            command.run!
          end
        end
      end
    end
  end
end

module Foobara
  module CommandConnectors
    class ResqueConnector < CommandConnector
      class NoCommandFoundError < StandardError
        attr_accessor :command_class

        def initialize(command_class)
          # :nocov:
          self.command_class = command_class

          super("No command found for #{command_class}")
          # :nocov:
        end
      end

      class << self
        def all
          @all ||= {}
        end

        def new(...)
          instance = super

          name = instance.name

          if all.key?(name)
            # :nocov:
            raise "#{name} already registered"
            # :nocov:
          end

          all[name] = instance
        end

        def [](name)
          name = name.to_sym if name

          unless all.key?(name)
            # :nocov:
            raise "#{name} not registered"
            # :nocov:
          end

          all[name]
        end
      end

      def connect(connectable, *, queue: nil, **, &)
        exposed_commands = super(connectable, *, **, &)
        exposed_commands = Util.array(exposed_commands)

        exposed_commands.each do |exposed_command|
          command_class = exposed_command.command_class
          transformed_command_class = exposed_command.transformed_command_class

          queue ||= Resque.queue_from_class(exposed_command) || :general
          command_name_to_queue[exposed_command.full_command_name] = queue

          klass = Util.make_class("#{command_class.name}Async", RunCommandAsync)

          inputs_type = transformed_command_class.inputs_type

          if inputs_type
            klass.inputs transformed_command_class.inputs_type
          end

          klass.resque_connector = self
          klass.target_command_class = exposed_command
        end

        exposed_commands
      end

      def enqueue(command_name, inputs = nil)
        transformed_command_class = transformed_command_from_name(command_name)

        unless transformed_command_class
          # :nocov:
          raise NoCommandFoundError, command_name
          # :nocov:
        end

        job = { command_name: }
        job[:inputs] = inputs unless inputs.empty?
        job[:connector_name] = name unless name.nil?

        queue = command_name_to_queue[command_name]
        Resque.enqueue_to(queue, CommandJob, job)
      end

      def command_name_to_queue
        @command_name_to_queue ||= {}
      end
    end
  end
end

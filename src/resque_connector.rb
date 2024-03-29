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

      attr_accessor :name

      def initialize(*, name: nil, **, &)
        self.name = name.to_sym if name

        super(*, **, &)
      end

      # NOTE: inputs transformer in this context is not clear. Is it how we transform for writing the job to redis?
      # Or are we transforming what comes out of redis?  It seems like redis serialize/redis deserialize would make
      # more sense here. It feels like these types of inputs_transformer helpers from connectors like http are not
      # universally meaningful.
      # It also feels like CommandClass.run_async would be a more intuitive interface.
      # This makes run_async feel like an "action" like "run" and "help". So maybe "actions" should be viewed
      # as methods on Org/Domain/Commands/Connector.
      # However, if it made a class, like SomeCommandAsync, then it could be exposed through other connectors
      # and be declared in depends_on calls and have proper possible errors for that operation.
      # But on the downside, it would appear in the domain's list of commands unless coming up with a clear way
      # to express that. A way could be found, though. So probably creating a command class is better.
      # And in this context maybe that should be the transformed command?
      # So TransformedCommand is connector specific? And some connectors might have no TransformedCommand?
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

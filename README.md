# Foobara::ResqueConnector

`foobara-resque-connector` connects Foobara commands to Resque for asynchronous use.

## Installation

Add `foobara-resque-connector` to your Gemfile or .gemspec file and `bundle install`.

Or even just `gem install foobara-resque-connector` if playing with it directly.

## Usage

To set this up automatically in an existing Foobara project, run `foob g resque-connector`.

Otherwise, for the manual setup, require the library and connect the Foobara command you want to run asynchronously.

```ruby
require "foobara/resque_connector"

Resque.redis = Redis.new(url: ENV.fetch("REDIS_URL"))

class DoSomething < Foobara::Command
  inputs do 
    foo :integer
    bar :string
  end

  def execute
    success_message
  end

  def success_message
    "success! #{foo} #{bar}"
  end
end

connector = Foobara::CommandConnectors::ResqueConnector.new
connector.connect(DoSomething, queue: :general)
```

You can then queue the Resque job by running a command with the `Async` suffix:

```ruby
DoSomethingAsync.run!(foo: 1, bar: "bar")
```

## Contributing

Contributions are welcome on Github at [foobara/resque-connector](https://github.com/foobara/resque-connector/)

To work on an existing issue or submit a Pull Request:

1. Fork the repository and clone it onto your local machine
2. Run `bundle install` to install dependencies
3. Run `rake` to ensure that everything works as expected before making any changes
4. Implement your changes
5. Re-run `rake` to make sure that all tests and Rubocop pass
6. Commit your changes, push to Github and open a pull request for review

## License

This project is licensed under the MPL-2.0 license. Please see [LICENSE.txt](LICENSE.txt) for more information.

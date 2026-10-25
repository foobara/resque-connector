# Foobara::ResqueConnector

`foobara-resque-connector` connects Foobara commands to Resque for asynchronous use.

## Installation

Add `gem "foobara-resque-connector"` to your Gemfile or .gemspec file and `bundle install`. Or even just `gem install foobara-resque-connector` if just playing with it directly in the scripts.

## Usage

### Create a `commands.rb` file

Create an application file such as `commands.rb`. In this file require the library, tell Resque where your Redis server lives and then define the Foobara command you want to run asynchronously.

```ruby
require "foobara/resque_connector"

# Tell Resque where your Redis server lives.
Resque.redis = Redis.new(url: ENV.fetch("REDIS_URL"))

class DoSomething < Foobara::Command
  inputs do 
    foo :integer
    bar :string
  end

  def execute
    "success! #{foo} #{bar}"
  end
end

connector = Foobara::CommandConnectors::ResqueConnector.new
connector.connect(DoSomething, queue: :general)
```

### Create a `Rakefile`

In the `Rakefile` load your `commands.rb` application file and add Resque's worker tasks including `resque:work`:

```ruby
require_relative "commands"
require "resque/tasks"
```

### Add a job

In the terminal run:

```sh
REDIS_URL=redis://localhost:6379 ruby -r ./commands -e 'DoSomethingAsync.run!(foo: 1, bar: "bar")'
```

Running this command successfully queues the Resque job.

### Start a worker

In a second terminal in the same project folder, run:

```sh
REDIS_URL=redis://localhost:6379 QUEUE=general VERBOSE=1 rake resque:work
```

- `QUEUE=general` tells the worker which queue to take jobs from. It must match the queue you passed to `connect`, or the worker won't see your jobs. (Use `QUEUE=*` to watch every queue.)

Upon running the command, what you should see is output similar to the one below. This particular example output (taken from the Foobara website linked [on this page](https://github.com/foobara/foobara-www/blob/main/src/Home/Connectors/Resque/ConnectorCodeOutput.ts)) comes from a running a different command called `IncrementAge`.

```sh
export default `$ QUEUE=* VERBOSE=1 rake resque:work
*** Starting worker demo:29545:general
*** got: (Job{general} | Foobara::CommandConnectors::ResqueConnector::CommandJob | [{"command_name" => "IncrementAge", "inputs" => {"capybara" => 1}}])
*** done: (Job{general} | Foobara::CommandConnectors::ResqueConnector::CommandJob | [{"command_name" => "IncrementAge", "inputs" => {"capybara" => 1}}])
*** got: (Job{general} | Foobara::CommandConnectors::ResqueConnector::CommandJob | [{"command_name" => "IncrementAge", "inputs" => {"capybara" => 2}}])
*** done: (Job{general} | Foobara::CommandConnectors::ResqueConnector::CommandJob | [{"command_name" => "IncrementAge", "inputs" => {"capybara" => 2}}])
*** got: (Job{general} | Foobara::CommandConnectors::ResqueConnector::CommandJob | [{"command_name" => "IncrementAge", "inputs" => {"capybara" => 2}}])
*** done: (Job{general} | Foobara::CommandConnectors::ResqueConnector::CommandJob | [{"command_name" => "IncrementAge", "inputs" => {"capybara" => 2}}])
*** ^C Exiting...
$ ./capybaras-cli FindAllCapybaras
{
  id: 1,
  name: "Fumiko",
  nickname: "foo",
  age: 101
},
{
  id: 2,
  name: "Barbara",
  nickname: "bar",
  age: 102
}`
```

## Named connectors

You can skip this section until you need more than one connector.

By default, the connector you create has no name. Each connector's name must be unique within your program, and the unnamed connector counts as having the name `nil` meaning you can only have one unnamed connector.

To create and look up a named connector (in this example below, the connector is named `:background`):

```ruby
connector = Foobara::CommandConnectors::ResqueConnector.new(name: :background)

Foobara::CommandConnectors::ResqueConnector[:background]
```

Your job-adding code and your worker must register the **same connector name and the same connector commands**. The easiest way to guarantee this is to load the same `commands.rb` in both.

## Contributing

Contributions in the form of Bug reports and pull requests are always welcome at [foobara/resque-connector](https://github.com/foobara/resque-connector/)

To work on an existing issue or submit a Pull Request:

1. Fork the repository and clone it onto your local machine
2. Run `bundle install` to install dependencies
3. Run `rake` to ensure that everything works as expected before making any changes
4. Implement your changes
5. Re-run `rake` to make sure that all tests and Rubocop pass
6. Commit your changes, push to Github and open a pull request for review

## License

This project is licensed under the MPL-2.0 license. Please see [LICENSE.txt](LICENSE.txt) for more information.

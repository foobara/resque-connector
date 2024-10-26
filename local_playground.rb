require "bundler/setup"

require "pry"
require "pry-byebug"

require "foobara/load_dotenv"

Foobara::LoadDotenv.run!

require "foobara/resque_connector"

if ENV["REDIS_URL"]
  Resque.redis = Redis.new(url: ENV["REDIS_URL"])
else
  # :nocov:
  raise 'Must set ENV["REDIS_URL"] if trying to initialize RedisCrudDriver with no arguments'
  # :nocov:
end

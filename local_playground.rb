require "bundler/setup"

require "pry"
require "pry-byebug"

require "foobara/load_dotenv"

# TODO: setup boot pattern here
Foobara::LoadDotenv.run!(env: "development")

require "foobara/resque_connector"

if ENV["REDIS_URL"]
  Resque.redis = Redis.new(url: ENV["REDIS_URL"])
else
  raise NoRedisUrlError,
        'Must set ENV["REDIS_URL"] if trying to initialize RedisCrudDriver with no arguments'
end

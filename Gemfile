require_relative "version"

source "https://rubygems.org"
ruby Foobara::ResqueConnector::MINIMUM_RUBY_VERSION

gemspec

# gem "foobara", path: "../foobara"

group :development do
  gem "foobara-rubocop-rules", ">= 1.0.0"
  gem "rubocop-rake"
end

group :test do
  gem "foobara-spec-helpers", "< 2.0.0"
  gem "rspec"
  gem "rspec-its"
  gem "rubocop-rspec"
  gem "simplecov"
end

group :development, :test do
  gem "foobara-dotenv-loader", "< 2.0.0"
  gem "rake"

  gem "guard-rspec"
  gem "pry"
  gem "pry-byebug"
  # TODO: Just adding this to suppress warnings seemingly coming from pry-byebug. Can probably remove this once
  # pry-byebug has irb as a gem dependency
  gem "irb"
end

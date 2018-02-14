require "bundler/setup"
require "action_channels"

require 'logger'

LOGGER_PATH = File.expand_path('../../tmp/test.log', __FILE__)
FileUtils.mkdir_p File.dirname(LOGGER_PATH)

ActionChannels.configure do |config|
  config.logger = Logger.new(LOGGER_PATH)
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

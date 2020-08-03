require "bundler/setup"
require "hotel_price"
Dir["rakuten/*.rb"].each { |file| require file }
Dir["jalan/*.rb"].each { |file| require file }
Dir["agoda/*.rb"].each { |file| require file }
Dir["booking/*.rb"].each { |file| require file }
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

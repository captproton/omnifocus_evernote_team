require 'cgi'
require 'fileutils'
require 'nokogiri'
require 'rubygems'

# Use require_relative to load models directly, avoiding
# heavy Thor/Rails deps that are not needed in tests
require_relative '../models/project'
require_relative '../models/link_file'
require_relative '../models/note'

RSpec.configure do |config|
  # Use expect syntax only (no should syntax)
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # Use the newer mock syntax
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Run specs in a random order to surface implicit dependencies
  config.order = :random
  Kernel.srand config.seed

  # Focus on failing specs with :focus tag
  config.filter_run_when_matching :focus

  # Print 10 slowest specs when running the full suite
  config.profile_examples = 10

  # Disable monkey patching (forces explicit `RSpec.describe`)
  config.disable_monkey_patching!
end

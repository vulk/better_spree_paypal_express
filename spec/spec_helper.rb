if ENV["COVERAGE"]
  require_relative 'rcov_exclude_list.rb'
  exlist = Dir.glob(@exclude_list)
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start do
    exlist.each do |p|
      add_filter p
    end
  end
end

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'rspec/rails'
require 'database_cleaner'
require 'ffaker'
require 'pry'
require 'capybara/rspec'
require 'capybara/rails'
# require 'capybara/poltergeist'
 
# Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = 15

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

require 'spree/core/testing_support/factories'
require 'spree/core/testing_support/controller_requests'
require 'spree/core/testing_support/authorization_helpers'
require 'spree/core/url_helpers'

require 'spree_paypal_express/factories'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Spree::Core::UrlHelpers
  config.extend AuthorizationHelpers::Request, :type => :feature

  config.mock_with :rspec
  config.color = true
  config.use_transactional_fixtures = false

  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.before do
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.fail_fast = ENV['FAIL_FAST'] || false
end

if ENV["COVERAGE"]
  # Load all files except the ones in exclude list
  require_all(Dir.glob('**/*.rb') - exlist)
end

require 'bundler/setup'
require 'rspec'
require 'orm'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after do
    %i(SomeClass SomeSubClass SomeModule SomeOtherModule A B C D E F G).each do |it|
      if Object.const_defined? it
        Object.send :remove_const, it
      end
    end
  end

  config.full_backtrace = true
end

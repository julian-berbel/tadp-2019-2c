require 'bundler/setup'
require 'rspec'
require 'orm'

RSpec.configure do |config|
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

    TADB::DB.clear_all
  end
end

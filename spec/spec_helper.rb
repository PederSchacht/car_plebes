require 'rspec/expectations'
$LOAD_PATH << "lib"
$LOAD_PATH << "models"

require 'environment'
require 'account'
require 'expense'
require 'car'

Environment.environment = "test"

def run_car_plebes_with_input(*inputs)
  shell_output = ""
  IO.popen('ENVIRONMENT=test ./car_plebes', 'r+') do |pipe|
    inputs.each do |input|
      pipe.puts input
    end
    pipe.close_write
    shell_output << pipe.read
  end
  shell_output
end

RSpec.configure do |config|
  config.after(:each) do
    Environment.database_connection.execute("DELETE from accounts;")
    Environment.database_connection.execute("DELETE from expenses;")
    Environment.database_connection.execute("DELETE from cars;")
  end
end

RSpec::Matchers.define :include_in_order do |*expected|
  match do |actual|
    input = actual.delete("\n")
    regex_string = expected.join(".*").gsub("?","\\?").gsub("\n",".*")
    result = /#{regex_string}/.match(input)
    result.should be
  end
end

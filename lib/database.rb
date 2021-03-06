require "sqlite3"

class Database < SQLite3::Database
  def initialize(database)
    super(database)
    self.results_as_hash = true
  end

  def self.connection(environment)
    @connection ||= Database.new("db/car_plebes_#{environment}.sqlite3")
  end

  def create_tables
    self.execute("CREATE TABLE accounts (id INTEGER PRIMARY KEY AUTOINCREMENT, name varcar(50), income INTEGER)")
    self.execute("CREATE TABLE expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, name varcar(50), cost INTEGER, account_id INTEGER, FOREIGN KEY(account_id) REFERENCES accounts(id))")
    self.execute("CREATE TABLE cars (id INTEGER PRIMARY KEY AUTOINCREMENT, name varcar(50), price INTEGER)")
  end

  def execute(statement, bind_vars = [])
    Environment.logger.info("Executing: #{statement} with: #{bind_vars}")
    super(statement, bind_vars)
  end
end

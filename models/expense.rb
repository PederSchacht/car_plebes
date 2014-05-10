class Expense
  attr_reader :errors, :id
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def self.all
    statement = "Select * from expenses;"
    execute_and_instantiate(statement)
  end

  def self.count
    statement = "Select count(*) from expenses;"
    result = Environment.database_connection.execute(statement)
    result[0][0]
  end

  def self.create(name)
    expense = Expense.new(name)
    expense.save
    expense
  end

  def self.find_by_name(name)
    statement = "Select * from expenses where name = ?;"
    execute_and_instantiate(statement, name)[0]
  end

  def self.last
    statement = "Select * from expenses order by id DESC limit(1);"
    execute_and_instantiate(statement)[0]
  end

  def save
    if self.valid?
      statement = "Insert into expenses (name) values (?);"
      Environment.database_connection.execute(statement, name)
      @id = Environment.database_connection.execute("Select last_insert_rowid();")[0][0]
      true
    else
      false
    end
  end

  def valid?
    @errors = []
    if !name.match /[a-zA-Z]/
      errors << "'#{self.name}' is not a valid expense name, as it does not include any letters."
    end
    if Expense.find_by_name(self.name)
      @errors << "#{self.name} already exists."
    end
    @errors.empty?
  end

  private

  def self.execute_and_instantiate(statement, bind_vars = [])
    rows = Environment.database_connection.execute(statement, bind_vars)
    results = []
    rows.each do |row|
      expense = Expense.new(row["name"])
      expense.instance_variable_set(:@id, row["id"])
      results << expense
    end
    results
  end
end

class Expense
  attr_reader :errors, :id
  attr_accessor :name, :cost, :account_id

  def initialize(name, cost, account_id)
    @name = name
    @cost = cost
    @account_id = account_id
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

  def self.create(name, cost, account_id)
    expense = Expense.new(name, cost, account_id)
    expense.save
    expense
  end

  def self.find_by_name(name, account_id)
    statement = "Select * from expenses where name = ? and account_id = ?;"
    execute_and_instantiate(statement, [name, account_id])[0]
  end

  def self.last
    statement = "Select * from expenses order by id DESC limit(1);"
    execute_and_instantiate(statement)[0]
  end

  def save
    if self.valid?
      statement = "Insert into expenses (name, cost, account_id) values (?,?,?);"
      Environment.database_connection.execute(statement, [name, cost, account_id])
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
    if Expense.find_by_name(self.name, self.account_id)
      @errors << "#{self.name} already exists."
    end
    @errors.empty?
  end

  def self.delete(expense)
    expense_name = expense.name
    statement = "Delete from expenses where name ='#{expense_name}';"
    execute_and_instantiate(statement)
  end

  private

  def self.execute_and_instantiate(statement, bind_vars = [])
    rows = Environment.database_connection.execute(statement, bind_vars)
    results = []
    rows.each do |row|
      expense = Expense.new(row["name"], row["cost"], row["account_id"])
      expense.instance_variable_set(:@id, row["id"])
      results << expense
    end
    results
  end
end

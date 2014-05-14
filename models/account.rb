class Account
  attr_reader :errors, :id
  attr_accessor :name, :income

  def initialize(name, income)
    @name = name
    @income = income
  end

  def self.all
    statement = "Select * from accounts;"
    execute_and_instantiate(statement)
  end

  def self.count
    statement = "Select count(*) from accounts;"
    result = Environment.database_connection.execute(statement)
    result[0][0]
  end

  def self.create(name, income)
    account = Account.new(name, income)
    account.save
    account
  end

  def self.find_by_name(name)
    statement = "Select * from accounts where name = ?;"
    execute_and_instantiate(statement, name)[0]
  end

  def self.last
    statement = "Select * from accounts order by id DESC limit(1);"
    execute_and_instantiate(statement)[0]
  end

  def save
    if self.valid?
      statement = "Insert into accounts (name, income) values (?,?);"
      Environment.database_connection.execute(statement, [name, income])
      @id = Environment.database_connection.execute("SELECT last_insert_rowid();")[0][0]
      true
    else
      false
    end
  end

  def valid?
    @errors = []
    if !name.match /[a-zA-Z]/
      @errors << "'#{self.name}' is not a valid account name, as it does not include any letters."
    end
    if Account.find_by_name(self.name)
      @errors << "#{self.name} already exists."
    end
    @errors.empty?
  end

  private

  def self.execute_and_instantiate(statement, bind_vars = [])
    rows = Environment.database_connection.execute(statement, bind_vars)
    results = []
    rows.each do |row|
      account = Account.new(row["name"], row["income"])
      account.instance_variable_set(:@id, row["id"])
      results << account
    end
    results
  end
end

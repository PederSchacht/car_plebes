class Car
  attr_reader :errors, :id
  attr_accessor :name, :price

  def initialize(name, price)
    @name = name
    @price = price
  end

  def self.all
    statement = "Select * from cars;"
    execute_and_instantiate(statement)
  end

  def self.count
    statement = "Select count(*) from cars;"
    result = Environment.database_connection.execute(statement)
    result[0][0]
  end

  def self.create(name, price)
    car = Car.new(name, price)
    car.save
    car
  end

  def self.find_by_name(name)
    statement = "Select * from cars where name = ?;"
    execute_and_instantiate(statement, name)[0]
  end

  def self.last
    statement = "Select * from cars order by id DESC limit(1);"
    execute_and_instantiate(statement)[0]
  end

  def save
    if self.valid?
      statement = "Insert into cars (name, price) values (?,?);"
      Environment.database_connection.execute(statement, [name, price])
      @id = Environment.database_connection.execute("Select last_insert_rowid();")[0][0]
      true
    else
      false
    end
  end

  def valid?
    @errors = []
    if !name.match /[a-zA-Z]/
      errors << "'#{self.name}' is not a valid car name, as it does not include any letters."
    end
    if Car.find_by_name(self.name)
      @errors << "#{self.name} already exists."
    end
    @errors.empty?
  end

  private

  def self.execute_and_instantiate(statement, bind_vars = [])
    rows = Environment.database_connection.execute(statement, bind_vars)
    results = []
    rows.each do |row|
      car = Car.new(row["name"], row["price"])
      car.instance_variable_set(:@id, row["id"])
      results << car
    end
    results
  end
end

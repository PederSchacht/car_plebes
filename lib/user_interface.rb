require 'account'
require 'expense'
require 'car'
require 'menus'

def account_id
  @account_id
end

def account_id=(str)
  @account_id = str
end

def get_menu_selection
  puts menu
  input = gets
  return unless input
  input.chomp!
  if input == "1"
    create_account
    get_menu_selection
  elsif input == "2"
    update_account
    get_menu_selection
  elsif input == "3"
    view_account
    get_menu_selection
  elsif input == "4"
    can_i_car
    get_menu_selection
  elsif input == "5"
    exit
  else
    puts "'#{input}' is not a valid selection"
    get_menu_selection
  end
end

private

def create_account
  puts "Who's account will this be?"
  account_name = gets
  return unless account_name
  account_name.chomp!
  puts "What is the #{account_name}'s monthly income?"
  account_income = gets
  return unless account_income
  account_income.chomp!
  account = Account.new(account_name, account_income)
  if account.save
    puts "#{account_name} has been added."
  else
    puts account.errors
    create_account
  end
end

def update_account
  puts "Who's account do you want to update?"
  account_name = gets
  return unless account_name
  account_name.chomp!
  account = Account.find_by_name(account_name)
  if account
    @account_id = account.id
    get_update_menu_selection
  else
    puts "Account '#{account_name}' does not exit. Please try again."
    update_account
  end
end

def update_income
  puts "What is the new income for this account?"
  new_income = gets
  return unless new_income
  new_income.chomp!
  Account.update(@account_id, new_income)
  puts "The account income has been set to #{new_income}"
end

def update_expenses
  puts update_expenses_menu
  input = gets
  return unless input
  input.chomp!
  if input == "1"
    add_expense
    update_expenses
  elsif input == "2"
    remove_expense
    update_expenses
  elsif input == "3"
    get_update_menu_selection
  else
    puts "'#{input}' is not a valid selection"
    update_expenses
  end
end

def add_expense
  puts "What expense do you want to add?"
  new_expense = gets
  return unless new_expense
  new_expense.chomp!
  puts "What does this expense cost per month?"
  new_expense_cost = gets
  return unless new_expense_cost
  new_expense_cost.chomp!
  expense = Expense.new(new_expense, new_expense_cost, @account_id)
  if expense.save
    puts "#{new_expense} has been added"
  else
    puts expense.errors
    add_expense
  end
  get_add_expense_menu
end

def get_add_expense_menu
  puts add_expense_menu
  input = gets
  return unless input
  input.chomp!
  if input == "1"
    add_expense
  elsif input == "2"
    return
  else
    puts "'#{input}' is not a valid selection"
    get_add_expense_menu
  end
end

def remove_expense
  puts "What expense do you want to remove?"
  new_expense = gets
  return unless new_expense
  new_expense.chomp!
  expense = Expense.find_by_name(new_expense, @account_id)
  if expense
    Expense.delete(expense)
    puts "#{new_expense} has been removed"
  else
    puts expense.errors
    remove_expense
  end
  get_remove_expense_menu
end

def get_remove_expense_menu
  puts remove_expense_menu
  input = gets
  return unless input
  input.chomp!
  if input == "1"
    remove_expense
  elsif input == "2"
    return
  else
    puts "'#{input}' is not a valid selection"
    get_remove_expense_menu
  end
end

def get_update_menu_selection
  puts update_menu
  input = gets
  return unless input
  input.chomp!
  if input == "1"
    update_income
    get_update_menu_selection
  elsif input == "2"
    update_expenses
    get_update_menu_selection
  elsif input == "3"
    get_menu_selection
  else
    puts "'#{input}' is not a valid selection"
    get_update_menu_selection
  end
end

def view_account
  puts "Who's account do you want to view?"
  account_name = gets
  return unless account_name
  account_name.chomp!
  account = Account.find_by_name(account_name)
  if account
    Account.display_account(account)
  else
    puts "Account '#{account.name}' does not exit. Please try again."
    view_account
  end
end

def can_i_car
  puts "Who wants to know?"
  account_name = gets
  return unless account_name
  account_name.chomp!
  account = Account.find_by_name(account_name)
  unless account
    puts "Account '#{account.name}' does not exit. Please try again."
    can_i_car
  end
  avaliable_funds = Account.get_avaliable_funds(account)
  puts "What car do you want to buy?"
  car_name = gets
  return unless car_name
  car_name.chomp!
  car = Car.find_by_name(car_name)
  if car
    price = car.price
    can_i_get(car_name, price, avaliable_funds)
  else
    puts "What does a #{car_name} cost?"
    car_price = gets
    return unless car_price
    car_price.chomp!
    new_car = Car.new(car_name, car_price)
    if new_car.save
      can_i_get(car_name, car_price, avaliable_funds)
    else
      puts new_car.errors
      can_i_car
    end
  end
end

def can_it_be_afforded(price, avaliable_funds)
  if price <= (avaliable_funds * 48)
    true
  else
    false
  end
end

def can_i_get(car_name, new_car_price, avaliable_funds)
  price = new_car_price.to_i
  result = can_it_be_afforded(price, avaliable_funds)
  if result == true
    if car_name.downcase.start_with?("a", "e", "i","o", "u")
      puts "You can afford an #{car_name} congratulations!"
    else
      puts "You can afford a #{car_name} congratulations!"
    end
  else
    if car_name.downcase.start_with?("a", "e", "i", "o", "u")
      puts "Sorry looks like you need more disposable income to afford an #{car_name}"
    else
      puts "Sorry looks like you need more disposable income to afford a #{car_name}. "
    end
  end
end

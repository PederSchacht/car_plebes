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
  puts "#{new_expense} has been removed"
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
    display_account(account)
  else
    puts "Account '#{account.name}' does not exit. Please try again."
    view_account
  end
end

def display_account(account)
  puts "displaying #{account.name}'s account"
end

def can_i_car
  puts "What car do you want to buy?"
  car_name = gets
  return unless car_name
  car_name.chomp!
  car = Car.find_by_name(car_name)
  if car
    can_i_get(car_name)
  else
    puts "What does a #{car_name} cost?"
    car_cost = gets
    new_car = Car.new(car_name)
    if new_car.save
      can_i_get(car_name)
    else
      puts new_car.errors
      can_i_car
    end
  end
end

def can_i_get(car_name)
  puts "You can afford #{car_name} congratulations!"
end

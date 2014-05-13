require_relative '../spec_helper'

describe "Adding an expense" do
  before do
    account = Account.new("Sam")
    account.save
    expense = Expense.new("Rent")
    expense.save
  end
  context "adding a unique expense" do
    let!(:output){ run_car_plebes_with_input("2", "Sam",  "2", "1", "Groceries", "25") }
    it "should print a confirmation message" do
      output.should include("Groceries has been added")
      Expense.count.should == 2
    end
    it "should insert a new expense" do
      Expense.count.should == 2
    end
    it "should use the name we entered" do
      Expense.last.name.should == "Groceries"
    end
  end
  context "adding a duplicate expense" do
    let(:output){ run_car_plebes_with_input("2", "Sam", "2", "1", "Rent", "30") }
    it "should print an error message" do
      output.should include("Rent already exists")
    end
    it "should ask them to try again" do
      menu_text = "What expense do you want to add?"
      output.should include_in_order(menu_text, "already exists", menu_text)
    end
    it "shouldn't save the duplicate" do
      Expense.count.should == 1
    end
    context "and trying again" do
      let!(:output){ run_car_plebes_with_input("2", "Sam", "2", "1", "Rent", "30", "Student Loans", "33") }
      it "should save a unique item" do
        Expense.last.name.should == "Student Loans"
      end
      it "should print a success message at the end" do
        output.should include("Student Loans has been added")
      end
    end
  end
  context "entering an invalid looking expense name" do
    context "with SQL injection" do
      let(:input){ "lunch'), ('425" }
      let!(:output){ run_car_plebes_with_input("2", "Sam", "2", "1", input, "22") }
      it "should create the expense without evaluating the SQL" do
        Expense.last.name.should == input
      end
      it "shouldn't create an extra expense" do
        Expense.count.should == 2
      end
      it "should print a success message at the end" do
        output.should include("#{input} has been added")
      end
    end
    context "without alphabet characters" do
      let(:output){ run_car_plebes_with_input("2", "Sam", "2", "1", "4*25", "44") }
      it "should not save the expense" do
        Expense.count.should == 1
      end
      it "should print an error message" do
        output.should include("'4*25' is not a valid expense name, as it does not include any letters.")
      end
      it "should let them try again" do
        menu_text = "What expense do you want to add?"
        output.should include_in_order(menu_text, "not a valid", menu_text)
      end
    end
  end
end

require_relative '../spec_helper'

describe "Adding an account" do
  before do
    account = Account.new("Jane")
    account.save
  end
  context "adding a unique account" do
    let!(:output){ run_car_plebes_with_input("1", "Joe") }
    it "should print a confirmation message" do
      output.should include("Joe has been added.")
      Account.count.should == 2
    end
    it "should insert a new account" do
      Account.count.should == 2
    end
    it "should use the name we entered" do
      Account.last.name.should == "Joe"
    end
  end
  context "adding a duplicate account" do
    let(:output){ run_car_plebes_with_input("1", "Jane") }
    it "should print an error message" do
      output.should include("Jane already exists.")
    end
    it "should ask them to try again" do
      menu_text = "Who's account will this be?"
      output.should include_in_order(menu_text, "already exists", menu_text)
    end
    it "shouldn't save the duplicate" do
      Account.count.should == 1
    end
    context "and trying again" do
      let!(:output){ run_car_plebes_with_input("1", "Jane", "Sandy") }
      it "should save a unique item" do
        Account.last.name.should == "Sandy"
      end
      it "should print a success message at the end" do
        output.should include("Sandy has been added")
      end
    end
  end
  context "entering an invalid looking account name" do
    context "with SQL injection" do
      let(:input){ "phalangectomy'), ('425" }
      let!(:output){ run_car_plebes_with_input("1", input) }
      it "should create the account without evaluating the SQL" do
        Account.last.name.should == input
      end
      it "shouldn't create an extra account" do
        Account.count.should == 2
      end
      it "should print a success message at the end" do
        output.should include("#{input} has been added")
      end
    end
    context "without alphabet characters" do
      let(:output){ run_car_plebes_with_input("1", "4*25") }
      it "should not save the account" do
        Account.count.should == 1
      end
      it "should print an error message" do
        output.should include("'4*25' is not a valid account name, as it does not include any letters.")
      end
      it "should let them try again" do
        menu_text = "Who's account will this be?"
        output.should include_in_order(menu_text, "not a valid", menu_text)
      end
    end
  end
end


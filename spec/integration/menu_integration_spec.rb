require_relative '../spec_helper'

describe "Menu Integration" do
  let(:menu_text) do
<<EOS
What do you want to do?
1. Create Account
2. Update Account
3. View Account
4. Can I Afford This Car?
5. Exit
EOS
  end
  context "the menu displays on startup" do
    let(:shell_output){ run_car_plebes_with_input() }
    it "should print the menu" do
      shell_output.should include(menu_text)
    end
  end
  context "the user selects 1" do
    let(:shell_output){ run_car_plebes_with_input("1") }
    it "should print the next menu" do
      shell_output.should include("Who's account will this be?")
    end
  end
  context "the user selects 2" do
    let(:shell_output){ run_car_plebes_with_input("2") }
    it "should print the next menu" do
      shell_output.should include("Who's account do you want to update?")
    end
  end
  context "the user selects 3" do
    let(:shell_output){ run_car_plebes_with_input("3") }
    it "should print the next menu" do
      shell_output.should include("Who's account do you want to view?")
    end
  end
  context "the user selects 4" do
    let(:shell_output){ run_car_plebes_with_input("4") }
    it "should print the next menu" do
      shell_output.should include("What car do you want to buy?")
    end
  end
  context "if the user types in the wrong input" do
    let(:shell_output){ run_car_plebes_with_input("6") }
    it "should print the menu again" do
      shell_output.should include_in_order(menu_text, "6", menu_text)
    end
    it "should include an appropriate error message" do
      shell_output.should include("'6' is not a valid selection")
    end
  end
  context "if the user types in no input" do
    let(:shell_output){ run_car_plebes_with_input("") }
    it "should print the menu again" do
      shell_output.should include_in_order(menu_text, menu_text)
    end
    it "should include an appropriate error message" do
      shell_output.should include("'' is not a valid selection")
    end
  end
  context "if the user types in incorrect input, it should allow correct input" do
    let(:shell_output){ run_car_plebes_with_input("6", "4") }
    it "should include the appropriate menu" do
      shell_output.should include("What car do you want to buy?")
    end
  end
  context "if the user types in incorrect input multiple times, it should allow correct input" do
    let(:shell_output){ run_car_plebes_with_input("6","", "4") }
    it "should include the appropriate menu" do
      shell_output.should include("What car do you want to buy?")
    end
  end
end

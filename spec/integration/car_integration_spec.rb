require_relative '../spec_helper'

describe "Adding a car" do
  before do
    account = Account.new("Sam", 25)
    account.save
    car = Car.new("Ferrari", 33)
    car.save
  end
  context "adding a unique car" do
    let!(:output){ run_car_plebes_with_input("4", "Sam", "Aston Martin", "5000") }
    it "should insert a new car" do
      Car.count.should == 2
    end
    it "should use the name we entered" do
      Car.last.name.should == "Aston Martin"
    end
  end
  context "adding a duplicate car" do
    let(:output){ run_car_plebes_with_input("4", "Sam", "Ferrari") }
    it "should skip asking for the car's price" do
      output.should_not include("What does a Ferrari cost?")
    end
    it "shouldn't save the duplicate" do
      Car.count.should == 1
    end
  end
  context "entering an invalid looking car name" do
    context "with SQL injection" do
      let(:input){ "Honda'), ('425" }
      let!(:output){ run_car_plebes_with_input("4", "Sam", input, "5000") }
      it "should create the car without evaluating the SQL" do
        Car.last.name.should == input
      end
      it "shouldn't create an extra car" do
        Car.count.should == 2
      end
    end
    context "without alphabet characters" do
      let(:output){ run_car_plebes_with_input("4", "Sam", "4*25", "5000") }
      it "should not save the car" do
        Car.count.should == 1
      end
      it "should print an error message" do
        output.should include("'4*25' is not a valid car name, as it does not include any letters.")
      end
      it "should let them try again" do
        menu_text = "Who wants to know?"
        output.should include_in_order(menu_text, "not a valid", menu_text)
      end
    end
  end
end


require_relative '../spec_helper'

describe Car do
  context ".all" do
    context "with no cars in the database" do
      it "should return an empty array" do
        Car.all.should == []
      end
    end
    context "with multiple cars in the database" do
      let!(:foo){ Car.create("Foo") }
      let!(:bar){ Car.create("Bar") }
      let!(:baz){ Car.create("Baz") }
      let!(:grille){ Car.create("Grille") }
      it "should return all of the cars" do
        car_attrs = Car.all.map{ |car| [car.name,car.id] }
        car_attrs.should == [["Foo", foo.id],
                                ["Bar", bar.id],
                                ["Baz", baz.id],
                                ["Grille", grille.id]]
      end
    end
  end

  context ".count" do
    context "with no cars in the database" do
      it "should return 0" do
        Car.count.should == 0
      end
    end
    context "with multiple cars in the database" do
      before do
        Car.new("Foo").save
        Car.new("Bar").save
        Car.new("Baz").save
        Car.new("Grille").save
      end
      it "should return the correct count" do
        Car.count.should == 4
      end
    end
  end

  context ".find_by_name" do
    context "with no cars in the database" do
      it "should return 0" do
        Car.find_by_name("Foo").should be_nil
      end
    end
    context "with car by that name in the database" do
      let(:foo){ Car.create("Foo") }
      before do
        foo
        Car.new("Bar").save
        Car.new("Baz").save
        Car.new("Grille").save
      end
      it "should return the car with that name" do
        Car.find_by_name("Foo").id.should == foo.id
      end
      it "should return the car with that name" do
        Car.find_by_name("Foo").name.should == foo.name
      end
    end
  end

  context ".last" do
    context "with no cars in the database" do
      it "should return nil" do
        Car.last.should be_nil
      end
    end
    context "with multiple cars in the database" do
      before do
        Car.new("Foo").save
        Car.new("Bar").save
        Car.new("Baz").save
        Car.new("Grille").save
      end
      it "should return the last one inserted" do
        Car.last.name.should == "Grille"
      end
    end
  end

  context "#new" do
    let(:car){ Car.new("Ferrari") }
    it "should store the name" do
      car.name.should == "Ferrari"
    end
  end

  context "#save" do
    let(:result){ Environment.database_connection.execute("Select * from cars") }
    let(:car){ Car.new("foo") }
    context "with a valid car" do
      before do
        car.stub(:valid?){ true }
      end
      it "should only save one row to the database" do
        car.save
        result.count.should == 1
      end
      it "should actually save it to the database" do
        car.save
        result[0]["name"].should == "foo"
      end
      it "should record the new id" do
        car.save
        car.id.should == result[0]["id"]
      end
    end
    context "with an invalid car" do
      before do
        car.stub(:valid?){ false }
      end
      it "should not save a new Car" do
        car.save
        result.count.should == 0
      end
    end
  end

  context "#valid?" do
    let(:result){ Environment.database_connection.execute("Select name from cars") }
    context "after fixing the errors" do
      let(:car){ Car.new("123") }
      it "should return true" do
        car.valid?.should be_false
        car.name = "Ferrari"
        car.valid?.should be_true
      end
    end
    context "with a unique name" do
      let(:car){ Car.new("Audi") }
      it "should return true" do
        car.valid?.should be_true
      end
    end
    context "with a invalid name" do
      let(:car){ Car.new("420") }
      it "should return false" do
        car.valid?.should be_false
      end
      it "should save the error messages" do
        car.valid?
        car.errors.first.should == "'420' is not a valid car name, as it does not include any letters."
      end
    end
    context "with a duplicate name" do
      let(:name){ "Porsche" }
      let(:car){ Car.new(name) }
      before do
        Car.new(name).save
      end
      it "should return false" do
        car.valid?.should be_false
      end
      it "should save the error messages" do
        car.valid?
        car.errors.first.should == "#{name} already exists."
      end
    end
  end
end


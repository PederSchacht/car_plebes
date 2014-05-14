require_relative '../spec_helper'

describe Car do
  context ".all" do
    context "with no cars in the database" do
      it "should return an empty array" do
        Car.all.should == []
      end
    end
    context "with multiple cars in the database" do
      let!(:foo){ Car.create("Foo", 25) }
      let!(:bar){ Car.create("Bar", 30) }
      let!(:baz){ Car.create("Baz", 20) }
      let!(:grille){ Car.create("Grille", 40) }
      it "should return all of the cars" do
        car_attrs = Car.all.map{ |car| [car.name,car.price,car.id] }
        car_attrs.should == [["Foo", 25, foo.id],
                             ["Bar", 30, bar.id],
                             ["Baz", 20, baz.id],
                             ["Grille", 40, grille.id]]
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
        Car.new("Foo", 25).save
        Car.new("Bar", 30).save
        Car.new("Baz", 20).save
        Car.new("Grille", 40).save
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
      let(:foo){ Car.create("Foo", 25) }
      before do
        foo
        Car.new("Bar", 30).save
        Car.new("Baz", 20).save
        Car.new("Grille", 40).save
      end
      it "should return the car with that name" do
        Car.find_by_name("Foo").id.should == foo.id
      end
      it "should return the car with that name" do
        Car.find_by_name("Foo").name.should == foo.name
      end
      it "should return the car with that price" do
        Car.find_by_name("Foo").price.should == foo.price
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
        Car.new("Foo", 25).save
        Car.new("Bar", 30).save
        Car.new("Baz", 20).save
        Car.new("Grille", 40).save
      end
      it "should return the last one inserted" do
        Car.last.name.should == "Grille"
      end
    end
  end

  context "#new" do
    let(:car){ Car.new("Ferrari", 15) }
    it "should store the name" do
      car.name.should == "Ferrari"
    end
    it "should store the price" do
      car.price.should == 15
    end
  end

  context "#save" do
    let(:result){ Environment.database_connection.execute("Select * from cars") }
    let(:car){ Car.new("foo", 25) }
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
      it "should record the new price" do
        car.save
        car.price.should == result[0]["price"]
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
      let(:car){ Car.new("123", 55) }
      it "should return true" do
        car.valid?.should be_false
        car.name = "Ferrari"
        car.price = 55
        car.valid?.should be_true
      end
    end
    context "with a unique name" do
      let(:car){ Car.new("Audi", 35) }
      it "should return true" do
        car.valid?.should be_true
      end
    end
    context "with a invalid name" do
      let(:car){ Car.new("420", 18) }
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
      let(:car){ Car.new(name, 38) }
      before do
        Car.new(name, 38).save
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


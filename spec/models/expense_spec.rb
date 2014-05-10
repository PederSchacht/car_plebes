require_relative '../spec_helper'

describe Expense do
  context ".all" do
    context "with no expenses in the database" do
      it "should return an empty array" do
        Expense.all.should == []
      end
    end
    context "with multiple expenses in the database" do
      let!(:foo){ Expense.create("Foo") }
      let!(:bar){ Expense.create("Bar") }
      let!(:baz){ Expense.create("Baz") }
      let!(:grille){ Expense.create("Grille") }
      it "should return all of the Expenses" do
        expense_attrs = Expense.all.map{ |expense| [expense.name,expense.id] }
        expense_attrs.should == [["Foo", foo.id],
                                ["Bar", bar.id],
                                ["Baz", baz.id],
                                ["Grille", grille.id]]
      end
    end
  end

  context ".count" do
    context "with no expenses in the database" do
      it "should return 0" do
        Expense.count.should == 0
      end
    end
    context "with multiple expenses in the database" do
      before do
        Expense.new("Foo").save
        Expense.new("Bar").save
        Expense.new("Baz").save
        Expense.new("Grille").save
      end
      it "should return the correct count" do
        Expense.count.should == 4
      end
    end
  end

  context ".find_by_name" do
    context "with no expenses in the database" do
      it "should return 0" do
        Expense.find_by_name("Foo").should be_nil
      end
    end
    context "with expense by that name in the database" do
      let(:foo){ Expense.create("Foo") }
      before do
        foo
        Expense.new("Bar").save
        Expense.new("Baz").save
        Expense.new("Grille").save
      end
      it "should return the expense with that name" do
        Expense.find_by_name("Foo").id.should == foo.id
      end
      it "should return the expense with that name" do
        Expense.find_by_name("Foo").name.should == foo.name
      end
    end
  end

  context ".last" do
    context "with no expenses in the database" do
      it "should return nil" do
        Expense.last.should be_nil
      end
    end
    context "with multiple expenses in the database" do
      before do
        Expense.new("Foo").save
        Expense.new("Bar").save
        Expense.new("Baz").save
        Expense.new("Grille").save
      end
      it "should return the last one inserted" do
        Expense.last.name.should == "Grille"
      end
    end
  end

  context "#new" do
    let(:expense){ Expense.new("Bob") }
    it "should store the name" do
      expense.name.should == "Bob"
    end
  end

  context "#save" do
    let(:result){ Environment.database_connection.execute("Select * from expenses") }
    let(:expense){ Expense.new("foo") }
    context "with a valid expense" do
      before do
        expense.stub(:valid?){ true }
      end
      it "should only save one row to the database" do
        expense.save
        result.count.should == 1
      end
      it "should actually save it to the database" do
        expense.save
        result[0]["name"].should == "foo"
      end
      it "should record the new id" do
        expense.save
        expense.id.should == result[0]["id"]
      end
    end
    context "with an invalid expense" do
      before do
        expense.stub(:valid?){ false }
      end
      it "should not save a new expense" do
        expense.save
        result.count.should == 0
      end
    end
  end

  context "#valid?" do
    let(:result){ Environment.database_connection.execute("Select name from expenses") }
    context "after fixing the errors" do
      let(:expense){ Expense.new("123") }
      it "should return true" do
        expense.valid?.should be_false
        expense.name = "Bob"
        expense.valid?.should be_true
      end
    end
    context "with a unique name" do
      let(:expense){ Expense.new("Joe") }
      it "should return true" do
        expense.valid?.should be_true
      end
    end
    context "with a invalid name" do
      let(:expense){ Expense.new("420") }
      it "should return false" do
        expense.valid?.should be_false
      end
      it "should save the error messages" do
        expense.valid?
        expense.errors.first.should == "'420' is not a valid expense name, as it does not include any letters."
      end
    end
    context "with a duplicate name" do
      let(:name){ "Susan" }
      let(:expense){ Expense.new(name) }
      before do
        Expense.new(name).save
      end
      it "should return false" do
        expense.valid?.should be_false
      end
      it "should save the error messages" do
        expense.valid?
        expense.errors.first.should == "#{name} already exists."
      end
    end
  end
end


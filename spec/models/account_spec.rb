require_relative '../spec_helper'

describe Account do
  context ".all" do
    context "with no accounts in the database" do
      it "should return an empty array" do
        Account.all.should == []
      end
    end
    context "with multiple accounts in the database" do
      let!(:foo){ Account.create("Foo", 25) }
      let!(:bar){ Account.create("Bar", 30) }
      let!(:baz){ Account.create("Baz", 20) }
      let!(:grille){ Account.create("Grille", 40) }
      it "should return all of the accounts" do
        account_attrs = Account.all.map{ |account| [account.name,account.income,account.id] }
        account_attrs.should == [["Foo", 25, foo.id],
                                ["Bar", 30, bar.id],
                                ["Baz", 20, baz.id],
                                ["Grille", 40, grille.id]]
      end
    end
  end

  context ".count" do
    context "with no accounts in the database" do
      it "should return 0" do
        Account.count.should == 0
      end
    end
    context "with multiple accounts in the database" do
      before do
        Account.new("Foo", 25).save
        Account.new("Bar", 30).save
        Account.new("Baz", 20).save
        Account.new("Grille", 40).save
      end
      it "should return the correct count" do
        Account.count.should == 4
      end
    end
  end

  context ".find_by_name" do
    context "with no accounts in the database" do
      it "should return 0" do
        Account.find_by_name("Foo").should be_nil
      end
    end
    context "with account by that name in the database" do
      let(:foo){ Account.create("Foo", 25) }
      before do
        foo
        Account.new("Bar", 30).save
        Account.new("Baz", 20).save
        Account.new("Grille", 40).save
      end
      it "should return the account with that name" do
        Account.find_by_name("Foo").id.should == foo.id
      end
      it "should return the account with that name" do
        Account.find_by_name("Foo").name.should == foo.name
      end
      it "should return the account with that income" do
        Account.find_by_name("Foo").income.should == foo.income
      end
    end
  end

  context ".last" do
    context "with no accounts in the database" do
      it "should return nil" do
        Account.last.should be_nil
      end
    end
    context "with multiple accounts in the database" do
      before do
        Account.new("Foo", 25).save
        Account.new("Bar", 30).save
        Account.new("Baz", 20).save
        Account.new("Grille", 40).save
      end
      it "should return the last one inserted" do
        Account.last.name.should == "Grille"
      end
    end
  end

  context "#new" do
    let(:account){ Account.new("Bob", 15) }
    it "should store the name" do
      account.name.should == "Bob"
    end
    it "should store the income" do
      account.income.should == 15
    end
  end

  context "#save" do
    let(:result){ Environment.database_connection.execute("Select * from accounts") }
    let(:account){ Account.new("foo", 25) }
    context "with a valid account" do
      before do
        account.stub(:valid?){ true }
      end
      it "should only save one row to the database" do
        account.save
        result.count.should == 1
      end
      it "should actually save it to the database" do
        account.save
        result[0]["name"].should == "foo"
      end
      it "should record the new id" do
        account.save
        account.id.should == result[0]["id"]
      end
      it "should record the new income" do
        account.save
        account.income.should == result[0]["income"]
      end
    end
    context "with an invalid account" do
      before do
        account.stub(:valid?){ false }
      end
      it "should not save a new account" do
        account.save
        result.count.should == 0
      end
    end
  end

  context "#valid?" do
    let(:result){ Environment.database_connection.execute("Select name from accounts") }
    context "after fixing the errors" do
      let(:account){ Account.new("123", 55) }
      it "should return true" do
        account.valid?.should be_false
        account.name = "Bob"
        account.income = 55
        account.valid?.should be_true
      end
    end
    context "with a unique name" do
      let(:account){ Account.new("Joe", 35) }
      it "should return true" do
        account.valid?.should be_true
      end
    end
    context "with a invalid name" do
      let(:account){ Account.new("420", 18) }
      it "should return false" do
        account.valid?.should be_false
      end
      it "should save the error messages" do
        account.valid?
        account.errors.first.should == "'420' is not a valid account name, as it does not include any letters."
      end
    end
    context "with a duplicate name" do
      let(:name){ "Susan" }
      let(:account){ Account.new(name, 38) }
      before do
        Account.new(name, 38).save
      end
      it "should return false" do
        account.valid?.should be_false
      end
      it "should save the error messages" do
        account.valid?
        account.errors.first.should == "#{name} already exists."
      end
    end
  end
end


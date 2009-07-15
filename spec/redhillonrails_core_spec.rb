require File.dirname(__FILE__) + '/spec_helper'

describe "model" do
  
  it "should respond to foreign_keys" do
    Parent.should respond_to(:foreign_keys)
  end
  
  it "should respond to indexes" do
    Parent.should respond_to(:indexes)
  end
  
end

describe "migration" do
  
  #next 5 tests are inter dependant so be careful when modyfying
  it "should create table with foreign key" do
    create_child_table :name => :parent_id_foreign_key
    foreign_key_verification
  end
  
  it "should drop foreign key with remove_foreign_key" do
    lambda {
      ActiveRecord::Migration.remove_foreign_key :children, :parent_id_foreign_key
    }.should_not raise_error
  end
  
  it "should add foreign key with add_foreign_key" do
    lambda {
      ActiveRecord::Migration.add_foreign_key :children, :parent_id, :parents, :id, :name => :parent_id_foreign_key
    }.should_not raise_error
    foreign_key_verification
  end
  
  it "should remove table without errors" do
    drop_child_table
  end
  #end of interdependant test
  
  describe "with foreign_key and options" do
    
    it ":on_delete => :cascade" do
      create_child_table :on_delete => :cascade
      
      parent = Parent.create
      
      child = Child.create :parent_id => parent.id
      
      Parent.delete(parent.id)
      lambda {Child.find(child.id)}.should raise_error(ActiveRecord::RecordNotFound)
      
      drop_child_table
    end
    
    it ":on_delete => :restrict" do
      create_child_table :on_delete => :restrict
      
      parent = Parent.create
      
      child = Child.create :parent_id => parent.id
      
      lambda {parent.delete}.should raise_error(ActiveRecord::StatementInvalid)
      
      drop_child_table
    end
    
    it ":on_delete => :set_null" do
      create_child_table :on_delete => :set_null

      parent = Parent.create
      
      child = Child.create :parent_id => parent.id
      
      parent.delete
      child.reload
      child.parent_id.should == nil
      
      drop_child_table
    end
    
    it ":on_update => :cascade" do
      create_child_table :on_update => :cascade
      # cannot change AR object id with rails
      drop_child_table
    end
    
    it ":on_update => :restrict" do
      create_child_table :on_update => :restrict
      # cannot change AR object id with rails
      drop_child_table
    end
    
    it ":on_update => :set_null" do
      create_child_table :on_update => :set_null
      # cannot change AR object id with rails
      drop_child_table
    end
    
  end
  
  def create_child_table(options = nil)
    lambda {
      ActiveRecord::Migration.create_table :children, :force => true do |t|
        # fix for tests when run with foreign_key_migration installed
        if defined?(RedHillConsulting::ForeignKeyMigrations)
          t.column_without_foreign_key_migrations :parent_id, :integer
        else
          t.integer :parent_id
        end
        t.foreign_key(:parent_id, :parents, :id, options)
      end
    }.should_not raise_error
  end
  
  def drop_child_table
    lambda {
      ActiveRecord::Migration.drop_table :children
    }.should_not raise_error
  end
  
  def foreign_key_verification
    expected_key = Child.foreign_keys.first
    expected_key[:name] .should == "parent_id_foreign_key"
    expected_key[:column_names].should == ["parent_id"]
    expected_key[:references_column_names].should == ["id"]
    expected_key[:table_name].should == "children"
    expected_key[:references_table_name].should == "parents"
    
    #check if database sopports foreign keys
    child = Child.new
    lambda {child.save!}.should_not raise_error(ActiveRecord::StatementInvalid)
    child = Child.new :parent_id => 5
    lambda {child.save!}.should raise_error(ActiveRecord::StatementInvalid)
  end
end
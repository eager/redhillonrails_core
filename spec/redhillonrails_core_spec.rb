require File.dirname(__FILE__) + '/spec_helper'

describe "model" do
  
  it "should respond to foreign_keys" do
    Parent.should respond_to(:foreign_keys)
  end
  
  it "should respond to indexes" do
    Parent.should respond_to(:indexes)
  end
  
  describe "with foreign_key" do
    
    it "should create table with foreign key" do
      lambda { 
        ActiveRecord::Migration.create_table :children, :force => true do |t|
          t.integer :parent_id
          t.foreign_key :parent_id, :parents, :id, :name => :parent_id_foreign_key
        end
      }.should_not raise_error
      
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
      lambda {
        ActiveRecord::Migration.drop_table :children
      }.should_not raise_error   
    end

  end
  
  describe "with foreign_key and options" do
    # clear all parents entries
    before(:each) do
      Parent.delete(:all)
    end
    
    it ":on_delete => :cascade" do
      lambda {
        create_child_table :on_delete => :cascade
      }.should_not raise_error 
      
      parent = Parent.create
      
      child = Child.create :parent_id => parent.id
      
      Parent.delete(parent.id)
      lambda {Child.find(child.id)}.should raise_error(ActiveRecord::RecordNotFound)
      
      lambda {drop_child_table}.should_not raise_error
    end
    
    it ":on_delete => :restrict" do
      lambda {
        create_child_table :on_delete => :restrict
      }.should_not raise_error
      
      parent = Parent.create
      
      child = Child.create :parent_id => parent.id
      
      lambda {parent.delete}.should raise_error(ActiveRecord::StatementInvalid)
      
      lambda {drop_child_table}.should_not raise_error
    end
    
    it ":on_delete => :set_null" do
      lambda {
        create_child_table :on_delete => :set_null
      }.should_not raise_error

      parent = Parent.create
      
      child = Child.create :parent_id => parent.id
      
      parent.delete
      child.reload
      child.parent_id.should == nil
      
      lambda {drop_child_table}.should_not raise_error
    end
    
    it ":on_update => :cascade" do
      lambda {
        create_child_table :on_update => :cascade
      }.should_not raise_error
      
      # cannot change AR object id with rails
      
      lambda {drop_child_table}.should_not raise_error
    end
    
    it ":on_update => :restrict" do
      lambda {
        create_child_table :on_update => :restrict
      }.should_not raise_error
      
       # cannot change AR object id with rails
      
      lambda {drop_child_table}.should_not raise_error
    end
    
    it ":on_update => :set_null" do
      lambda {
        create_child_table :on_update => :set_null
      }.should_not raise_error
      
      # cannot change AR object id with rails
      
      lambda {drop_child_table}.should_not raise_error
    end
    
    def create_child_table(options = nil)
      ActiveRecord::Migration.create_table :children, :force => true do |t|
        t.integer :parent_id
        t.foreign_key(:parent_id, :parents, :id, options)
      end
    end
    
    def drop_child_table
      ActiveRecord::Migration.drop_table :children
    end
  end
  
  def foreign_key_verification
    Child.foreign_keys.first[:name] .should == "parent_id_foreign_key"
    Child.foreign_keys.first[:column_names].should == ["parent_id"]
    Child.foreign_keys.first[:references_column_names].should == ["id"]
    Child.foreign_keys.first[:table_name].should == "children"
    Child.foreign_keys.first[:references_table_name].should == "parents"
    
    #check if database sopports foreign keys
    child = Child.new
    lambda {child.save!}.should_not raise_error(ActiveRecord::StatementInvalid)
    child = Child.new :parent_id => 5
    lambda {child.save!}.should raise_error(ActiveRecord::StatementInvalid)
  end
end
begin
  require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
rescue LoadError
  puts "You need to install rspec in your base app"
  exit
end

require File.dirname(__FILE__) + '/models/parent'
require File.dirname(__FILE__) + '/models/child'


plugin_spec_dir = File.dirname(__FILE__)

def clear_db_after_test
  if ActiveRecord::Base.connection.table_exists? :children
    ActiveRecord::Migration.drop_table :children
  end
  
  if ActiveRecord::Base.connection.table_exists? :parents
    ActiveRecord::Migration.drop_table :parents
  end
end

def prepare_db_for_test
  clear_db_after_test
  ActiveRecord::Migration.create_table :parents, {:force => true}
end

ActiveRecord::Migration.verbose = false

Spec::Runner.configure do |config|
  
  p ActiveRecord::Base.connection.methods.sort
  
  config.use_transactional_fixtures = false
    
  config.before :each do
    full_example_description = "Starting #{self.class.description} #{@method_name}"  
    ActiveRecord::Base.logger.info("\n\n#{full_example_description}\n#{'-' * (full_example_description.length)}")
  end  
    
  config.before :all do
    prepare_db_for_test
  end

  config.after :all do
    clear_db_after_test
  end
end
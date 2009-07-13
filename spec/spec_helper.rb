begin
  require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
rescue LoadError
  puts "You need to install rspec in your base app"
  exit
end

require File.dirname(__FILE__) + '/models/one'
require File.dirname(__FILE__) + '/models/three'


plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")

databases = YAML::load(IO.read(plugin_spec_dir + "/db/database.yml"))
ActiveRecord::Base.establish_connection(databases["test"])

ActiveRecord::Migration.verbose = false


Spec::Runner.configure do |config|
  config.use_transactional_fixtures = false
    
  config.before :all do
    ActiveRecord::Migration.create_table :parents, {:force => true}
  end

  config.after :all do
    begin
      ActiveRecord::Migration.drop_table :children
      ActiveRecord::Migration.drop_table :parents
    rescue ActiveRecord::StatementInvalid => err
    end
  end
end
require 'rake'
require 'spec/rake/spectask'

desc 'Run the specs'
namespace :spec do
  namespace :plugins do
    Spec::Rake::SpecTask.new(:redhillonrails_core) do |t|
      t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
      t.spec_files = FileList['spec/**/*_spec.rb']
    end
  end
end


begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "redhillonrails_core"
    gemspec.summary = "A gem version of redhillonrails_core"
    gemspec.description = "RedHill on Rails Core is a plugin that features to support other RedHill on Rails plugins. Those features include:
        * Creating and dropping views;
        * Creating and removing foreign-keys;
        * Obtaining indexes directly from a model class; and
        * Determining when Schema.define() is running.
    "
    gemspec.email = "christian@perpenduum.com"
    gemspec.homepage = "http://github.com/frolic/redhillonrails_core"
    gemspec.authors = ["RedHill Consulting, Pty. Ltd.", "Christian Eager"]
    gemspec.add_dependency('rspec')
    gemspec.add_dependency('activerecord')
    # gemspec.files.exclude 
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

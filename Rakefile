begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "vibes-rspec-rails23"
    s.summary = "Rspec Rails for 2.3"
    s.email = ["matt.campbell@vibes.com", "lance.cooper@vibes.com"]
    s.homepage = "http://github.com/vibes/rspec-rails23"
    s.description = "Rails 2.3 Extension for Rspec 2"
    s.authors = ["Matt Campbell", "Lance Cooper"]
    s.files =  FileList["[A-Z]*", "{bin,lib,spec}/**/*"]
    s.add_dependency "actionpack", '~> 2.3.5'
    s.add_dependency "rspec", '~> 2.13.0'
    s.add_development_dependency "sdoc"
    s.add_development_dependency "sdoc-helpers"
    s.add_development_dependency "rdiscount"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'

desc "Run all specs"
RSpec::Core::RakeTask.new :spec do |t|
  t.pattern = "spec/**/*_spec.rb"
end

namespace :spec do
  desc "Run all specs using rcov"
  RSpec::Core::RakeTask.new :coverage do |t|
    t.pattern = "spec/**/*_spec.rb"
    t.rcov = true
    t.rcov_opts = %[--exclude "spec/*,gems/*,db/*,/Library/Ruby/*,config/*" --text-summary  --sort coverage]
  end
end

task :default => [:spec]

begin
  require 'sdoc_helpers'
rescue LoadError => ex
  puts "sdoc support not enabled:"
  puts ex.inspect
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Rspec-Rails #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  load 'tasks/setup.rb'
end

ensure_in_path 'lib'
require 'case_check'

task :default => 'spec:run'
task :install => 'gem:install'

PROJ.name = 'cf_case_check'
PROJ.authors = 'Rhett Sutphin'
PROJ.email = 'r-sutphin@northwestern.edu'
# PROJ.url = 'FIXME (project homepage)'
PROJ.version = CaseCheck::VERSION
# PROJ.rubyforge.name = 'cf_case_check'

PROJ.ruby_opts = [] # There are a bunch of warnings in rspec, so setting -w isn't useful
PROJ.spec.opts << '--color'


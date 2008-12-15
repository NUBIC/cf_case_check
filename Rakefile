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
PROJ.email = 'rhett@detailedbalance.net'
PROJ.url = 'http://github.com/rsutphin/cf_case_check'
PROJ.version = CaseCheck::VERSION
# PROJ.rubyforge.name = 'cf_case_check'
PROJ.description = "A utility which walks a ColdFusion application's source and determines which includes, custom tags, etc, will not work with a case-sensitive filesystem"

PROJ.ruby_opts = [] # There are a bunch of warnings in rspec, so setting -w isn't useful
PROJ.spec.opts << '--color'
PROJ.rcov.opts << '--exclude /Library'

PROJ.gem.dependencies << 'activesupport'

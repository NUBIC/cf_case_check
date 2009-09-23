# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cf_case_check}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Rhett Sutphin"]
  s.date = %q{2009-09-23}
  s.default_executable = %q{cf_case_check}
  s.description = %q{A utility which walks a ColdFusion application's source and determines which includes, custom tags, etc, will not work with a case-sensitive filesystem}
  s.email = %q{rhett@detailedbalance.net}
  s.executables = ["cf_case_check"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "bin/cf_case_check"]
  s.files = ["History.txt", "Manifest.txt", "Rakefile", "bin/cf_case_check", "lib/case_check.rb", "lib/case_check/coldfusion_source.rb", "lib/case_check/commands.rb", "lib/case_check/configuration.rb", "lib/case_check/core-ext.rb", "lib/case_check/reference.rb", "lib/case_check/references/cfc.rb", "lib/case_check/references/cfinclude.rb", "lib/case_check/references/cfmodule.rb", "lib/case_check/references/custom_tag.rb", "spec/coldfusion_source_spec.rb", "spec/commands_spec.rb", "spec/configuration_spec.rb", "spec/core_ext_spec.rb", "spec/reference_spec.rb", "spec/references/cfc_spec.rb", "spec/references/cfinclude_spec.rb", "spec/references/cfmodule_spec.rb", "spec/references/custom_tag_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/rsutphin/cf_case_check}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A utility which walks a ColdFusion application's source and determines which includes, custom tags, etc, will not work with a case-sensitive filesystem}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_development_dependency(%q<bones>, [">= 2.5.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<bones>, [">= 2.5.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<bones>, [">= 2.5.0"])
  end
end

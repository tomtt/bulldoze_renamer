require_relative 'lib/bulldoze_renamer/version'

Gem::Specification.new do |spec|
  spec.name          = "bulldoze_renamer"
  spec.version       = BulldozeRenamer::VERSION
  spec.authors       = ["Tom ten Thij"]
  spec.email         = ["code@tomtenthij.nl"]

  spec.summary       = %q{A command line tool to bulk rename classes and variables in ruby projects}
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency('activesupport', '>= 6')
  spec.add_dependency('ruby-filemagic', '~> 0.7.2')
end

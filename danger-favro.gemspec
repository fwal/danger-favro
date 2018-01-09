
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "favro/gem_version.rb"

Gem::Specification.new do |spec|
  spec.name          = "danger-favro"
  spec.version       = Favro::VERSION
  spec.authors       = ["Frederik Wallner"]
  spec.email         = ["frederik.wallner@gmail.com"]
  spec.description   = "Detect Favro cards in PRs"
  spec.summary       = "A Danger plugin that detect Favro cards referenced in code or PR title and displays basic information about them."
  spec.homepage      = "https://github.com/fwal/danger-favro"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "danger-plugin-api", "~> 1.0"
  spec.add_runtime_dependency "json", "~> 2.1.0"
  spec.add_runtime_dependency "rest-client", "~> 2.0"

  # General ruby development
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 12.3.0"

  # Testing support
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "webmock", "~>3.2.1"

  # Linting code and docs
  spec.add_development_dependency "coveralls", "~> 0.8.21"
  spec.add_development_dependency "rubocop", "~> 0.52.1"
  spec.add_development_dependency "yard", "~> 0.9.12"

  # Makes testing easy via `bundle exec guard`
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"

  # If you want to work on older builds of ruby
  spec.add_development_dependency "listen", "~> 3.1.5"

  # This gives you the chance to run a REPL inside your tests
  # via:
  #
  #    require 'pry'
  #    binding.pry
  #
  # This will stop test execution and let you inspect the results
  spec.add_development_dependency "pry"
end

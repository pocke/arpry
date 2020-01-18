
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "arpry/version"

Gem::Specification.new do |spec|
  spec.name          = "arpry"
  spec.version       = Arpry::VERSION
  spec.authors       = ["Masataka Pocke Kuwabara"]
  spec.email         = ["kuwabara@pocke.me"]

  spec.summary       = %q{Explore database without Rails}
  spec.description   = %q{Explore database without Rails}
  spec.homepage      = "https://github.com/pocke/arpry"
  spec.license       = 'Apache-2.0'

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
    # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.required_ruby_version = '>= 2.4'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activerecord', '< 6', '>= 5'
  spec.add_runtime_dependency 'pry', '>= 0.12.0'

  spec.add_development_dependency "bundler", ">= 1", "< 3"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "minitest", ">= 5", '< 6'
  spec.add_development_dependency "sqlite3"
end

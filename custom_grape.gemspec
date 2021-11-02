require_relative 'lib/custom_grape/version'

Gem::Specification.new do |spec|
  spec.name          = "custom_grape"
  spec.version       = CustomGrape::VERSION
  spec.authors       = ["MC"]
  spec.email         = ["mc@beansmile.com"]

  spec.summary       = "定制grape"
  spec.description   = "定制grape"
  spec.homepage      = "https://github.com/beansmile/custom_grape"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/beansmile/wechat_third_party_platform"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 6.0.3.4"
  spec.add_dependency "grape", "~> 1.6.0"
  spec.add_dependency "grape-entity", "~> 0.10.1"
  spec.add_dependency "grape-kaminari", "~> 0.4.1"
end

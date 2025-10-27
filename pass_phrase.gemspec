# frozen_string_literal: true

require_relative 'lib/pass_phrase/version'

Gem::Specification.new do |spec|
  spec.name          = "pass_phrase"
  spec.version       = PassPhrase::VERSION
  spec.authors       = ["Matt Whiteley"]
  spec.summary       = "A Ruby port of aaronbassett's Pass-phrase generator."
  spec.description   = "Generates a pass-phrase based on adjective-noun-verb-adjective-noun."
  spec.homepage      = "https://github.com/matt-whiteley/pass-phrase"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files to include in the gem
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  # This line tells rubygems that 'bin/pass_phrase' is an executable
  spec.executables   = ["pass_phrase"]
  spec.bindir        = "bin"

  # Add any runtime dependencies here (this one has none)
  # spec.add_runtime_dependency "some-gem", "~> 1.0"
end
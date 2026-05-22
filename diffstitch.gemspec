# frozen_string_literal: true

require_relative 'lib/diffstitch/version'

Gem::Specification.new do |spec|
  spec.name          = 'diffstitch'
  spec.version       = Diffstitch::VERSION
  spec.authors       = ['Steven Roomberg']
  spec.email         = ['stevenroomberg@gmail.com']

  spec.summary       = 'Compare multiple git branches against a base in a split HTML view'
  spec.description   = 'A CLI tool that generates a side-by-side HTML report comparing ' \
                       'multiple git branches against a common base branch.'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.homepage      = 'https://github.com/sroomberg/diffstitch'
  spec.metadata      = {
    'homepage_uri'    => spec.homepage,
    'source_code_uri' => spec.homepage,
    'changelog_uri'   => "#{spec.homepage}/blob/main/CHANGELOG.md"
  }

  spec.files         = Dir['lib/**/*', 'bin/*', '*.gemspec', 'Gemfile', 'CHANGELOG.md', 'LICENSE']
  spec.bindir        = 'bin'
  spec.executables   = ['diffstitch']
  spec.require_paths = ['lib']

  spec.add_dependency 'launchy', '~> 3.1'

  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.0'
end

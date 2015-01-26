# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'asciidoctor/confluence/version'

Gem::Specification.new do |spec|
  spec.name          = "asciidoctor-confluence"
  spec.version       = Asciidoctor::Confluence::VERSION
  spec.authors       = ["Guillaume Scheibel"]
  spec.email         = ["guillaume.scheibel@gmail.com"]
  spec.summary       = "Publishing Asciidoctor content as Confluence page"
  spec.description   = "Asciidoctor-Confluence allows to parse asciidoc files, transform them into HTML and then push them into a Confluence"
  spec.homepage      = "http://asciidoctor.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ['asciidoctor-confluence'] #spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake',  '~> 10.4', '>= 10.4.2'
  spec.add_development_dependency 'test-unit',  '~> 3.0', '>= 3.0.9'
  spec.add_development_dependency 'rspec', '~> 3.1.0', '>= 3.1'
  spec.add_development_dependency 'rspec-mocks', '~> 3.1.3', '>= 3.1'
  spec.add_development_dependency 'webmock', '~> 1.20.4', '>= 1.20'

  spec.add_runtime_dependency 'asciidoctor', '~> 1.5.2', '>= 1.5'
  spec.add_runtime_dependency 'faraday', '~> 0.9.1', '>= 0.9'
  spec.add_runtime_dependency 'json', '~> 1.8.2', '>= 1.8.2'
end

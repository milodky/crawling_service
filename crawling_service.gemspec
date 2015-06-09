# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crawling_service/version'

Gem::Specification.new do |spec|
  spec.name          = 'crawling_service'
  spec.version       = CrawlingService::VERSION
  spec.authors       = ['Xiaoting']
  spec.email         = ['yext4011@gmail.com']
  spec.summary       = %q{Required.}
  spec.description   = %q{Optional.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'


  spec.add_dependency 'mechanize'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'bunny'

end

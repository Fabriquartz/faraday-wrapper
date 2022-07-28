# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'faraday-wrapper'
  s.required_ruby_version = '>= 2.6'
  s.version     = '1.2.5'
  s.date        = '2019-07-19'
  s.summary     = 'FaradayWrapper'
  s.description = 'FaradayWrapper is a wrapper around the faraday gem for Fabriquartz Micro-Services'
  s.authors     = ['Cédric Remond']
  s.email       = 'cedric.remond@fabriquartz.com'
  s.files       = ['lib/faraday_wrapper.rb']
  s.homepage    =
    'https://github.com/Fabriquartz/faraday-wrapper'
  s.license = 'MIT'
  s.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/Fabriquartz"

  s.add_runtime_dependency 'faraday', '~> 2.3'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.7'
end

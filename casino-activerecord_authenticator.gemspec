# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'casino/sql_authlogic_authenticator/version'

Gem::Specification.new do |s|
  s.name        = 'casino-activerecord_authlogic_authenticator'
  s.version     = CASino::SQLAuthLogicAuthenticator::VERSION
  s.authors     = ['Marcin Ożóg']
  s.email       = ['marcin@itgo.pl']
  s.homepage    = 'https://github.com/ypcatify/casino-sql_authlogic_authenticator'
  s.license     = 'MIT'
  s.summary     = 'Provides mechanism to use ActiveRecord with AuthLogic as an authenticator for CASino.'
  s.description = 'This gem can be used to allow the CASino backend to authenticate against an SQL server using ActiveRecord with AuthLogic.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 2.12'
  s.add_development_dependency 'simplecov', '~> 0.7'
  s.add_development_dependency 'sqlite3', '~> 1.3.7'
  s.add_development_dependency 'coveralls'

  s.add_runtime_dependency 'activerecord', '>= 4.1.0', '< 4.3.0'
  s.add_runtime_dependency 'authlogic', '~> 3.4.5'
  s.add_runtime_dependency 'casino', '>= 3.0.0', '< 5.0.0'
end

# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'evt-entity_projection'
  s.version = '2.0.1.4'
  s.summary = 'Projects event data into an entity'
  s.description = ' '

  s.authors = ['The Eventide Project']
  s.email = 'opensource@eventide-project.org'
  s.homepage = 'https://github.com/eventide-project/entity-projection'
  s.licenses = ['MIT']

  s.require_paths = ['lib']
  s.files = Dir.glob('{lib}/**/*')
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.3.3'

  s.add_runtime_dependency 'evt-messaging'

  s.add_development_dependency 'test_bench'
  s.add_development_dependency 'evt-message_store-postgres'
end

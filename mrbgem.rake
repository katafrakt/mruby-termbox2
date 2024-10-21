MRuby::Gem::Specification.new('mruby-termbox2') do |spec|
  spec.license = 'MIT'
  spec.author  = 'Paweł Świątkowski'
  spec.summary = 'Low-level bindings to Termbox2'

  spec.cc.flags << ['-Wno-implicit-function-declaration']
  spec.add_dependency('mruby-data')
end
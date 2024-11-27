Gem::Specification.new do |s|
  s.name        = "archi_dsl"
  s.version     = "0.1.0"
  s.summary     = "Generate archimate XML models from a DSL"
  s.description = "Generate archimate XML models from a DSL - compatible with archie."
  s.homepage    = 'https://github.com/TreyE/archi_dsl'
  s.authors     = ["Trey Evans"]
  s.email       = "lewis.r.evans@gmail.com"
  s.files       = Dir['lib/**/*.rb']
  s.license       = "MIT"

  s.add_dependency "nokogiri"
  s.add_dependency "ruby-graphviz"
end

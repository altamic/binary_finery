Gem::Specification.new do |s|
  s.name    = %q{binary_finery}
  s.version = "0.0.1"
  s.date    = %q{2011-10-07}
  s.summary = %q{A fluent interface for reading or writing binary data}
  s.description = %q{BinaryFinery mixes in a fluent interface to any
                     IO entity for reading or writing binary data.}
  s.authors = ["Michelangelo Altamore"]
  s.email   = %q{michelangelo@altamore.org}
  s.files = ["README", "README.md", "LICENSE", "Rakefile", "lib/binary_finery.rb", 
             "test/helper.rb", "test/test_binary_finery.rb"]
  s.homepage = %q{https://github.com/altamic/binary_finary}
  s.add_development_dependency("minitest", [">= 2.1.0"])
end

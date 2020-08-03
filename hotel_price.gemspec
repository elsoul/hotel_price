lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hotel_price/version"

Gem::Specification.new do |spec|
  spec.name          = "hotel_price"
  spec.version       = HotelPrice::VERSION
  spec.authors       = ["Fumitake Kawasaki", "James Neve"]
  spec.email         = ["fumitake.kawasaki@el-soul.com", "jamesoneve@gmail.com"]

  spec.summary       = "Scraping Library to get world hotel price"
  spec.description   = "Empower World Travel Information Technology "
  spec.homepage      = "https://github.com/elsoul/hotel_price"
  spec.license       = "MIT"
  spec.metadata = { "source_code_uri" => "https://github.com/elsoul/hotel_price" }
  spec.required_ruby_version = ">= 2.7.0"
  # spec.metadata["allowed_push_host"] = "https://hotel.el-soul.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/elsoul/hotel_price"
  spec.metadata["changelog_uri"] = "https://github.com/elsoul/hotel_price"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.9.0"
  spec.add_runtime_dependency "activesupport", "~> 6.0.2.2"
  spec.add_runtime_dependency "json", "~> 2.3.1"
  spec.add_runtime_dependency "nokogiri", "~> 1.10.9"
  spec.add_runtime_dependency "selenium-webdriver", "~> 3.141"
end

# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pdf_form_filler/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Chris Mear"]
  gem.email         = 'chris@feedmechocolate.com'
  gem.description   = "pdf_form_filler fills in a PDF form using fields defined by co-ordinates in a YAML file."
  gem.summary       = "pdf_form_filler fills in a PDF form using fields defined by co-ordinates in a YAML file."
  gem.homepage      = 'https://github.com/chrismear/pdf_form_filler'

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'pdf_form_filler'
  gem.require_paths = ["lib"]
  gem.version       = PdfFormFiller::VERSION

  gem.add_dependency 'prawn', '~>0.12.0'

  gem.add_development_dependency 'rake', '~>0.9.2'
end

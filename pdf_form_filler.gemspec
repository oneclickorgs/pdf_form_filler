# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pdf_form_filler/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Chris Mear"]
  gem.email         = 'chris@feedmechocolate.com'
  gem.description   = "pdf_form_filler is a very simple tool for filling in PDF forms"
  gem.summary       = "pdf_form_filler fills in a PDF form using fields defined by co-ordinates in a YAML file."
  gem.homepage      = 'https://github.com/chrismear/pdf_form_filler'

  gem.files         = `git ls-files`.split($\)
  gem.bindir        = 'bin'
  gem.executables   = ['pdf_form_filler', 'pdf_form_filler_highlight']
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'pdf_form_filler'
  gem.require_paths = ["lib"]
  gem.version       = PdfFormFiller::VERSION

  gem.add_dependency 'prawn', '~>0.12.0'

  gem.add_development_dependency 'rake', '~>10.1.1'
  gem.add_development_dependency 'rspec', '~>2.11.0'
end

require File.expand_path('../lib/pdf_form_filler', File.dirname(__FILE__))

require 'tempfile'
require 'yaml'
require 'digest/md5'

describe PdfFormFiller do

  it "generates a PDF" do
    output_file = Tempfile.new('output')

    fixtures_path = File.expand_path('fixtures', File.dirname(__FILE__))

    template_path = File.join(fixtures_path, 'ms_application_form.pdf')
    definition_path = File.join(fixtures_path, 'ms_application_form.yml')
    data = YAML.load_file(File.join(fixtures_path, 'ms_application_form_data.yml'))

    expect {
      document = PdfFormFiller::Form.new(:template => template_path, :definition => definition_path)
      document.fill_form(data)
      document.render_file(output_file.path)
    }.to_not raise_error

    expected_hash = Digest::MD5.file(File.join(fixtures_path, 'ms_application_form_output.pdf')).hexdigest
    actual_hash = Digest::MD5.file(output_file).hexdigest

    actual_hash.should eq(expected_hash)

    output_file.close
    output_file.unlink
  end

end

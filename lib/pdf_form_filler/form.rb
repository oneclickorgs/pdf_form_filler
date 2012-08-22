require 'prawn'
require 'yaml'

class PdfFormFiller::Form
  def initialize(options={})
    @template = options[:template]

    @definition_file = options[:definition]
    @definition = YAML.load_file(@definition_file)

    @pdf = Prawn::Document.new(:template => @template)

    # x_offset, y_offset is the position of the Prawn origin, as expressed
    # in the co-ordinate system used for the rest of the measurements.
    #
    # In Prawn, x runs left to right, and y runs bottom to top. If either
    # of the axes in your co-ordinate system run opposite to this, set
    # invert_x and/or invert_y to true.
  end

  def fill_form(data)
    1.upto(@pdf.page_count) do |page_number|
      @pdf.go_to_page(page_number)
    end
  end

  def highlight_fields
    1.upto(@pdf.page_count) do |page_number|
      @pdf.go_to_page(page_number)

      if @definition[page_number] && @definition[page_number].respond_to?(:each)
        @definition[page_number].each do |name, box_definition|
          if box_definition.is_a?(Hash)
            box_coords = box_definition['box']
          else
            box_coords = box_definition
          end
          local_box_coords = convert_to_local(box_coords)

          @pdf.fill_color = "ff0000"
          @pdf.transparent(0.5) do
            @pdf.fill_rectangle([local_box_coords[0], local_box_coords[1]], local_box_coords[2], local_box_coords[3])
          end

          @pdf.fill_color = "000000"
          @pdf.text_box(name, :at => [local_box_coords[0], local_box_coords[1]], :width => local_box_coords[2], :height => local_box_coords[3])
        end
      end

    end
  end

  def render_file(output)
    @pdf.render_file(output)
  end

protected

  def convert_to_local(box_coords)
    x_offset = @definition['defaults']['x_offset'] || 0
    y_offset = @definition['defaults']['y_offset'] || 0

    x = if @definition['defaults']['invert_x']
      x_offset - box_coords[0]
    else
      box_coords[0] - x_offset
    end

    y = if @definition['defaults']['invert_y']
      y_offset - box_coords[1]
    else
      box_coords[1] - y_offset
    end

    [x, y, box_coords[2], box_coords[3]]
  end
end

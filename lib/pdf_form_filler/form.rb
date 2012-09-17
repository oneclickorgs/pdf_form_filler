require 'prawn'
require 'yaml'

class PdfFormFiller::Form
  def initialize(options={})
    @template = options[:template]

    @definition_file = options[:definition]
    @definition = YAML.load_file(@definition_file)

    # Work around Prawn bug where using a multi-page template
    # results in 'Error 14' when the generated PDF is opened in
    # Adobe Reader.
    #
    # See: https://github.com/prawnpdf/prawn/issues/364
    @pdf = Prawn::Document.new(:template => @template)
    page_count = @pdf.page_count
    @pdf = Prawn::Document.new(:skip_page_creation => true)
    1.upto(page_count) do |page_number|
      @pdf.start_new_page(:template => @template, :template_page => page_number)
    end

    @pdf.font(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'fonts', 'LiberationSans-Regular.ttf')))

    # x_offset, y_offset is the position of the Prawn origin, as expressed
    # in the co-ordinate system used for the rest of the measurements.
    #
    # In Prawn, x runs left to right, and y runs bottom to top. If either
    # of the axes in your co-ordinate system run opposite to this, set
    # invert_x and/or invert_y to true.

    if @definition['defaults']
      @font_size = @definition['defaults']['font_size'] || 12
      @horizontal_padding = @definition['defaults']['horizontal_padding'] || 5
      @vertical_padding = @definition['defaults']['vertical_padding'] || 1
      @text_align = (@definition['defaults']['text_align'] || :left).to_sym
      @vertical_align = (@definition['defaults']['vertical_align'] || :center).to_sym
    else
      @font_size = 12
      @horizontal_padding = 5
      @vertical_padding = 1
      @text_align = :left
      @vertical_align = :center
    end

  end

  def fill_form(data)
    1.upto(@pdf.page_count) do |page_number|
      @pdf.go_to_page(page_number)

      if @definition[page_number] && @definition[page_number].respond_to?(:each)
        @definition[page_number].each do |name, box_definition|
          if box_definition.is_a?(Hash)
            box_coords = box_definition['box']
            font_size = box_definition['font_size'] || @font_size
            check_box = box_definition['check_box']

            if check_box
              text_align = :center
              vertical_align = :center
              font_size = box_coords[3]
              horizontal_padding = 0
              vertical_padding = 0
            end

            if box_definition['text_align']
              text_align = box_definition['text_align'].to_sym
            end
            text_align ||= @text_align

            if box_definition['vertical_align']
              vertical_align = box_definition['vertical_align'].to_sym
            end
            vertical_align ||= @vertical_align

            if box_definition['font_size']
              font_size = box_definition['font_size']
            end
            font_size ||= @font_size

            if box_definition['horizontal_padding']
              horizontal_padding = box_definition['horizontal_padding']
            end
            horizontal_padding ||= @horizontal_padding

            if box_definition['vertical_padding']
              vertical_padding = box_definition['vertical_padding']
            end
            vertical_padding ||= @vertical_padding
          else
            box_coords = box_definition
            font_size = @font_size
            text_align = @text_align
            vertical_align = @vertical_align
            horizontal_padding = @horizontal_padding
            vertical_padding = @vertical_padding
          end
          local_box_coords = convert_to_local(box_coords)

          if check_box
            value = (data[name.to_s] || data[name.to_sym]) ? 'X ' : ''
          else
            value = (data[name.to_s] || data[name.to_sym] || '').to_s
          end

          @pdf.font_size(font_size)
          @pdf.fill_color = "000000"
          @pdf.text_box(value,
            :at => [local_box_coords[0] + (horizontal_padding / 2.0), local_box_coords[1] - (vertical_padding / 2.0)],
            :width => local_box_coords[2] - horizontal_padding,
            :height => local_box_coords[3] - vertical_padding,
            :align => text_align,
            :valign => vertical_align
          )
        end
      end

    end
  end

  def highlight_fields
    1.upto(@pdf.page_count) do |page_number|
      @pdf.go_to_page(page_number)

      if @definition[page_number] && @definition[page_number].respond_to?(:each)
        @definition[page_number].each do |name, box_definition|
          if box_definition.is_a?(Hash)
            box_coords = box_definition['box']
            font_size = box_definition['font_size'] || @font_size
            check_box = box_definition['check_box']

            if check_box
              text_align = :center
              vertical_align = :center
              font_size = box_coords[3] + 0.5
              horizontal_padding = 0
              vertical_padding = 0
            end

            if box_definition['text_align']
              text_align = box_definition['text_align'].to_sym
            end
            text_align ||= @text_align

            if box_definition['vertical_align']
              vertical_align = box_definition['vertical_align'].to_sym
            end
            vertical_align ||= @vertical_align

            if box_definition['font_size']
              font_size = box_definition['font_size']
            end
            font_size ||= @font_size

            if box_definition['horizontal_padding']
              horizontal_padding = box_definition['horizontal_padding']
            end
            horizontal_padding ||= @horizontal_padding

            if box_definition['vertical_padding']
              vertical_padding = box_definition['vertical_padding']
            end
            vertical_padding ||= @vertical_padding
          else
            box_coords = box_definition
            font_size = @font_size
            text_align = @text_align
            vertical_align = @vertical_align
            horizontal_padding = @horizontal_padding
            vertical_padding = @vertical_padding
          end
          local_box_coords = convert_to_local(box_coords)

          @pdf.fill_color = "ff0000"
          @pdf.transparent(0.5) do
            @pdf.fill_rectangle([local_box_coords[0], local_box_coords[1]], local_box_coords[2], local_box_coords[3])
          end

          @pdf.font_size(font_size)
          @pdf.fill_color = "000000"
          @pdf.text_box(name,
            :at => [local_box_coords[0] + (horizontal_padding / 2.0), local_box_coords[1] - (vertical_padding / 2.0)],
            :width => local_box_coords[2] - horizontal_padding,
            :height => local_box_coords[3] - vertical_padding,
            :align => text_align,
            :valign => vertical_align,
            :overflow => :shrink_to_fit
          )
        end
      end

    end
  end

  def render_file(output)
    @pdf.render_file(output)
  end

  def render
    @pdf.render
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

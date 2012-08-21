#!/usr/bin/env ruby

require 'prawn'

axes = false

def stroke_axis(pdf, options={})
  options = { :height => (pdf.cursor - 20).to_i,
              :width => pdf.bounds.width.to_i
            }.merge(options)

  pdf.dash(1, :space => 4)
  pdf.stroke_horizontal_line(-21, options[:width], :at => 0)
  pdf.stroke_vertical_line(-21, options[:height], :at => 0)
  pdf.undash

  pdf.fill_circle [0, 0], 1

  (100..options[:width]).step(100) do |point|
    pdf.fill_circle [point, 0], 1
    pdf.draw_text point, :at => [point-5, -10], :size => 7
  end

  (100..options[:height]).step(100) do |point|
    pdf.fill_circle [0, point], 1
    pdf.draw_text point, :at => [-17, point-2], :size => 7
  end
end

input_file = "ms_application_form.pdf"

pdf = Prawn::Document.new(:template => input_file)

pdf.go_to_page(1)
stroke_axis(pdf) if axes

pdf.text_box("OCO Digital IPS", :at => [45, 603])

pdf.go_to_page(2)
stroke_axis(pdf) if axes
pdf.go_to_page(3)
stroke_axis(pdf) if axes

pdf.text_box("x", :at => [136.5, 613])
pdf.text_box("x", :at => [403.5, 613])
pdf.go_to_page(4)
stroke_axis(pdf) if axes
pdf.go_to_page(5)
stroke_axis(pdf) if axes
pdf.go_to_page(6)
stroke_axis(pdf) if axes
pdf.go_to_page(7)
stroke_axis(pdf) if axes
pdf.go_to_page(8)
stroke_axis(pdf) if axes
pdf.go_to_page(9)
stroke_axis(pdf) if axes

pdf.render_file "output.pdf"

#!/usr/bin/env ruby
require 'json'
require_relative 'output_pdf.rb'
require 'open-uri'
require 'base64'

data = JSON.parse(ARGV[0])
form = data['form'];
applicant = data['applicant']

form['filled_path'] = "/tmp/#{form['name']}.pdf"

# pdftk can't read from uri, storing in tmp file
form['tmp_path'] = "/tmp/#{form['name']}_tmp.pdf"
File.open(form['tmp_path'], "wb") do |file|
  file.write open(form['path']).read
end

filled = OutputPDF.new(form, applicant).to_file

puts Base64.encode64(filled)

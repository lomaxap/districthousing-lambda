#!/usr/bin/env ruby
require 'json'
require_relative 'output_pdf.rb'
require 'open-uri'
require 'base64'

applicantData = JSON.parse(ARGV[0])
form = {
  'path'=> 'https://s3-us-west-2.amazonaws.com/bread-district-housing/forms/3treeflats.pdf',
  'name'=> '3treeflats'
}

form['filled_path'] = "/tmp/#{form['name']}.pdf"

# pdftk can't read from uri, storing in tmp file
form['tmp_path'] = "/tmp/#{form['name']}_tmp.pdf"
File.open(form['tmp_path'], "wb") do |file|
  file.write open(form['path']).read
end

filled = OutputPDF.new(form, applicantData).to_file

puts Base64.encode64(filled)

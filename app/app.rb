#!/usr/bin/env ruby
require 'json'
require_relative 'output_pdf.rb'
require 'open-uri'
require 'base64'

data = JSON.parse(ARGV[0])
form = data['form'];
applicant = data['applicant']

path = ''
if form['path'].include? 'google'
  doc_id = /\/file\/d\/(.+)\//.match(form['path'])[1]
  raise 'must set `GOOGLE_API_KEY` as environment variable' unless ENV['GOOGLE_API_KEY']
  path = "https://www.googleapis.com/drive/v3/files/#{doc_id}?key=#{ENV['GOOGLE_API_KEY']}&alt=media"
else
  path = form['path']
end

form['filled_path'] = "/tmp/#{form['name']}.pdf"
## pdftk can't read from uri, storing in tmp file
form['tmp_path'] = "/tmp/#{form['name']}_tmp.pdf"
File.open(form['tmp_path'], "wb") do |file|
  file.write open(path).read
end

filled = OutputPDF.new(form, applicant).to_file

puts Base64.encode64(filled)

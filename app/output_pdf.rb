require 'pdf_forms'
require 'tempfile'
require_relative 'value_for_fields'

class OutputPDF
  def initialize form, applicant
    @applicant = applicant
    @form = form
    @pdftk = PdfForms.new(`which pdftk`.chomp)
  end

  def to_file
    @pdftk.fill_form @form['tmp_path'], @form['filled_path'], form_field_hash
    File.binread(@form['filled_path'])
  end

  def form_field_hash
    Hash[form_fields.compact]
  end

  def form_fields
    vff = ValueForField.new
    fields.map do |field_name|
      [field_name, vff.value_of(@applicant, field_name)]
    end
  end

  def fields
    @pdftk.get_fields(@form['tmp_path']).map(&:name)
  end

  def filled_values
    @pdftk.fill_form @form['tmp_path'], @form['filled_path'], form_field_hash
    @pdftk.get_fields(@form['filled_path'])
  end

end

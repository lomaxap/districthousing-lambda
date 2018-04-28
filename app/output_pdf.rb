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
    fields.map do |f|
      name = f.name
      val = vff.value_of(@applicant, name) || f.value
      val = f.value if val == ""
      [name, val]
    end
  end

  def fields
    @pdftk.get_fields(@form['tmp_path'])
  end

  def filled_values
    @pdftk.fill_form @form['tmp_path'], @form['filled_path'], form_field_hash
    @pdftk.get_fields(@form['filled_path'])
  end

end

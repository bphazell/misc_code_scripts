require 'csv'
require 'uri'
require_relative 'filevalidator'

class FieldValidator
  attr_accessor :field_names, :csv
  @validations_by_field

  def initialize
    @field_names = []
    @validations_by_field = {}
    @csv = FileValidator.new
  end

  def validate_not_empty(field)
    !validate_empty(field)
  end

  def validate_empty(field)
    field.to_s.strip == ""
  end

  def validate_url_for_hyperlink(field)
    !!(field.strip =~ /^#{URI::regexp}$/)  # Strips all whitespace before running regex
  end

  def validate_url_for_hyperlink_with_blanks(field)
    field.to_s.strip == "" or !!(field.strip =~ /^#{URI::regexp}$/) # Allows blank cells in url column
  end

  def validate_digits_only(field)
    !(field =~ /\D/)
  end

  def list_validations
    (methods - Object.methods).reject { |v| !v.to_s.include?("validate_") }
  end

  def add_validations(field,validations)
    @validations_by_field[field] = validations.map { |validation| self.method(validation.to_sym) }
  end

  def validations_by_field
    @validations_by_field
  end

  def run_validations
    raise "You must assign a file to your csv to run your validations." if @csv.file.nil?
    valid = true
    output_file = @csv.file.gsub(".csv","_validated.csv")
    headers = @csv.headers + ["validates","failures"]
     CSV.open(output_file,'w',:headers=>headers,:write_headers=>true) do |validated|
      CSV.foreach(@csv.file, :headers=>true) do |row|
        row["validates"], row["failures"], failures = nil, nil, []
        @validations_by_field.each do |field,validations|
          validations.each do |validation|
            row["validates"] = validation.call(row[field])
            failures << "#{validation.name}(#{field} = '#{row[field]}')" if !row["validates"]
          end
        end
        if !failures.empty? 
          valid = false if valid
          row["failures"] = failures.join("\n")
          row["validates"] = false # Ensures validates=false if there are any failures
        end
        validated << headers.map { |h| row[h] }
      end
    end
    {:valid=>valid, :output_file=>output_file}
  end
end
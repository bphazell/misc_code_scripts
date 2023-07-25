require 'csv'
require 'ap'

class CSV_Cols
  attr_accessor :csv_name, :columns_hash, :headers

  def initialize(csv)
    @csv_name = csv
    @headers = grab_headers
    @columns_hash = populate_columns_hash
  end

  def populate_columns_hash
    @headers.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |header, hash|
      CSV.foreach(@csv_name, headers: true) do |row|
        hash[header] << row[header]
      end 
    end
  end

  def grab_headers
    headers = []
    CSV.foreach(@csv_name, headers: false) do |row|
      headers = row
      return headers
    end
  end

  def change_col_name_from_to(old_col_name, new_col_name)
    update_headers(old_col_name, new_col_name)
    update_columns_hash(old_col_name, new_col_name)
  end

  def update_headers(old_col_name, new_col_name)
    @headers.map! { |header| old_col_name == header ? new_col_name : header}
  end

  def update_columns_hash(old_col_name, new_col_name)
    @columns_hash[new_col_name] = @columns_hash[old_col_name]
    @columns_hash.delete(old_col_name)
  end

  # subset("id", "==", "Yes")
  # subset("id", "==", "No")
  def subset(header, cond, compared_to)
    keeper_indices = []
    @columns_hash[header].each.with_index do |el, index|
      case cond
      when "<"
        keeper_indices << index if el.to_f < compared_to.to_f
      when ">"
        keeper_indices << index if el.to_f > compared_to.to_f
      when "<="
        keeper_indices << index if el.to_f <= compared_to.to_f
      when ">="
        keeper_indices << index if el.to_f >= compared_to.to_f
      when "=="
        keeper_indices << index if el.to_s == compared_to.to_s
      when "!="
        keeper_indices << index if el.to_s != compared_to.to_s
      end
    end
    @columns_hash = subset_using_new_array_indices(keeper_indices)
  end

  def subset_using_new_array_indices(keeper_indices)
    @columns_hash.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |(header, array), new_hash|
      array.each_with_index do |el, i|
        new_hash[header] << el if keeper_indices.include? i
      end 
    end
  end

  def open_columns_method(csv, a_or_w)
    nrows = @columns_hash.first[1].length
    CSV.open(csv, a_or_w, headers: @headers, write_headers: true) do |out|
      (0...nrows).each do |nrow|
        row = []
        @headers.each do |header|
          row << @columns_hash[header][nrow]
        end
        out << row
      end
    end
    return "CSV written to #{csv}"
  end

end

csv_object = CSV_Cols.new("test.csv")
csv_object.columns_hash
csv_object.change_col_name_from_to("id", "identification_number")
csv_object.subset("identification_number", "<", 5)
csv_object.open_columns_method("tester_outputter.csv", "w")

csv_object = CSV_Cols.new("test.csv")
csv_object.change_col_name_from_to("id", "identification_number")
csv_object.subset("identification_number", ">=", 5)
csv_object.open_columns_method("opposite_tester_outputter.csv", "w")


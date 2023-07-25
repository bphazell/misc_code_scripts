require 'rubygems'
require 'csv'
require 'json'

print "Loading file..."
top_level = []
taxonomy_items = {}
input_file = ARGV[0]
output_file = ARGV[1]

raise "Input and output filenames must be provided. Syntax: 'ruby to_taxonomy.rb <input_file> <output_file>'" unless output_file if !(input_file && output_file)

output_file = output_file.split(".")[0..-2].join(".")

begin
  csv = CSV.open(File.expand_path(ARGV[0]), "r")
rescue
  raise "File #{ARGV[0]} invalid or not found."
end
puts "done!"

print "Processing data..."
headers = csv.shift
#using this method because it's faster than using fastercsv's built in header wrapper
cat_id_index = headers.index('category_id')
parent_id_index = headers.index('parent_id')
name_index = headers.index('category_name')
summary_index = headers.index('notes')

csv.each do |row|
  p_id = row[parent_id_index]
  c_id = row[cat_id_index]
  taxonomy_items[c_id] = {} unless taxonomy_items[c_id]
  if p_id == "0"
    top_level << c_id.to_i
  else
    taxonomy_items[c_id]['parent'] = p_id
    taxonomy_items[p_id] = {} unless taxonomy_items[p_id]
    taxonomy_items[p_id]['children'] = [] unless taxonomy_items[p_id]['children']
    taxonomy_items[p_id]['children'] << c_id
  end
  taxonomy_items[c_id]['title'] = row[name_index].gsub(/\n/, " ").strip
  taxonomy_items[c_id]['summary'] = row[summary_index].strip if summary_index && row[summary_index]

end
puts "done!"

#json bitches

print "Writing JSON..."
#hacking it to keep the categories ordered
keys = taxonomy_items.keys.sort{|x,y| x.to_i <=> y.to_i}

output = []

keys.each do |key|
  taxonomy_items[key]['children'].sort!{|x,y| x.to_i <=> y.to_i} if taxonomy_items[key]['children']
  output << "\"#{key}\":#{taxonomy_items[key].to_json}"
end

File.open("#{output_file}.js", "w"){|f| f << "var #{output_file} = {\"topLevel\":#{top_level.to_json}, \"taxonomyItems\":{#{output.join(',')}}};"}
puts "done!"
puts "Updated taxonomy written in #{output_file}.js"

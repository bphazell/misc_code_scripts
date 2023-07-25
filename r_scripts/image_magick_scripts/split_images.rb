require 'FileUtils'

source_location = "/Users/bhazell/Dropbox (CrowdFlower)/jpeg_apple"
output_location = "/Users/bhazell/Desktop/image_magick/output"


Dir.glob("#{source_location}/*.jpg") do |file|
	p file
	filename = file.split("/")[-1]
	image_id = filename.split('.')[0]
	output_path = File.join(output_location, image_id)
	FileUtils.mkdir_p(output_path)
	command = "convert '#{file}' -crop 5x5@  +repage  +adjoin  '#{File.join(output_path,"tiles.jpg")}'"
	system(command)
	#exit()
end
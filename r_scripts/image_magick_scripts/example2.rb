image_location = 'asdasdad/asdad/asd/adssa'
image_out_location = 'asdasdad/asdad/asd/adssa'

tiles = 25.times.each_slice(5).map do |slice|
	"( " + slice.map do |id|
		"#{image_location}/tile-#{id}.jpg"
	end.join(" ") + " +append ) "
end.join(" ")

p tiles 

full_cmd = "convert '#{tiles}' -append #{image_out_location}/aggregate.jpg"
p full_cmd
#system(full_cmd)

"""
\( img1split-0.jpg img1split-1.jpg img1split-2.jpg img1split-3.jpg img1split-4.jpg +append \) \
\( img1split-5.jpg img1split-6.jpg img1split-7.jpg img1split-8.jpg img1split-9.jpg +append \) \
\( img1split-10.jpg img1split-11.jpg img1split-12.jpg img1split-13.jpg img1split-14.jpg +append \) \
\( img1split-15.jpg img1split-16.jpg img1split-17.jpg img1split-18.jpg img1split-19.jpg +append \) \
\( img1split-20.jpg img1split-21.jpg img1split-22.jpg img1split-23.jpg img1split-24.jpg +append \) \ -append cobmined.jpg
"""
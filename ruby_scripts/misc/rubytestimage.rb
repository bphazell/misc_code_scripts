

img = Magick::Image::read("#{0175384d-b5f2-4734-9b25-d7867355d5b9.jpg}").first

def split_images(i)
  #'image' is a ImageMagick Object
  width  = image.cols/number_cols
  height = image.rows/nubmer_rows
  images = []
  0.upto(number_rows-1) do |x|
    0.upto(number_cols-1) do |y|
      images << image.crop( Magick::NorthWestGravity, x*width, y*height, width, height, true)
    end
  end
end

split_images(img)


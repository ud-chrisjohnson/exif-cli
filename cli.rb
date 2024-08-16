
require "thor"
require "exif"

class ExifCli < Thor

  option :output, :aliases => :o, :default => 'images.csv', :banner => 'File to write to. Must be a .csv or .html'
  desc "extract", "Extract GPS data from image directory"
  def extract(directory = '.')    
    unless File::directory?(directory)
      puts "Valid directory is required"
      return -1
    end

    output_file = options[:output]
    unless output_file.end_with?(".csv") || output_file.end_with?(".html")
      puts "Output file must be .csv or .html"
      return -1
    end

    images = []

    all_files = get_files(directory)

    all_files.each do |file|
      image = { :filename => file, :lat => nil, :lon => nil }
      begin        
        geo_data = Exif::Data.new(File.open(file))[:gps]

        image[:lat] = geo_decimal(*geo_data[:gps_latitude], geo_data[:gps_latitude_ref]) unless geo_data.empty?
        image[:lon] = geo_decimal(*geo_data[:gps_longitude], geo_data[:gps_longitude_ref]) unless geo_data.empty?
      rescue Exception => e
        puts "#{file} - WARNING: #{e}"
      end
      images << image
    end

    output_file.end_with?(".html") ? write_html(images, output_file) : write_csv(images, output_file)
    puts "Found #{images.size} images and wrote to #{output_file}"
  end
  
  private
  def get_files(dir, paths = [])
    Dir.each_child(dir) do |file|
      full_path = "#{dir}/#{file}"
      if file.downcase.end_with?(".jpg")
        paths << full_path
      elsif File.directory?(full_path)
        get_files(full_path, paths)
      else 
        next
      end      
    end
    paths.sort
  end

  def geo_decimal(degrees, minutes, seconds, direction)
    (degrees + (minutes / 60.0) + (seconds / 3600.0)) * (direction == 'S' || direction == 'W' ? -1 : 1)
  end

  def write_csv(images, filename)
    file = File.new(filename, "w")
    file.puts 'Filename,Latitude,Longitude'
    images.each { |image| file.puts "#{image[:filename]},#{image[:lat]},#{image[:lon]}"}
    file.close
  end

  def write_html(images, filename)
    file = File.new(filename, "w")
    file.puts "<html>\n\t<head>\n\t\t<style>\n\t\t\timg { height: auto; width: 128px; display: block; margin-left: auto; margin-right: auto; }\n\t\t\ttable, th, td { border: 1px solid black }\n\t\t\ttd { padding: 2px; height: 132px; }\n\t\t</style>\n\t</head>\n\t<body>\n\t\t<h1>Images</h1>\n\t\t<table>\n\t\t\t<tr>\n\t\t\t\t<th>Image</th>\n\t\t\t\t<th>Filename</th>\n\t\t\t\t<th>Latitude</th>\n\t\t\t\t<th>Longitude</th>\n\t\t\t</tr>"
    images.each do |image| 
      file.puts "\t\t\t<tr>\n\t\t\t\t<td><img src=\"#{image[:filename]}\" /> </td>\n\t\t\t\t<td>#{image[:filename]}</td>\n\t\t\t\t<td>#{image[:lat]}</td>\n\t\t\t\t<td>#{image[:lon]}</td>\n\t\t\t</tr>"
    end
    file.puts "\t\t</table>\n\t</body>\n</html>"
    file.close
  end
end

ExifCli.start(ARGV)

# EXIF CLI Application

This console application will locate all .jpg images in a directory, including nested directories, and output the geolocation data from them, if present.

Output can be formatted for either CSV or HTML

## Usage
`ruby cli.rb extract [<directory>] [-o|--output <output_file>]`

## Examples
- `ruby cli.rb extract` - Will extract images from the current directory and output in CSV format to `images.csv`
- `ruby cli.rb extract ~/images` - Will extract images from the `~/images` directory and output in CSV format to `images.csv`
- `ruby cli.rb extract -o images.html` - Will extract images from the current directory and output in HTML format to `images.html`
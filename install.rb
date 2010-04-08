require 'rubygems'

puts 'Copying files...'

public_path = File.join(RAILS_ROOT, 'public')
current_path = File.join(File.dirname(__FILE__), 'media')

javascripts_path = File.join(public_path, 'javascripts')
stylesheets_path = File.join(public_path, 'stylesheets')
images_path = File.join(public_path, 'images')

# copying JS
js_file = 'colorPicker.js'
dest_file = File.join(javascripts_path, js_file)
src_file = File.join(current_path, 'javascripts', js_file)
FileUtils.cp_r(src_file, dest_file)

# copying CSS
css_file = 'colorPicker.css'
FileUtils.cp_r(File.join(current_path, 'stylesheets', css_file), File.join(stylesheets_path, css_file))

# copying images
plugin_images_path = File.join(current_path, 'images')

Dir.foreach(plugin_images_path) do |image|
  src_image = File.join(plugin_images_path, image)

  if File.file?(src_image)
    dest_image = File.join(images_path, image)
    FileUtils.cp_r(src_image, dest_image)
  end
end

puts "Done - Installation complete!\nPlease run `rake db:migrate:plugins` and `rake redmine_labels:create:custom_field`"

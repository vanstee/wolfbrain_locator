require 'bundler'
Bundler.require

framework 'Cocoa'
framework 'CoreLocation'

def locationManager(manager, didUpdateToLocation: location, fromLocation: from_location)
  formatted_location = "#{location.coordinate.latitude},#{location.coordinate.longitude}"
  reverse_location = Geokit::Geocoders::GoogleGeocoder.reverse_geocode(formatted_location)
  @@location_menu_item.title = "You are currently in #{reverse_location.city}, #{reverse_location.state}"

  puts formatted_location
end

def quit(sender)
  NSApplication.sharedApplication.terminate(self)
end

application = NSApplication.sharedApplication

menu = NSMenu.new
menu.initWithTitle('Wolfbrain Locator')

@@location_menu_item = NSMenuItem.new
@@location_menu_item.title = 'The mighty Wolfbrain Locator is ineffective against your dark hipster magic!'
@@location_menu_item.target = self
menu.addItem(@@location_menu_item)

menu_item = NSMenuItem.new
menu_item.title = 'Quit'
menu_item.action = 'quit:'
menu_item.target = self
menu.addItem(menu_item)

status_bar = NSStatusBar.systemStatusBar
status_item = status_bar.statusItemWithLength(NSVariableStatusItemLength)
status_item.setMenu(menu)
status_item.setTitle('Wolfbrain Locator')
# image = NSImage.new.initWithContentsOfFile('image.png')
# status_item.setImage(image)

location_manager = CLLocationManager.alloc.init
location_manager.delegate = self
location_manager.startUpdatingLocation

application.run
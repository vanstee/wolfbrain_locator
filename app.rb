require 'bundler'
Bundler.require

framework 'Cocoa'
framework 'CoreLocation'

class WolfbrainLocator
  def initialize
    @application = NSApplication.sharedApplication
    self.methods.grep(/^initialize_/).map{ |s| self.method(s) }.each(&:call)
    @application.run
  end

  def initialize_menu
    @menu = NSMenu.new
    @menu.initWithTitle('Wolfbrain Locator')
  end

  def initialize_location_label
    @location_label = NSMenuItem.new
    @menu.addItem(@location_label)
    update_location
  end

  def initialize_location_menu_item
    @location_menu_item = NSMenuItem.new
    @location_menu_item.title = 'Update Current Location'
    @location_menu_item.action = 'locate:'
    @location_menu_item.target = self
    @menu.addItem(@location_menu_item)
  end

  def initialize_quit_menu_item
    @quit_menu_item = NSMenuItem.new
    @quit_menu_item.title = 'Quit'
    @quit_menu_item.action = 'quit:'
    @quit_menu_item.target = self
    @menu.addItem(@quit_menu_item)
  end

  def initialize_status_bar
    @status_bar_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength)
    @status_bar_item.setMenu(@menu)
    @status_bar_item.setTitle('Wolfbrain Locator')
    # image = NSImage.new.initWithContentsOfFile('image.png')
    # @status_bar_item.setImage(image)
  end

  def locate(sender)
    @location_manager = CLLocationManager.alloc.init
    @location_manager.delegate = self
    @location_manager.startUpdatingLocation
  end

  def quit(sender)
    NSApplication.sharedApplication.terminate(self)
  end

  def locationManager(manager, didUpdateToLocation:new_location, fromLocation:old_location)
    @location_manager.stopUpdatingLocation
    @absolute_location = "#{new_location.coordinate.latitude},#{new_location.coordinate.longitude}"
    @relative_location = Geokit::Geocoders::GoogleGeocoder.reverse_geocode(@absolute_location)
    update_location
  end

  def locationManager(manager, didFailWithError:error)
    @location_manager.stopUpdatingLocation
  end

  def update_location
    formatted_location = @relative_location && "#{@relative_location.city}, #{@relative_location.state}"
    @location_label.title = "Location: #{ formatted_location || 'Unknown' }"
  end

  def serial_number
    @serial_number ||= `system_profiler SPHardwareDataType`.match(/Serial Number.*: (.*)/)[1]
  end
end

WolfbrainLocator.new

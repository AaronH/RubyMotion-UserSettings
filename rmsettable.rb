# rmsettable.rb
# https://github.com/AaronH/RubyMotion-UserSettings

module RMSettable

  def rm_settable(*args)
    # Call this in your app_delegate.rb as part of the didFinishLaunchingWithOptions setup.
    #
    # The arguments can consist of symbols for various settings you wish to store.
    #
    #    rm_settable :name, :background_color
    #
    #
    # By default, the keys store and retrieve generic objects. If you wish to specify a
    # particular type, you may declare that as a hash on the key.
    #
    #    rm_settable :name, age: {type: :integer}, superstar: {type: :boolean}
    #
    # AVAILABLE TYPES :array, :boolean, :data, :dictionary, :double, :float,
    #                 :integer, :object, :string_array, :string, :url
    #
    #
    # You can also include a hash of options.
    #
    #    rm_settable name: {type: :string}, age: options: {autosave: false, default_type: :integer}
    #
    #    rm_settable options: {:lenient_keys}
    #
    # AVAILBLE OPTIONS
    #        :autosave  true (default)
    #                   By default, settings are synchronized to the device as soon as
    #                   it is updated. However, if you are updating a lot of items at once
    #                   or would prefer to manually call save on the settings object, set
    #                   this to false. Be aware that iOS will still save the settings
    #                   periodically without being explicitly called.
    #
    #    :default_type  :object (default)
    #                   Items are saved as objects. You many specify the type
    #                   when you declare the setting names or override the default
    #                   expected for all item.
    #
    #    :lenient_keys  false (default)
    #                   If you don't want to declare any or all of the settings you will
    #                   be storing, set this to true. Any setting not explicitly declared
    #                   will be stored and retrieved as the default setting type.
    #
    @rm_settings = RMSettings.new args
  end


  def applicationDidEnterBackground(application)
    # make sure we save any unsaved settings when going to the background
    # if you override this method in the app_delegate
    # be sure to call super to save any unsaved settings
    rm_settings.save
  end

  def applicationWillTerminate(application)
    # make sure we save any unsaved settings when being terminated
    # if you override this method in the app_delegate
    # be sure to call super to save any unsaved settings
    rm_settings.save
  end

  def settings
    # provide access to the RMSettings object to the app_delegate
    rm_settings
  end

  def self.included(base)
    base.class_eval do
      attr_accessor :rm_settings
    end
  end
end

# These subclasses provide easy access to the app_delegate and settings object.
# If you wish to call settings directly from your controller or view, be sure
# to inherit from these classes
class RMView < UIView
  def settings
    application.settings
  end

  def application
    UIApplication.sharedApplication.delegate
  end
end

class RMViewController < UIViewController
  def settings
    application.settings
  end
  def application
    UIApplication.sharedApplication.delegate
  end
end
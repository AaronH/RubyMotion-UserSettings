RubyMotion-UserSettings
===================

An extension to allow RubyMotion apps easy access to reading, writing, and persisting user settings and other objects on iOS via NSUserDefaults.

Installation
------------

Copy the `rmsettable.rb` and `rmsettings.rb` into your `/app` directory. As there isn't yet a convention for where to put these sorts of files, I'd recommend adding a `/app/lib/rm_settings` directory.

    /project
      /app
        /lib
          /rm_settings
             rmsettable.rb
             rmsettings.rb

Setup
-----

Given the way RubyMotion compiles files, you will probably need to add the RMSettings files to your `Rakefile` files_dependencies options.

```ruby
Motion::Project::App.setup do |app|
  app.files_dependencies  'app/app_delegate.rb' => 'app/lib/rm_settings/rmsettable.rb',
                          'app/lib/rm_settings/rmsettable.rb' => 'app/lib/rm_settings/rmsettings.rb'

  ...
```

Usage
-----

### Initializing

To begin, include `RMSettable` inside the `AppDelegate` class of `/app/app_delegate.rb` and call the `rm_settable` function with your other `didFinishLaunchingWithOptions` code.

```ruby
class AppDelegate
  include RMSettable

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    rm_settable :name, :background_color

  ...
```

In its simplest form, the `rm_settable` function is called with a list of symbols for the settings your app will save to the NSUserDefaults.

```ruby
  rm_settable :name, :background_color
```

By default, the keys expect the settings for your app to be passed and stored as strings.  If you wish to use another type, you may declare that as a hash on the key.

```ruby
  rm_settable :name, age: {type: :integer}, completed_tutorial: {type: :boolean}
```

The types available derive from the NSUserDefault class.  They can be :array, :boolean, :data, :dictionary, :double, :float, :integer, :object, :string_array, :string, or :url.

### Options


Additionally, you can include a hash of options to affect the way RMSettings works.

```ruby
  rm_settable age:, name: {type: :string}, options: {autosave: false, default_type: :integer}
```

```ruby
  rm_settable options: {:lenient_keys}
```

#### Available Options
*   `autosave` _(true)_

    By default, settings are synchronized to the device as soon as
    it is updated. However, if you are updating a lot of items at once
    or would prefer to manually call save on the settings object, set
    this to false. Be aware that iOS will still save the settings
    periodically without being explicitly called.

    Regardless of this setting, settings will also be saved when
    `applicationDidEnterBackground` or `applicationWillTerminate` is called
    on the app.  To prevent this behaviour, you must override these methods
    in your `app_delegate.rb`.

*   `default_type` _(:string)_

    Items being saved expect to be Strings. You many also specify the
    required type when you declare the setting names. With this
    setting you may override the default type expected for all settings.

*   `lenient_keys` _(false)_

    If you don't want to declare any or all of the settings you will
    be storing, set this to true. Any setting not explicitly declared
    will still be stored and retrieved as the default setting type.

### Reading and Writing User Settings

A method named `settings` is added to the application's delegate and supplies a simple interface to the user settings.

```ruby
  # write a setting
  UIApplication.sharedApplication.delegate.settings.name = 'Karl Pilkington'

  # read a setting
  @name = UIApplication.sharedApplication.delegate.settings.name

  # check a setting's boolean value or blankness
  UIApplication.sharedApplication.delegate.settings.name?

  # reset a setting to its default (also aliased as 'reset' or 'remove')
  UIApplication.sharedApplication.delegate.settings.delete :name
```

Extras
------

Convenience subclasses are provided for `UIViewController` and `UIView` called `RMViewController` and `RMView`. If you derive your views and controllers form these classes you will have even easier access to the application's settings.

```ruby
class MyCoolView < RMView

  def headClassifier
    if !settings.head_shape? and settings.username =~ /karl\spilkington/i
      settings.head_shape = 'Orange'
    end
  end
  ...
```

To Do
-----
* Add tests
* Add error reporting
* Check that passed data types are valid
* Add support for setting default value at declaration


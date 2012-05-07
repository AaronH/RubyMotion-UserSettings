RubyMotion-settings
===================

A convenience wrapper to allow RubyMotion apps easy access to reading, writing, and persisting values via NSUserDefaults.

Installation
============

Copy the `rmsettable.rb` and `rmsettings.rb` into your `/app` directory. As there isn't yet a convention for where to put these sorts of files, I'd recommend adding a `/app/lib/rm_settings` directory.  
  
    /project
      /app
        /lib
          /rm_settings
             rmsettable.rb
             rmsettings.rb

Given the way RubyMotion compiles files, you will probably need to add the RMSettings files to your `Rakefile` files_dependencies options.

```ruby
Motion::Project::App.setup do |app|
  app.files_dependencies  'app/app_delegate.rb' => 'app/lib/rm_settings/rmsettable.rb',
                          'app/lib/rm_settings/rmsettable.rb' => 'app/lib/rm_settings/rmsettings.rb'

  ...
```

Include `RMSettable` inside the `AppDelegate` class of `/app/app_delegate.rb` and call the `rm_settable` function with your other `didFinishLaunchingWithOptions` code.

```ruby
class AppDelegate
  include RMSettable

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    rm_settable :name, finished_tutorial: {type: :boolean}, options: {autosave: false}

  ...
```

For details on usage, see the code files.
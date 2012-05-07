# rmsettings.rb
# https://github.com/AaronH/RubyMotion-UserSettings

class RMSettings
  attr_accessor :settings, :available, :keys, :options

  def initialize(*args)
    # Initializes the available settings and options
    # See rmsettable.rb for details on the various options
    args = args.flatten.compact.uniq
    @available  = {}
    @settings ||= NSUserDefaults.standardUserDefaults

    user_options = (args.select{|a| a.is_a? Hash}.first || {}).delete(:options) || {}
    @options  = { autosave:     true,
                  lenient_keys: false,
                  default_type: :object}.merge(user_options)

    args.flatten.each do |item|
      if item.is_a?(Symbol)
        @available[item] = {type: @options[:default_type]}
      elsif item.is_a?(Hash)
        item.each do |key, value|
          @available[key] = value
        end
      end
    end
    @keys = @available.keys
  end

  def save
    # Save all current settings to the device.
    # Can be called manually but is generally called automatically
    # after updating a key unless the :autosave option is false.
    settings.synchronize
  end

  def autosave
    # Automatically saves the data unless autosave is false.
    save if autosave?
  end

  def autosave?
    # Check to see if the autosave option is selected
    options[:autosave]
  end

  def default_type_for(key)
    # Determine the appropriate type for reading and writing item
    ((@available[key] || {})[:type] || @options[:default_type])
  end

  def setting_for?(key)
    # Call to check boolean status of a particular key.
    # Generally called dynamically from the method_missing function.
    #
    #    settings.setting_for? :tutorial_completed
    #
    #    settings.tutorial_completed?
    #
    value = setting_for(key)
    case default_type_for(key)
    when :string, :array
      value.empty?
    else
      !!value
    end
  end

  def save_setting(key, value)
    # Save the contents of value to the key.
    # Returns the value of the key after setting.
    #
    # Generally called dynamically from the method_missing function.
    #
    #    settings.save_setting :name, 'Karl Pilkington'
    #
    #    settings.head_shape = 'Orange'
    #
    case default_type_for(key)
    when :boolean
      settings.setBool    value, forKey: key
    when :double
      settings.setDouble  value, forKey: key
    when :float
      settings.setFloat   value, forKey: key
    when :integer
      settings.setInteger value, forKey: key
    when :object
      settings.setObject  value, forKey: key
    when :url
      settings.setURL     value, forKey: key
    else
      settings.setObject  value, forKey: key
    end

    autosave

    # return the current value
    setting_for key
  end
  alias :[]= :save_setting

  def setting_for(key)
    # Read the contents of a given key.
    #
    # Generally called dynamically from the method_missing function.
    #
    #    settings.setting_for :nickname
    #
    #    settings.nickname
    #
    case default_type_for(key)
    when :array
      settings.arrayForKey      key
    when :boolean
      settings.boolForKey       key
    when :data
      settings.dataForKey       key
    when :dictionary
      settings.dictionaryForKey key
    when :double
      settings.doubleForKey     key
    when :float
      settings.floatForKey      key
    when :integer
      settings.integerForKey    key
    when :object
      settings.objectForKey     key
    when :string_array
      settings.stringArrayForKey key
    when :string
      settings.stringForKey     key
    when :url
      settings.URLForKey        key
    end
  end
  alias :[] :setting_for

  def remove(key)
    # Resets the key to it's default value and returns that value
    # Aliased as delete and reset
    settings.removeObjectForKey key
    autosave
    setting_for key
  end
  alias :delete :remove
  alias :reset  :remove

  def valid_key?(key)
    # Checks to see if the method_missing key has been declared
    # unless that functionality has been turned off in the settings
    @options[:lenient_keys] or keys.include?(key)
  end

  def method_missing(method, *args)
    # Split the method to componenet parts to do our magic.
    if m = method.to_s.match(/^([^\?\=]+)([\?\=])?$/)
      base_key        = m[1].to_sym
      method_modifier = m[2]
      # Check if we want to do something here.
      if valid_key?(base_key)
        return  case method_modifier
                when nil
                  # Call the reader
                  setting_for(base_key)
                when '='
                  # Call the writer
                  save_setting(base_key, [*args].flatten.first)
                when '?'
                  # Call the boolean check
                  setting_for?(base_key)
                else
                  # Nothing to do, so let's fail
                  super
                end
      end
    end
    super
  end

end
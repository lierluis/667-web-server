require File.join File.dirname(__FILE__), 'config'

class Htaccess < ConfigFile
  attr_reader :config
  
  def initialize(str)
    super
    self.process_lines()
  end
  
  def process_lines
    @config=Hash.new()
    line_hash=load() #retrieves hash of the multi-line string
    line_hash.each do |config_option, config_values|
      @config[config_option]=Array.new()
      config_values.split(' ').each_with_index do |config_value, iteration|
        @config[config_option][iteration]=config_value
      end
    end
  end
  
  def auth_user_file
    if(!@config.has_key?('AuthUserFile'))
      return ""
    end
    return @config['AuthUserFile'][0]
  end
  
  def auth_type
    if(!@config.has_key?('AuthType'))
      return ""
    end
    return @config['AuthType'][0]
  end
  
  def auth_name
    if(!@config.has_key?('AuthName'))
      return ""
    end
    return "\"#{@config['AuthName'].join(" ")}\"" # returns a string
  end
  
  def require
    if(!@config.has_key?('Require'))
      return ""
    end
    return @config['Require'].join(" ") # possible multiple users
  end
  
end

# sample code
# 
#htaccess = Htaccess.new(File.open("public/protected/.htaccess", "r").read())
#print "AuthUserFile: ", htaccess.auth_user_file(),"\n"
#print "AuthType: ", htaccess.auth_type(),"\n"
#print "AuthName: ", htaccess.auth_name(),"\n"
#print "Require: ", htaccess.require(),"\n"

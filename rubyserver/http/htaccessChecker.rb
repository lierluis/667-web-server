require_relative 'htaccess'
require_relative 'config'
require 'base64'
require 'digest'
require 'pathname'
class HtaccessChecker
  attr_reader :path, :headers, :config
  
  # 'path' parameter can be both a path object or a path string
  def initialize(path, headers, config) 
    @headers = headers
    @config = config

    #make sure path is a directory, so we can check for existence of access file
    if not File.directory?(path)
      path=File.dirname(path)
    end

    #For security, check if the path parameter already points to an access file
    if path.to_s.end_with? '/'+@config.access_file_name
      @path=Pathname.new(path.to_s)
    else
      @path=Pathname.new(path.to_s)
      @path=@path.join(@config.access_file_name)
    end
  end
  
  def protected?
    if File.exist?(@path)
      return true
    else 
      return false
    end
  end

  def can_authorize?
    user_identif = @headers['Authorization']
    if user_identif == nil
      return false
    else 
      return true
    end
  end

  def authorized?

    if not self.protected?
      return true
    end

    if not self.can_authorize?
      return false
    end

    user_identif       = @headers['Authorization']
    pass               = user_identif.split(" ")
    decoded_ident      = Base64.decode64(pass[1])
    htaccess           = Htaccess.new(File.open(@path, "r").read())
    auth_user_file     = htaccess.auth_user_file
    htpwd_file         = File.open(auth_user_file, "r")
    htpwd_content      = htpwd_file.read()
    username, password = decoded_ident.split(':')
    htpwd_array        = htpwd_content.split("\n")
    
    htpwd_array.each do |content|
      htpasswd_parts = content.split(':')
      compare_string = htpasswd_parts[1].gsub(/{SHA}/, '').chomp
      if username.chomp == htpasswd_parts[0].chomp &&
          Digest::SHA1.base64digest(password).chomp == compare_string
        return true
      end
    end
    
    return false
  end
end

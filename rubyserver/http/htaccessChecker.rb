require_relative 'htaccess'
require 'base64'
require 'digest'

class HtaccessChecker
  attr_reader :path, :user_identif
  
  def initialize(path, user_identif)
    @path = path
    @user_identif = user_identif
  end
  
  def protected?
    #@filepath.include?(Dir.pwd) ? true : false
    if @path.include? "/home/izaacg/3_5webserver/SFSU_CSC_667/rubyserver/public_html/protected/" 
      return true
    else 
      return false
    end
  end

  def can_authorized?
    htaccess = Htaccess.new(File.open("/home/izaacg/3_5webserver/SFSU_CSC_667/rubyserver/public_html/protected/.htaccess", "r").read())
    @auth_user_file = htaccess.auth_user_file
    #@decoded_ident = Base64.decode64(@user_identif)
    return users(@user_identif)
  end

  
  def users(decoded_ident)
    htpwd_file = File.open(@auth_user_file, "r")
    htpwd_content = htpwd_file.read()
    username, password = decoded_ident.split(':')
    htpwd_array = htpwd_content.split("\n")
    htpwd_array.each do |content|
      htpasswd_parts = content.split(':')
      compare_string = htpasswd_parts[1].gsub(/{SHA}/, '')
      if username = compare_string[0] && Digest::SHA1.base64digest(password) == compare_string
        return true
      else
        return false
      end
    end
  end


  def authorized?
    can_authorized?
  end
end
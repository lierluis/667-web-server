require_relative 'htaccess'
require 'base64'
require 'digest'

class HtaccessChecker
  attr_reader :path, :headers
  
  def initialize(path, headers)
    @path = path
    @headers = headers
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
    user_identif = headers['Authorization']
    if user_identif == nil
      return false
    else 
      return true
    end
  end

  def authorized?
    user_identif = headers['Authorization']
    pass = user_identif.split(" ")
    decoded_ident = Base64.decode64(pass[1])
    htaccess = Htaccess.new(File.open("/home/izaacg/3_5webserver/SFSU_CSC_667/rubyserver/public_html/protected/.htaccess", "r").read())
    @auth_user_file = htaccess.auth_user_file
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
end
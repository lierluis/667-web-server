require 'socket' # allows use of TCPServer & TCPSocket classes
require 'thread'
# require File.join File.dirname(__FILE__), 'config' # access config.rb

#DEFAULT_PORT = 8999

class Webserver
  attr_reader :options, :socket, :port, :mime_types, :httpd_config
  
  def initialize(options={})
    @options = options
    
    #Open webserver configuration and mime types
    @httpd = HttpdConf.new(File.open("config/httpd.conf", "r").read())
    #@mimefile = File.open("config/mime.types", "r")
  end
  
  def start
    @portnumber = @httpd.port
    
    loop do
      puts "-----------------------------------------------"
      puts "Opening server socket to listen for connections"
      @socket = server.accept # open socket, wait until client connects
      
      puts "Received connection\n\n"
      Request.new(@socket).parse # parse client's HTTP request
      @socket.puts Response.new.to_s # print HTTP response to client
      
      @socket.close # terminate connection
      
#      Thread.new(@socket) do |newsocket| # thread for every session
#        puts "Received connection\n"
#        Request.new(newsocket).parse
#        newsocket.puts Response.new.to_s
#        
#        newsocket.close # terminate connection
#      end
    end
  end
  
  # TCPServer represents a TCP/IP server socket
  def server
    @server ||= TCPServer.open(options.fetch('localhost', @portnumber))
  end
end

# receives a stream in constructor, & parses content into members
class Request
  attr_reader :verb, :uri, :query, :version, :headers, :body, :http_request
  
  def initialize(stream)
    @http_request = stream
  end
  
  def parse
    request_line = @http_request.gets.split(" ")
    puts request_line.join(" ")
    
    path, query = request_line[1].split("?")
    
    @verb    = request_line[0]
    @uri     = request_line[1]
    @query   = query
    @version = request_line[2]
    @headers = Hash.new
    
    while (header = @http_request.gets) != "\r\n"
      key, value = header.split(": ")
      @headers.store(key, value)
      
      if key == "Content-Length"
        has_body = true
        content_length = value.to_i
      end
    end
    
    @headers.each do |key, value|
      puts "#{key}: #{value}"
    end
    puts "\r\n" # blank line
    
    if has_body == true
      @body = @http_request.read(content_length)
      puts @body
    end
    
  end
end

# generates generic OK response to send to the client
class Response
  attr_reader :version, :response_code, :response_phrase, :headers, :body
  
  def initialize
    @body            = "body"
    @version         = "HTTP/1.1"
    @response_code   = "200"
    @response_phrase = "OK"
    @headers         ={"Content-Type" => "text/plain",
                       "Content-Length" => "#{@body.bytesize}",
                       "Connection" => "close"}
  end
  
  def to_s
    s = "\r\n#{@version} #{@response_code} #{@response_phrase}\r\n"

    @headers.each do |key, value|
      s += "#{key}: #{value}\r\n"
    end
    s += "\r\n" # blank line
    s += "#{@body}\r\n"
    
    return s
  end
end

class HttpdConf 
    def initialize(httpdConfig)
      @config = httpdConfig.split("\n")
      @httpdhash = {}
    end
    def root
      @httpdhash[:root] = find("ServerRoot")
    end
    def docRoot
      @httpdhash[:docRoot] = find("DocumentRoot")
    end
    def port
      @httpdhash[:port] = find("Listen").to_i
    end
    def log
      @httpdhash[:log] = find("LogFile")
    end
    def errorlog
      @httpdhash[:errorlog] = find("ErrorLogFile")
    end
    def find(resource)
      keyword = ""
      @config.each do |line|
        if line.include? resource
          keyword = line.split(" ")
          break
        end
      end
      keyword = keyword[1]
    end
  end

class Htaccess
  attr_reader :config
  
  def auth_user_file
    
  end
end


Webserver.new.start
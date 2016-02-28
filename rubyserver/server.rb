require 'socket' # allows use of TCPServer & TCPSocket classesH
require 'thread'

#DEFAULT_PORT = 8999

class WebServer
  attr_reader :options, :socket
  
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
      
#	  Thread.new(@socket) do |newsocket| # thread for every session
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
  attr_reader :verb, :uri, :query, :version, :headers, :body, :request
  
  def initialize(stream)
    @request = stream
  end
  
  def parse
    request_line = @request.gets
    print "request line: ", request_line
    
    fullpath = request_line.split(" ")
    path, query = fullpath[1].split("?")
    
    @body    = "body"
    @verb    = fullpath[0]
    @uri     = fullpath[1]
    @query   = query
    @version = fullpath[2]
    @headers = Hash.new
    
    has_body = false
    while (header = @request.gets) != "\r\n"
      key, value = header.split(": ")
      @headers.store(key, value)
      
      if key == "Content-Length"
        has_body = true
      end
    end
    
    @headers.each do |key, value|
      puts "#{key}: #{value}"
    end
    puts "#{[header]}" # blank line
    
    if has_body == true
#      while line = @request.gets
#        puts "#{[line]}"
#      end
#      puts "#{[line]}"
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

WebServer.new.start
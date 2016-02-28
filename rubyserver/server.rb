require 'socket' # allows use of TCPServer & TCPSocket classes
require 'thread'
# require File.join File.dirname(__FILE__), 'config'
require File.join File.dirname(__FILE__), 'request'
require File.join File.dirname(__FILE__), 'response'

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

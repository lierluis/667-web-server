require 'socket' # allows use of TCPServer & TCPSocket classes
require 'thread'
require File.join File.dirname(__FILE__), 'config'
require File.join File.dirname(__FILE__), 'request'
require File.join File.dirname(__FILE__), 'response'
require File.join File.dirname(__FILE__), 'htaccess'

#DEFAULT_PORT = 8999

class Webserver
  attr_reader :options, :socket, :port, :mime_types, :httpd_config
  
  def initialize(options={})
    @options = options
  end
  
  def start
    read_config_file()
    @port = @httpd_config.listen()
    
    
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
  
  def read_config_file
    @httpd_config = HttpConfig.new(File.open("config/httpd.conf", "r").read())
    @mime_types = MimeTypes.new(File.open("config/mime.types", "r").read()).load
  end
  
  # TCPServer represents a TCP/IP server socket
  def server
    @server ||= TCPServer.open(options.fetch('localhost', @port))
  end
end

Webserver.new.start

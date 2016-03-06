require 'socket' # allows use of TCPServer & TCPSocket classes
require 'thread'
require File.join File.dirname(__FILE__), 'http/config'
require File.join File.dirname(__FILE__), 'http/worker'
require File.join File.dirname(__FILE__), 'http/response'
require File.join File.dirname(__FILE__), 'http/htaccess'

#DEFAULT_PORT = 8999

class Webserver
  attr_reader :options, :socket, :port, :mime_types, :httpd_config
  
  def initialize(options={})
    @options = options
  end
  
  def start
    read_config_file()
    @port = @httpd_config.listen()
    print "Now listening at port: ", @port, "\n"
    puts "Opening server socket to listen for connections"
    
    loop do
      
      @socket = server.accept # open socket, wait until client connects
      # puts "Received connection\n\n"
      # Request.new(@socket).parse # parse client's HTTP request
      # @socket.puts Response.new.to_s # print HTTP response to client
      # @socket.close # terminate connection
      
     Thread.new(@socket) do |newsocket| # thread for every session
       puts "-----------------------------------------------"
       puts "Received connection\n"
       Worker.new(newsocket).parse
       newsocket.close # terminate connection
     end
    end
  end
  
  def read_config_file
    @httpd_config = HttpConfig.new(File.open("config/httpd.conf", "r").read())
  end
  
  # TCPServer represents a TCP/IP server socket
  def server
    @server ||= TCPServer.open(options.fetch('localhost', @port))
  end
end

Webserver.new.start

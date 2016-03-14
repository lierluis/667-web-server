require 'socket' # allows use of TCPServer & TCPSocket classes
require 'thread'
require File.join File.dirname(__FILE__), 'http/config'
require File.join File.dirname(__FILE__), 'http/worker'

class Webserver
  attr_reader :options, :socket, :port, :mime_types, :httpd_config
  
  def initialize(options={})
    @options = options
  end
  
  def start
    read_config_file()
    @port = @httpd_config.listen()
    
    loop do
      puts "------------------------------------------------------------"
      puts "Opening server socket to listen for connections at port " + @port
      @socket = server.accept # open socket, wait until client connects
      puts "Received connection\n\n"
      Thread.new(@socket) do |threaded_socket| # thread for every session
        Worker.new(threaded_socket, @httpd_config, @mime_types).start
        threaded_socket.close # terminate connection
      end
    end
  end
  
  def read_config_file
    @httpd_config = HttpConfig.new(File.open("config/httpd.conf", "r").read())
    @mime_types = MimeTypes.new(File.open("config/mime.types", "r").read()).load
  end
  
  def server
    @server ||= TCPServer.open(options.fetch('localhost', @port))
  end
end

Webserver.new.start

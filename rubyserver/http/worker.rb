require_relative 'resource'
require_relative 'request'
require_relative 'response'
require_relative 'logger'
require_relative 'htaccess'

# responsible for handling a single request/response cycle, and logging it
class Worker
  attr_reader :client, :config, :logger, :mime_types
  
  def initialize(client, config, mime_types)
    @client = client # socket
    @config = config
    @mime_types = mime_types
    @logger = Logger.new(@config.log_file)
  end
  
  def start
    
    request = Request.new(@client) # get request
    request.parse
    
    # pass the request to find the resource
    resource = Resource.new(request, @config, @mime_types)
    file = resource.resolve
    
    puts file

    begin
      myfile = IO.readlines(file)
      if file
        response_code = 200
        @client.puts myfile
        puts response_code
      end
    rescue
      myfile = IO.readlines("public_html/404.html")
      response_code = 404
      @client.puts myfile
      puts response_code
    end

    response = Response.new(request, response_code)
    @client.puts response.to_s

  end

end



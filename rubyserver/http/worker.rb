require_relative 'resource'
require_relative 'request'
require_relative 'response'
require_relative 'logger'
require_relative 'htaccess'
require_relative 'htaccessChecker'
require_relative 'response_factory'
require 'base64'
require 'digest'
Thread.abort_on_exception = true
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
    begin
      request.parse
    rescue
      resp_file = IO.readlines(@config.document_root+Response.toPath(NOT_FOUND))
      @client.puts resp_file
      puts NOT_FOUND
    end

    resource = Resource.new(request, @config, @mime_types)

    response, body=ResponseFactory.create(request, resource)

    @client.puts response.to_s
    if body
      IO.copy_stream(body, @client)
    end
    puts response.to_s
    @logger.write(request,response)

  end

end



require_relative 'resource'
require_relative 'request'
require_relative 'response'
require_relative 'logger'
require_relative 'htaccessChecker'
require_relative 'response_factory'
Thread.abort_on_exception = true

# responsible for handling a single request/response cycle, and logging it
class Worker
  attr_reader :client, :config, :logger, :mime_types
  
  def initialize(client, config, mime_types)
    @client = client # socket
    @config = config
    @doc_root = @config.document_root
    @mime_types = mime_types
    @logger = Logger.new(@config.log_file)
  end
  
  def start
    begin
      request = Request.new(@client) # get request
      request.parse
      resource = Resource.new(request, @config, @mime_types)
    rescue
      response=Response.defaultRedirectResponse(BAD_REQUEST, @config, @mime_types)
    end
    begin
      response = ResponseFactory.create(request, resource)
    rescue
      response=ResponseFactory.defaultRedirectResponse(INTERNAL_ERROR, @config, @mime_types)
    end
    @client.puts response.to_s
    if response.body
      IO.copy_stream(response.body, @client)
    end
    puts response.to_s
    @logger.write(request,response)

  end

end



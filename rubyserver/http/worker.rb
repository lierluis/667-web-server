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
      begin
        request = Request.new(@client) # get request
        request.parse
      rescue # Bad request
        resp_file = IO.readlines(@doc_root+Response.toPath(BAD_REQUEST))
        @client.puts resp_file
        puts BAD_REQUEST
        return
      end
      resource = Resource.new(request, @config, @mime_types)
      response, body = ResponseFactory.create(request, resource)
    rescue # No other errors thrown, default to internal server error
      resp_file = IO.readlines(@doc_root+Response.toPath(INTERNAL_ERROR))
      @client.puts resp_file
      puts INTERNAL_ERROR
      return
    end

    @client.puts response.to_s
    if body
      IO.copy_stream(body, @client)
    end
    puts response.to_s
    @logger.write(request,response)

  end

end



class Response
  attr_reader :http_version, :response_code, :response_phrase, :headers, :body
  
  def initialize(request, response_code, body, mime_types, default=false)
    @body ||= body
    @response_code = response_code
    @response_phrase = PHRASES[@response_code]
    content_length = 0
    content_type = ""
    if default # Create default response 
      @http_version = 'HTTP/1.1'
      content_type = 'html'
    else
      @http_version = request.version
      content_type = mime_types.for(request.extension)
    end
    if @body
      content_length = File.size(body)
    end
    
    @headers = {
      "Date" => Time.now,
      "Server" => "derp",
      "Content-Type" => "#{content_type}",
      "Content-Length" => "#{content_length}",
      "Connection" => "close"          
    }
    if response_code == 401
      @headers["WWW-Authenticate"] = "Basic"
    end
  end


  PHRASES = {
    200 => 'OK', # standard response
    201 => 'Created', # new resource being created
    204 => 'No Content', #primarily for DELETE verb, no body returned
    304 => 'Not Modified', # no need to retransmit resource
    400 => 'Bad Request', # server can't process request b/c of client error
    401 => 'Unauthorized', # authentication is required and has failed
    403 => 'Forbidden', # you don't have necessary permissions for the resource
    404 => 'Not Found', # resource not found but may be available in the future
    500 => 'Internal Server Error' # unexpected condition encountered
  }

  def self.toPath(code)
    return '/' + code.to_s + ".html"
  end
  
  def to_s
    s = "#{@http_version} #{@response_code} #{@response_phrase}\r\n"
    @headers.map{|key, value| s += "#{key}: #{value}\r\n"}
    s += "\r\n"
    return s
  end
end

require_relative 'config.rb'

# generates generic OK response to send to the client
class Response
  attr_reader :http_version, :response_code, :response_phrase, :headers, :body
  
  def initialize(request, response_code, body, mime_types)
    @body            ||= body
    @http_version    = request.version
    @response_code   = response_code
    @response_phrase = PHRASES[@response_code]
    body_type=mime_types.for(request.extension)
    content_length=0
    if @body
      content_length=File.size(body)
    end
    @headers         ={"Date" => Time.now,
                       "Server" => "derp",
                       "Content-Type" => mime_types.for(request.extension),
                       "Content-Length" => "#{content_length}",
                       "Connection" => "close"}
    if response_code == 401
      @headers["WWW-Authenticate"]="Basic"
    end
  end
  
  PHRASES = {
    200 => 'OK', # standard response
    201 => 'Created', # new resource being created
    304 => 'Not Modified', # no need to retransmit resource
    400 => 'Bad Request', # server can't process request b/c of client error
    401 => 'Unauthorized', # authentication is required and has failed
    403 => 'Forbidden', # you don't have necessary permissions for the resource
    404 => 'Not Found', # resource not found but may be available in the future
    500 => 'Internal Server Error' # unexpected condition encountered
  }

  def self.toPath(code)
    return '/'+code.to_s+".html"
  end
  
  def to_s
    s = "#{@http_version} #{@response_code} #{@response_phrase}\r\n"
    @headers.map{|key, value| s += "#{key}: #{value}\r\n"}
    s += "\r\n"
    # The body will need to be appended directly to the socket as a byte stream
    # In the event that the body is a binary file, we can't imbed it in a string...
    return s
  end
end

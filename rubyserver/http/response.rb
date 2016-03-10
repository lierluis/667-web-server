# generates generic OK response to send to the client
class Response
  attr_reader :http_version, :response_code, :response_phrase, :headers, :body
  
  def initialize(request, response_code)
    @body            = "body"
    @http_version    = "HTTP/1.1"
    @response_code   = response_code
    @response_phrase = RESPONSE_PHRASES[@response_code]
    @headers         ={"Date" => Time.now,
                       "Server" => "derp",
                       "Content-Type" => "text/plain",
                       "Content-Length" => "#{@body.bytesize}",
                       "Connection" => "close"}
  end
  
  RESPONSE_PHRASES = {
    200 => 'OK', # standard response
    201 => 'Created', # new resource being created
    304 => 'Not Modified', # no need to retransmit resource
    400 => 'Bad Request', # server can't process request b/c of client error
    401 => 'Unauthorized', # authentication is required and has failed
    403 => 'Forbidden', # you don't have necessary permissions for the resource
    404 => 'Not Found', # resource not found but may be available in the future
    500 => 'Internal Server Error' # unexpected condition encountered
  }
  
  def to_s
    s = "\r\n#{@http_version} #{@response_code} #{@response_phrase}\r\n"
    @headers.map{|key, value| s += "#{key}: #{value}\r\n"}
    s += "\r\n" # blank line
    s += "#{@body}\r\n"
    
    return s
  end

  def logResponse
    responseTolog = {}
    responseTolog[:code] = @response_code
    responseTolog[:phrase] = @response_phrase
    return responseTolog
  end
end

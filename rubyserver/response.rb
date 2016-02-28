# generates generic OK response to send to the client
class Response
  attr_reader :version, :response_code, :response_phrase, :headers, :body
  
  def initialize
    @body            = "body"
    @version         = "HTTP/1.1"
    @response_code   = "200"
    @response_phrase = "OK"
    @headers         ={"Date" => Time.now,
                       "Server" => "derp",
                       "Content-Type" => "text/plain",
                       "Content-Length" => "#{@body.bytesize}",
                       "Connection" => "close"}
  end
   
  def to_s
    s = "\r\n#{@version} #{@response_code} #{@response_phrase}\r\n"
 
    @headers.each do |key, value|
      s += "#{key}: #{value}\r\n"
    end
    s += "\r\n" # blank line
    s += "#{@body}\r\n"
     
    return s
  end
end

# receives a stream in constructor, & parses content into members
class Request
  attr_reader :verb, :uri, :query, :version, :headers, :body, :http_request
  
  def initialize(stream)
    @http_request = stream
  end
  
  def parse
    request_line = @http_request.gets.split(" ")
    puts request_line.join(" ")
    
    path, query = request_line[1].split("?")
    
    @verb    = request_line[0]
    @uri     = request_line[1]
    @query   = query
    @version = request_line[2]
    @headers = Hash.new
    
    # get headers up until blank line
    while (header = @http_request.gets) != "\r\n"
      key, value = header.split(": ")
      @headers.store(key, value)
      
      # if content-length exists, there is a body
      if key == "Content-Length"
        has_body = true
        content_length = value.to_i
      end
    end
    
    # print headers, blank line, and body
    @headers.each do |key, value|
      puts "#{key}: #{value}"
    end
    puts "\r\n" # blank line

    if has_body == true
      @body = @http_request.read(content_length)
      puts @body
    end
    
  end
end

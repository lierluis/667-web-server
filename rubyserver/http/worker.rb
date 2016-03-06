require_relative 'resource'
require_relative 'config'
require_relative 'response'


# receives a stream in constructor, & parses content into members
class Worker
  attr_reader :verb, :uri, :query, :version, :headers, :body, :http_request
  
  def initialize(stream)
    @http_request = stream
  end
  
  def parse
    request_line = @http_request.gets.split(" ")
    puts request_line.join(" ")
    path, extension = request_line[1].split(".") #find the extension
    path, query = request_line[1].split("?")
    
    @verb    = request_line[0]
    @uri     = request_line[1]
    @query   = query
    @version = request_line[2]
    request = {}
    request[:uri] = @uri 
    request[:extension] = extension
    request[:query] = @query
    request[:verb] = @verb
    @headers = Hash.new
    
    # get headers up until blank line
    while (header = @http_request.gets) != "\r\n"
      key, value = header.split(": ")
      @headers.store(key, value)
    end
    
    @headers.map{|key, value| puts "#{key}: #{value}"}
    puts "\r\n" # blank line
    
    # print body if 'Content-Length' header exists
    if @headers.has_key?('Content-Length')
      content_length = @headers.values_at('Content-Length')[0].to_i
      @body = @http_request.read(content_length)
      puts @body
    end

    #passing the URI to resource
    httpd_conf = HttpConfig.new(File.open("config/httpd.conf", "r").read())
    mime_types = MimeTypes.new(File.open("config/mime.types", "r").read()).load
    resource = Resource.new(request, httpd_conf, mime_types)
    file = resource.resolve
   
    puts file

    begin
      myfile = IO.readlines(file)
      if file
        error = 200
        @http_request.puts myfile
        puts error
      end
    rescue
      myfile = IO.readlines("public_html/404.html")
      error = 404
      @http_request.puts myfile
      puts error
    end

    response = Response.new(request, error)
    @http_request.puts response.to_s

  end

end



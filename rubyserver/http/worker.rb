require_relative 'resource'
require_relative 'request'
require_relative 'response'
require_relative 'logger'
require_relative 'htaccess'
require_relative 'htaccessChecker'
require 'base64'
require 'digest'

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
      myfile = IO.readlines("public_html/400.html")
      response_code = 400
      @client.puts myfile
      puts response_code
    end  
    
    # pass the request to find the resource
    resource = Resource.new(request, @config, @mime_types)
    file = resource.resolve

    #check if the resource is protected
    accessChecker = HtaccessChecker.new(file,request.headers)
    
    if accessChecker.protected?
  
      if accessChecker.can_authorized?

        if accessChecker.authorized?

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
        else
          myfile = IO.readlines("public_html/403.html")
          response_code = 403
          @client.puts myfile
          puts response_code
        end
      else
        myfile = IO.readlines("public_html/401.html")
        response_code = 401
        @client.puts myfile
        puts response_code
      end
    else 
      #Is the file is a executable it gotta be in cgi-bin
      begin
        if file.include? "cgi-bin"
          IO.popen([{'ENV_VAR' => 'value'},file]) {|io| @client.puts io.read}
        else
          myfile = IO.readlines(file)
          if file
            response_code = 200
            @client.puts myfile
            puts response_code
          end
        end
      rescue
        myfile = IO.readlines("public_html/404.html")
        response_code = 404
        @client.puts myfile
        puts response_code
      end
    end
    response = Response.new(request, response_code) 
    @client.puts response.to_s 
    @logger.write(request,response)

  end

end



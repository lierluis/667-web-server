require_relative 'resource'
require_relative 'request'
require_relative 'response'
require_relative 'logger'
require_relative 'htaccess'
require_relative 'htaccessChecker'
require 'base64'
require 'digest'
NOT_FOUND = 404
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
      @client.puts myfile
      puts NOT_FOUND
    end

    # pass the request to find the resource
    resource = Resource.new(request, @config, @mime_types)


    #check if the resource is protected
    accessChecker = HtaccessChecker.new(file,request.headers,@config)
    
    if accessChecker.protected?
  
      if accessChecker.can_authorize?

        if accessChecker.authorized?

          if request.verb == 'GET'
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
          end
          if request.verb == 'HEAD'
            begin
              myfile = IO.readlines(file)
              if file
                response_code = 200
                @client.puts response_code
                puts response_code
              end
            rescue
              myfile = IO.readlines("public_html/404.html")
              response_code = 404
              @client.puts myfile
              puts response_code
            end
          end
          if request.verb == 'PUT'
            File.open(file, 'w') {|f| f.write("just created this file") }
            @client.puts "New file created: "
            @client.puts file
          end
          if request.verb == 'DELETE'
            File.delete(file)
            @client.puts "The following file was deleted: "
            @client.puts file
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
          if request.verb == 'PUT'
            File.open(file, 'w') {|f| f.write("just created this file") }
            @client.puts "New file created: "
            @client.puts file
          end
          if request.verb == 'DELETE'
            File.delete(file)
            @client.puts "The following file was deleted: "
            @client.puts file
          end
          if request.verb == 'GET'
            myfile = IO.readlines(file)
            if file
              response_code = 200
              @client.puts myfile
              puts response_code
            end
          end
          if request.verb == 'HEAD'
            begin
              myfile = IO.readlines(file)
              if file
                response_code = 200
                @client.puts response_code
                puts response_code
              end
            rescue
              myfile = IO.readlines("public_html/404.html")
              response_code = 404
              @client.puts myfile
              puts response_code
            end
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

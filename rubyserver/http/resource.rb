require_relative 'config'
# Resource

# This object will help us figure out where and what the requested resource is.

# methods: initialize(uri, httpd_conf, mime_types), resolve, mime_type, script?
class Resource
  attr_reader :request, :httpd_conf, :mime_types

  def initialize(request, httpd_conf, mime_types)
    @request = request
    @httpd_conf = httpd_conf
    @mime_types = mime_types
  end

  def resolve

    if @httpd_conf.script_alias(@request.uri) 
      @absolute_path = @httpd_conf.script_alias(@request.uri)

    elsif @httpd_conf.alias(@request.uri)
      @absolute_path = @httpd_conf.alias(@request.uri)

    else 
      @absolute_path = @httpd_conf.document_root() + @request.uri

    end

    if @request.extension != '' and @mime_types.for(@request.extension) != nil
      puts @mime_types.for(@request.extension)
      print @absolute_path, "\n"
      return @absolute_path
    end

    # if we have not returned yet, the URI is almost certainly a directory.
    index_to_append="" # default value
    directory_indexes = @httpd_conf.directory_indexes()
    directory_indexes.each do |directory_index|
      if(File.exist?(@absolute_path+directory_index))
        index_to_append=directory_index #adds the directory index
        break
      end
    end
    @absolute_path+=index_to_append
    print @absolute_path, "\n"

    # myfile = IO.readlines(@absolute_path)#read htmlfile
    #   #@session.puts(Time.now.ctime) # Send the time to the client
    # @session.puts myfile#post html
    return @absolute_path


  end
end


  

# # CODE TO SHOW HOW IT WORKS
# # suppose we get the request uri is parse and everything
# request = {}
# #case1 a pic
# request[:uri] = 'pictures/picture1.jpg' 
# request[:extension] = 'jpg'
# #case2 a alias
# # request[:uri] = '~things'
# # request[:extension] = ''
# #case3 a script alias
# # request[:uri] = 'cgi-bin'
# # request[:extension] = ''


# httpd_conf = HttpConfig.new(File.open("config/httpd.conf", "r").read())
# mime_types = MimeTypes.new(File.open("config/mime.types", "r").read()).load

# resource = Resource.new(request, httpd_conf, mime_types)
# resource.resolve


require_relative 'config'
# Resource

# This object will help us figure out where and what the requested resource is.

# methods: initialize(uri, httpd_conf, mime_types), resolve, mime_type, script?
class Resource
  attr_reader :request, :httpconf, :mimes
  #URI is supposed to be the parse request
  #http_conf

  def initialize(uri, httpd_conf, mime_types)
    @request = uri
    @httpconf = httpd_conf
    @mimes = mime_types
  end

  def resolve
    #check if the URI is alias (compare URI with the alias symbolic)
    if @httpconf.alias(@request.uri)
      @absolute_path = @httpconf.alias(@request.uri)
    #check if URI is Script alias (compare URI with the script alias symbolic)
    elsif @httpconf.script_alias(@request.uri) 
      @absolute_path = @httpconf.script_alias(@request.uri)
    else #if not any alias
      @absolute_path = @httpconf.document_root() + @request.uri
    end
    #is this a valid file from mime types?
    #if not we append the DirIndex; otherwise return absolute path 
    if @request.extension != '' and @mimes.for(@request.extension) != nil
      puts @mimes.for(@request.extension)
      print @absolute_path, "\n"
      return @absolute_path
    end

    # if we have not returned yet, the URI is almost certainly a directory.
    index_to_append="index.html" # default value
    directory_indexes = @httpconf.directory_indexes()
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


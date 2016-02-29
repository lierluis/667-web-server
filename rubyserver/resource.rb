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
  print @request[:uri], "\n"
  #Checking if the URI is alias
  if @request[:uri] == @httpconf.alias_sym() #compares uri with the alias symbolic
    @absolute_path = @httpconf.alias_abs()  
  #checking if the URI is Script alias
  elsif @request[:uri] == @httpconf.script_alias_sym()  #compares uri with the script alias symbolic
    @absolute_path = @httpconf.script_alias_abs() 
  else #if not any alias 
    @absolute_path = @httpconf.document_root() + @request[:uri] 
  end
  #is this a file a valid file from mime or if its not we append the DirIndex othewise return absolute path 
  if request[:extension] != '' and @mimes.for(@request[:extension]) != nil
    puts @mimes.for(@request[:extension])
    print @absolute_path, "\n"
    return @absolute_path
  end
  @index = @httpconf.directory_indexes().join
  @absolute_path += @index #adds the directory index 
  print @absolute_path, "\n"
end
end
# CODE TO SHOW HOW IT WORKS
# suppose we get the request uri is parse and everything
request = {}
#case1 a pic
request[:uri] = 'pictures/picture1.jpg' 
request[:extension] = 'jpg'
#case2 a alias
# request[:uri] = '~things'
# request[:extension] = ''
#case3 a script alias
# request[:uri] = 'cgi-bin'
# request[:extension] = ''


httpd_conf = HttpConfig.new(File.open("config/httpd.conf", "r").read())
mime_types = MimeTypes.new(File.open("config/mime.types", "r").read()).load

resource = Resource.new(request, httpd_conf, mime_types)
resource.resolve

<<<<<<< HEAD

=======
>>>>>>> e4310a1ec3e0c88dbf69a3e84ddf0af7230e640a

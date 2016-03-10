# records a single entry in the log file, in the apache common log format
class Logger
  attr_reader :file, :filepath
  
  def initialize(filepath)
    @filepath = filepath # log.txt
  end
  
  def write(request, response)
  	#sample still need to add 127.0.0.1 user-identifier frank 
  	#127.0.0.1 user-identifier frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326
  	File.open(@filepath, 'a') do |f|
  	f << Time.now << " "
  	f << "\"" << request.verb << " " <<request.uri << " " <<request.version << "\" "
  	f << response[:code] << " " << response[:phrase] << "\n"
	end
  end
end
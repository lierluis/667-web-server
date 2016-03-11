# records a single entry in the log file, in the apache common log format
class Logger
  attr_reader :file, :filepath
  
  def initialize(filepath)
    @filepath = filepath
    @file = File.open(@filepath, 'a')
  end
  
  def write(request, response)
  	remote_host = request.socket.addr.last
    remote_logname = "-" #TODO: check if IdentityCheck is enabled
    remote_user = "-" #TODO: get username if resource is password-protected
    time = Time.now
    request_line = "#{request.verb} #{request.uri} #{request.version}"
    status = response.response_code
    response_size = (response.body.bytesize > 0) ? response.body.bytesize : "-"
    
    log = "#{remote_host} #{remote_logname} #{remote_user} " +
          "[#{time}] \"#{request_line}\" #{status} #{response_size}\n"
    
    @file << log
  end
end
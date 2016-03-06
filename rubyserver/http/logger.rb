# records a single entry in the log file, in the apache common log format
class Logger
  attr_reader :file, :filepath
  
  def initialize(filepath)
    @filepath = filepath # log.txt
  end
  
  def write(request, response)
    
  end
end
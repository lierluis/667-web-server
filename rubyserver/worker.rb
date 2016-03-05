require File.join File.dirname(__FILE__), 'http/request'
require File.join File.dirname(__FILE__), 'http/response'
require File.join File.dirname(__FILE__), 'resource'
require File.join File.dirname(__FILE__), 'htaccess'
require File.join File.dirname(__FILE__), 'logger'

# responsible for handling a single request/response cycle, and logging it
class Worker
  attr_reader :client, :config, :logger
  
  def initialize(client, config)
    @client, @config = client, config
    @logger = Logger.new(@config.log_file)
  end
  
  def start
    
    request = Request.new(@client) # get request
    request.parse # parse client's HTTP request
    
    # resource...
    
    # response... (ResponseFactory handles responses)
    
  end
  
end

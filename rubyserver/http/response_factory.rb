require_relative 'config'
require_relative 'response'
OK = 200
CREATED = 201
NO_CONTENT = 204
UNAUTHORIZED = 401
BAD_REQUEST = 400
FORBIDDEN = 403
NOT_FOUND = 404



class ResponseFactory
  def self.create(request, resource)
    begin
    request.parse
    rescue
      html_not_found = IO.readlines(resource.config.document_root+
      @client.puts html_not_found
      puts NOT_FOUND
    end
  end
  private 

end

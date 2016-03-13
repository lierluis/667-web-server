require_relative 'config'

class ResponseFactory
  def self.create(request, resource, config)
    begin
    request.parse
    rescue
      not_found_file = IO.readlines(config.document_root)
      response_code = 400
      @client.puts myfile
      puts response_code
    end

  end
end

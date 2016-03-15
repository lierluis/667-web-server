require_relative 'config'
require_relative 'response'

OK = 200
CREATED = 201
NO_CONTENT = 204
UNAUTHORIZED = 401
BAD_REQUEST = 400
FORBIDDEN = 403
NOT_FOUND = 404
INTERNAL_ERROR = 500
REDIRECT_CODES=[NOT_FOUND, FORBIDDEN, BAD_REQUEST, UNAUTHORIZED]

class ResponseFactory

  def self.create(request, resource)

    config=resource.config
    mime_types=resource.mime_types

    # client=request.socket
    file_path = resource.resolve
    response_code, file=processRequest(file_path, request, config)

    if REDIRECT_CODES.include? response_code
      #process a request for the redirect page
      redirect_path=config.document_root+Response.toPath(response_code)
      throwaway_code, file=get(redirect_path)
    end

    response = Response.new(request, response_code, file, mime_types)

    return response, response.body

  end

  def self.processRequest(file, request, config)

    access_checker = HtaccessChecker.new(file,request.headers,config)

    if access_checker.protected?
      if access_checker.can_authorize?
        if access_checker.authorized?
          authorizedRequestFlow(file, request)
        else
          return self.forbidden
        end
      else
        self.unauthorized
      end
    else
      authorizedRequestFlow(file, request)
    end

  end

  def self.authorizedRequestFlow(file, request)

      if file.include? "cgi-bin"
          IO.popen([{'ENV_VAR' => 'value'},file]) {|io| io.read}
          return ok
      elsif request.verb == 'GET'
        return get(file)
      elsif request.verb == 'HEAD'
        #Return only the response code from the tuple created by 'get'
        return get(file)[0]
      elsif request.verb == 'PUT'
        return put(file)
      elsif request.verb == 'DELETE'
        return delete(file)
      end

  end

  def self.delete(file)

    if File.exist?(file)
      File.delete(file)
      return noContent
    else
      return notFound
    end

  end
  
  def self.put(file)
    begin
      File.open(file, 'w') {|f| f.write("File created via 'PUT'") }
      return created
    rescue
      return badRequest
    end

  end

  def self.get(file)

    begin
      if File.directory?(file)
        return notFound
      end
      retrieved_file=File.open(file, "rb")
      # retrieved_file = IO.readlines(file)
      if retrieved_file
        return ok, retrieved_file
      else
        return notFound
      end
    rescue
      return notFound
    end

  end

  def self.internalError
    return INTERNAL_ERROR
  end

  def self.forbidden
    return FORBIDDEN
  end

  def self.unauthorized
    return UNAUTHORIZED
  end

  def self.noContent
    return NO_CONTENT
  end

  def self.badRequest
    return BAD_REQUEST
  end

  def self.created
    return CREATED
  end

  def self.ok
    return OK
  end

  def self.notFound
    return NOT_FOUND
  end

end

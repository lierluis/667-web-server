require_relative 'config'
require_relative 'response'

OK = 200
CREATED = 201
NO_CONTENT = 204
UNAUTHORIZED = 401
BAD_REQUEST = 400
FORBIDDEN = 403
NOT_FOUND = 404
SCRIPT_RUN = 666
INTERNAL_ERROR = 500
REDIRECT_CODES=[NOT_FOUND, FORBIDDEN, BAD_REQUEST, UNAUTHORIZED]

class ResponseFactory

  def self.create(request, resource)

    config=resource.config
    mime_types=resource.mime_types

    file_path = resource.resolve
    response_code, file=processRequest(file_path, request, resource, config)

    if REDIRECT_CODES.include? response_code
      file=self.redirectFile(response_code, config)
    elsif response_code == SCRIPT_RUN
      return Response.new(nil, ok, file, mime_types, default=true)
    end
      

    response = Response.new(request, response_code, file, mime_types)

    return response

  end

  def self.processRequest(file, request, resource, config)

    access_checker = HtaccessChecker.new(file,request.headers,config)

    if access_checker.protected?
      if access_checker.can_authorize?
        if access_checker.authorized?
          authorizedRequestFlow(file, request, resource, config)
        else
          return self.forbidden
        end
      else
        self.unauthorized
      end
    else
      authorizedRequestFlow(file, request, resource, config)
    end

  end

  def self.authorizedRequestFlow(file, request, resource, config)
    if resource.is_script
      out = IO.popen([{'ENV_VAR' => 'value'},file])
      output_filename=config.document_root+'/tmp/out.html'
      File.open(output_filename , 'w') {|file| file.write(out.readlines.join)}
      script_out=File.open(output_filename, "rb")
      return SCRIPT_RUN, script_out
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

  def self.defaultRedirectResponse(code, config, mime_types)
    file = redirectFile(code, config)
    response = Response.new(nil, code, file, mime_types, default=true)
  end

  def self.redirectFile(code, config)
    return File.open(config.document_root+Response.toPath(code), "rb")
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

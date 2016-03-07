#Parent class to provide common config file parsing
class ConfigFile
  attr_reader :lines

  def initialize(str)
    @lines=str
  end

  # Return hash of key value pairs found in the multi-line string,
  # The key and value are separated by the first whitespace found in each line 
  def load()
    parsedData = Hash.new()
    @lines.each_line do |line|
      if self.valid_line?(line)
        lineSplit=line.split(' ', 2) #split into max two parts
        parsedData[lineSplit[0]] = self.remove_quotes(lineSplit[1])
      end
    end
    return parsedData
  end

  def valid_line?(line)
    if line.tr(' ', '').start_with? '#' or 
      line.start_with? "\n" or
      line.split.length == 0
      return false
    end
    return true
  end

  def remove_quotes(str)
    return str.tr('"',"")
  end

end


class MimeTypes < ConfigFile
  attr_reader :mime_types

  # Take the keys from @lines as @mime_type values (valid mime extensions)
  # Take the values from @lines as @mime_type keys
  # Split the @lines values into multiple extensions delimited by white space
  def process_lines(line_hash)
    @mime_types=Hash.new()
    line_hash.each do |mime_type, mime_extensions|
      mime_extensions.split(' ').each do |mime_extension|
        @mime_types[mime_extension]=mime_type
      end
    end
  end

  # Override load() on superclass and add call to process_lines
  def load()
    line_hash=super
    self.process_lines(line_hash)
    return self
  end

  def for(extension)
    return @mime_types[extension]
  end

end

class HttpConfig < ConfigFile
  attr_reader :config

  def initialize(str)
    super
    self.process_lines()
  end

  def process_lines()
    @config=Hash.new("")
    line_hash=load() #retrieves hash of the multi-line string
    @config['ScriptAlias']=Hash.new() # Multiple ScriptAliases/Aliases may exist
    @config['Alias']=Hash.new()
    @config['DirectoryIndex']=Array.new() # Multiple DirectoryIndexes may exist
    line_hash.each do |config_option, config_values|
      if(config_option=='ScriptAlias') #Store all values in nested Hash
        config_values=config_values.split(' ')
        @config['ScriptAlias'][config_values[0]]=config_values[1].strip()
      elsif(config_option=='Alias') #Store all Alias values in one nested hash
        config_values=config_values.split(' ')
        @config['Alias'][config_values[0]]=config_values[1].strip()
      elsif(config_option=='DirectoryIndex')
        config_values.split(' ').each_with_index do |value, iteration|
          @config['DirectoryIndex'][iteration]=value.strip()
        end
      else
        @config[config_option]=config_values.strip()
      end
    end
  end

  def server_root()
    return @config['ServerRoot']
  end

  def document_root()
    return @config['DocumentRoot']
  end

  def listen()
    return @config['Listen']
  end

  def log_file()
    return @config['LogFile']
  end

  def alias_sym()
    return @config['Alias']
  end

  def alias_abs()
    return @config['Alias']
  end

  def alias(path)
    return @config['Alias'][path]
  end

  def script_alias(path)
    return @config['ScriptAlias'][path]
  end

  def access_file_name()
    return @config['AccessFileName']
  end

  def directory_indexes()
    return @config['DirectoryIndex']
  end
end

# Here's some code to illustrate how this works!
# mimes=MimeTypes.new(File.open("config/mime.types", "r").read()).load
# mimes.mime_types.each do |k,v|
#   print k, " : ",v, "\n"
# end
# puts mimes.for('h261')

# httpd_conf=HttpConfig.new(File.open("../config/httpd.conf", "r").read())
# print "Server Root: ", httpd_conf.server_root(),"\n"
# print "Document Root: ", httpd_conf.document_root(),"\n"
# print "Listen: ", httpd_conf.listen(),"\n"
# print "Log File: ",httpd_conf.log_file(),"\n"


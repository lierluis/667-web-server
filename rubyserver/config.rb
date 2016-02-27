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


end

## Here's some code to illustrate how this works!
configFile=MimeTypes.new(File.open("config/mime.types", "r").read()).load
configFile.mime_types.each do |k,v|
  print k, " : ",v, "\n"
end
puts configFile.for('h261')
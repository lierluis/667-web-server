#Parent class to provide common config file parsing
class ConfigFile

  attr_reader :lines

  def initialize(str)
    @lines=self.load(str)
  end

  # Return hash of key value pairs found in the multi-line string,
  # The key and value are separated by the first whitespace found in each line 
  def load(str)
    parsedData = Hash.new()
    str.each_line do |line|
      if self.validLine?(line)
        lineSplit=line.split(' ', 2)
        parsedData[lineSplit[0]] = self.removeQuotes(lineSplit[1])
      end
    end
    return parsedData
  end

  def validLine?(line)
    if line.start_with? "#" or 
      line.start_with? "\n"
      return false
    end
    return true
  end

  def removeQuotes(str)
    return str.tr('"',"")
  end

end


class MimeTypes < ConfigFile
  attr_accessor :mime_types

end

class HttpConfig < ConfigFile


end

configFile=ConfigFile.new(File.open("config/mime.types", "r").read())
configFile.lines.each do |k,v|
  print k, " : ",v, "\n"
end
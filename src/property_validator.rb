require File.dirname(__FILE__) + '/rappa_error'

class PropertyValidator

  def initialize(config,file)
    @config = config
    @file = file
  end

  def input_directory
    unless @config[:input_directory].nil?
      @config[:file_name] = (@config[:input_directory] == '.') ? 'default' : @file.basename(@config[:input_directory])
    end
    check_property(@config[:input_directory], :input_directory)
    input_directory = append_trailing_slash(@config[:input_directory])
    raise RappaError, "input directory: #{input_directory} does not exist" unless @file.exists?(input_directory)
    input_directory
  end

  def output_directory
    check_property(@config[:output_directory], :output_directory)
    @config[:output_directory]
  end

  def input_archive
    check_property(@config[:input_archive], :input_archive)
    input_archive = @config[:input_archive]
    raise RappaError, "input archive: #{@config[:input_archive]} does not exist" unless @file.exists?(@config[:input_archive])
    input_archive
  end

  def output_archive
    check_property(@config[:output_archive], :output_archive)
    @config[:output_archive]
  end

  def input_rap
    check_property(@config[:input_rap], :input_rap)
    @config[:input_rap]
  end

  def url
    check_property(@config[:url], :url)
    @config[:url]
  end

  def api_key
    check_property(@config[:api_key], :api_key)
    @config[:api_key]
  end


  def validate_name(name)
    raise RappaError, "a rap archive already exists with the name: #{@config[:file_name]}.rap - please remove it and try again" if @file.exists?(name)
  end

  private

  def check_property(property, property_type)
    raise RappaError, "property #{property_type} is mandatory but was not supplied" if property.nil? or property.empty?
  end

  def append_trailing_slash(path)
    path = "#{path}/" if path[-1] != '/'
    path
  end

end
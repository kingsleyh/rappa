require File.dirname(__FILE__) + '/rappa_error'

class RapValidator

  SUPPORTED_SERVERS = %w(thin unicorn webrick)

  def initialize(file)
    @file = file
  end

  def validate_package(directory)
    @rap = get_rap_file(directory + '/rap.yml')
    validate_server_type
    validate_scripts
    validate_details
  end

  def validate_details
    raise RappaError, 'rap.yml :pids is required' if @rap[:pids].nil? or @rap[:pids].empty?
    raise RappaError, 'rap.yml :name is required' if @rap[:name].nil? or @rap[:name].empty?
    raise RappaError, 'rap.yml :description is required' if @rap[:description].nil? or @rap[:description].empty?
    raise RappaError, 'rap.yml :version is required' if @rap[:version].nil? or @rap[:version].empty?
  end

  def validate_scripts
    raise RappaError, 'rap.yml :start_script is required' if @rap[:start_script].nil? or @rap[:start_script].empty?
    raise RappaError, 'rap.yml :stop_script is required' if @rap[:stop_script].nil? or @rap[:stop_script].empty?
  end

  def validate_server_type
    raise RappaError, "rap.yml :server_type is required and must be one of: #{SUPPORTED_SERVERS}" if @rap[:server_type].nil? or @rap[:server_type].empty?
    raise RappaError, "rap.yml :server_type supplied: #{@rap[:server_type]} is not in the supported server list: #{SUPPORTED_SERVERS}" unless SUPPORTED_SERVERS.include?(@rap[:server_type])
  end

  def self.validate_is_rap_archive(file, config)
    base_name = file.basename(config[:input_archive])
    extension = file.extname(base_name)
    raise RappaError, "input archive: #{config[:input_archive]} is not a valid .rap archive" unless extension == '.rap'
  end

  private

  def get_rap_file(rap_file_path)
    if @file.exists?(rap_file_path)
      YAML.load_file(rap_file_path)
    else
      raise RappaError, 'rap.yml file is required - please run rappa generate to create a sample rap.yml'
    end
  end

end
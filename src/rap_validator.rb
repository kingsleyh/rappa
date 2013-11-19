require File.dirname(__FILE__) + '/rappa_error'

class RapValidator

  SUPPORTED_SERVERS = %w(thin unicorn webrick)

  def initialize(file,yaml=YAML)
    @file = file
    @yaml = yaml
  end

  def validate_package(directory)
    @rap = get_rap_file(directory + '/rap.yml')
    validate_server_type
    validate_scripts
    validate_details
  end

  def validate_is_rap_archive(file, input_archive)
    base_name = file.basename(input_archive)
    extension = file.extname(base_name)
    raise RappaError, "input archive: #{input_archive} is not a valid .rap archive" unless extension == '.rap'
  end

  def validate_is_zip_archive(file, input_archive)
    base_name = file.basename(input_archive)
    extension = file.extname(base_name)
    raise RappaError, "input archive: #{input_archive} is not a valid .zip archive" unless extension == '.zip'
  end

  private

  def validate_details
    raise RappaError, 'rap.yml :pids is required' if nil_or_empty?(@rap[:pids])
    raise RappaError, 'rap.yml :name is required' if nil_or_empty?(@rap[:name])
    raise RappaError, 'rap.yml :description is required' if nil_or_empty?(@rap[:description])
    raise RappaError, 'rap.yml :version is required' if nil_or_empty?(@rap[:version])
  end

  def validate_scripts
    raise RappaError, 'rap.yml :start_script is required' if nil_or_empty?(@rap[:start_script])
    raise RappaError, 'rap.yml :stop_script is required' if nil_or_empty?(@rap[:stop_script])
  end

  def validate_server_type
    raise RappaError, "rap.yml :server_type is required and must be one of: #{SUPPORTED_SERVERS}" if nil_or_empty?(@rap[:server_type])
    raise RappaError, "rap.yml :server_type supplied: #{@rap[:server_type]} is not in the supported server list: #{SUPPORTED_SERVERS}" unless SUPPORTED_SERVERS.include?(@rap[:server_type])
  end

  def get_rap_file(rap_file_path)
    if @file.exists?(rap_file_path)
      @yaml.load_file(rap_file_path)
    else
      raise RappaError, 'rap.yml file is required - please run rappa generate to create a sample rap.yml'
    end
  end

  def nil_or_empty?(item)
    item.nil? or item.empty?
  end

end
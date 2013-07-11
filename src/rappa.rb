require 'zip/zip'
require 'fileutils'
require 'yaml'
require 'rest-client'
require File.dirname(__FILE__) + '/rap_validator'
require File.dirname(__FILE__) + '/property_validator'

class Rappa

  def initialize(config={}, rest_client=RestClient, file=File, rap_validator=RapValidator, property_validator=PropertyValidator)
    @config = config
    @file = file
    @rest_client = rest_client
    @property_validator= property_validator.new(@config,@file)
    @rap_validator = rap_validator.new(@file)
  end

  def package
    output_directory = @property_validator.output_directory
    FileUtils.mkdir_p output_directory unless @file.exists?(output_directory)
    name = "#{output_directory}/#{@config[:file_name]}.rap"
    @property_validator.validate_name(name)
    @rap_validator.validate_package(@property_validator.input_directory)
    package_zip(@property_validator.input_directory, name)
  end

  def expand
    @rap_validator.validate_is_rap_archive(@file,@config)
    @property_validator.output_archive
    FileUtils.mkdir_p output_directory unless @file.exists?(output_directory)
    expand_zip
  end

  def deploy
    @rest_client.put "#{@property_validator.url}?key=#{ @property_validator.api_key}", :file => @file.new(@property_validator.input_rap)
  end

  def generate
    sample = {:server_type => 'thin', :start_script => 'start.sh', :stop_script => 'stop.sh', :pids => 'tmp/pids', :name => 'App Name', :description => 'App Description'}
    @file.open('sample.rap.yml', 'w') { |f| f.puts sample.to_yaml }
  end

  protected

  def install
    expand
    validate(calculate_destination)
  end

  private

  def expand_zip
    Zip::ZipFile.open(@config[:input_archive]) { |zip_file|
      zip_file.each { |f|
        f_path=@file.join(calculate_destination, f.name)
        FileUtils.mkdir_p(@file.dirname(f_path))
        zip_file.extract(f, f_path) { true } unless @file.exist?(f_path) # true will overwrite existing files.
      }
    }
  end

  def package_zip(input_directory, name)
    Zip::ZipFile.open(name, Zip::ZipFile::CREATE) do |zip_file|
      Dir[@file.join(input_directory, '**', '**')].each do |file|
        zip_file.add(file.sub(input_directory, ''), file)
      end
    end
  end

  def calculate_destination
    base_name = @file.basename(@config[:input_archive])
    name = base_name.chomp(@file.extname(base_name))
    @config[:output_archive] + '/' + name
  end



end

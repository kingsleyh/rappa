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
    @property_validator= property_validator.new(@config, @file)
    @rap_validator = rap_validator.new(@file)
  end

  def package
    input_directory = @property_validator.input_directory
    output_directory = @property_validator.output_directory
    FileUtils.mkdir_p output_directory unless @file.exists?(output_directory)
    name = "#{output_directory}/#{@config[:file_name]}.rap"
    @property_validator.validate_name(name)
    @rap_validator.validate_package(input_directory)
    package_zip(input_directory, name)
  end

  def expand
    input_archive = @property_validator.input_archive
    output_directory = @property_validator.output_archive
    @rap_validator.validate_is_rap_archive(@file, input_archive)
    FileUtils.mkdir_p output_directory unless @file.exists?(output_directory)
    expand_zip
  end

  def deploy
    input_rap = @property_validator.input_rap
    api_key = @property_validator.api_key
    url = @property_validator.url
    @rap_validator.validate_is_rap_archive(@file, input_rap)
    @rest_client.put "#{url}?key=#{ api_key}", :file => @file.new(input_rap)
  end

  def standalone_package
    input_directory = @property_validator.input_directory
    output_directory = @property_validator.output_directory
    FileUtils.mkdir_p output_directory unless @file.exists?(output_directory)
    name = "#{output_directory}/#{@config[:file_name]}.zip"
    @property_validator.validate_name(name)
    package_zip(input_directory, name)
  end

  def standalone_expand
    input_archive = @property_validator.input_archive
    output_directory = @property_validator.output_archive
    @rap_validator.validate_is_zip_archive(@file, input_archive)
    FileUtils.mkdir_p output_directory unless @file.exists?(output_directory)
    expand_zip
  end

  def standalone_deploy
    input_zip = @property_validator.input_zip
    api_key = @property_validator.api_key
    url = @property_validator.url
    @rap_validator.validate_is_zip_archive(@file, input_zip)
    @rest_client.put "#{url}?key=#{ api_key}", :file => @file.new(input_zip)
  end

  def generate
    sample = {:name => 'App Name', :description => 'App Description', :version => '1', :server_type => 'thin', :start_script => 'start.sh', :stop_script => 'stop.sh', :pids => 'tmp/pids', :bootstrap => 'bootstrap.sh'}
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
      glob = Dir[@file.join(input_directory, '**', '**')]
      @property_validator.excludes.each { |ex| glob.reject! { |f| f[input_directory + ex] } }
      glob.each do |file|
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

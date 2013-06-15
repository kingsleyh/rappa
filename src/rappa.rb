require 'zip/zip'
require 'fileutils'
require 'yaml'

class Rappa

  SUPPORTED_SERVERS = %w(thin unicorn webrick)

  def initialize(config={})
    @config = config
    @config[:file_name] = File.basename(@config[:input_directory]) unless @config[:input_directory].nil?
    p @config
  end

  def package
    input_directory = append_trailing_slash(@config[:input_directory])
    raise Exception, "input directory: #{input_directory} does not exist" unless File.exists?(input_directory)
    output_directory = @config[:output_directory]
    raise Exception, "output directory: #{output_directory} does not exist" unless File.exists?(output_directory)
    name = "#{@config[:output_directory]}/#{@config[:file_name]}.rap"
    validate(input_directory)
    Zip::ZipFile.open(name, Zip::ZipFile::CREATE) do |zip_file|
      Dir[File.join(input_directory, '**', '**')].each do |file|
        zip_file.add(file.sub(input_directory, ''), file)
      end
    end
  end

  def expand
    calculate_destination
    raise Exception, "input directory: #{@config[:input_archive]} does not exist" unless File.exists?(@config[:input_archive])
    raise Exception, "output directory: #{@config[:output_archive]} does not exist" unless File.exists?(@config[:output_archive])
    Zip::ZipFile.open(@config[:input_archive]) { |zip_file|
      zip_file.each { |f|
        f_path=File.join(destination, f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(f, f_path) { true } unless File.exist?(f_path) # true will overwrite existing files.
      }
    }
  end

  def generate
    sample = {:server_type => 'thin', :start_script => './start.sh', :stop_script => './stop.sh'}
    File.open("sample.rap.yml", "w") { |f| f.puts sample.to_yaml }
  end

  protected

  def install
    expand
    validate(calculate_destination)
  end

  private

  def validate(directory)
    rap_file = directory + '/rap.yml'
    if File.exists?(rap_file)
      rap = YAML.load_file(rap_file)
      raise Exception, ":server_type is required and must be on of: #{SUPPORTED_SERVERS}" if rap[:server_type].nil? or rap[:server_type].empty?
      raise Exception, ":server_type supplied: #{rap[:server_type]} is not in the supported server list: #{SUPPORTED_SERVERS}" unless SUPPORTED_SERVERS.include?(rap[:server_type])
      raise Exception, ':start_script is required' if rap[:start_script].nil? or rap[:start_type].empty?
      raise Exception, ':stop_script is required' if rap[:stop_script].nil? or rap[:stop_type].empty?
    else
      raise Exception, 'rap.yml file is required - please run rappa generate to create a sample rap.yml'
    end
  end

  def calculate_destination
    base_name = File.basename(@config[:input_archive])
    name = base_name.chomp(File.extname(base_name))
    @config[:output_archive] + '/' + name
  end

  def append_trailing_slash(path)
    "#{path}/" if path[-1] != "/"
  end

end
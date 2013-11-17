require 'rspec'
require 'fileutils'
require File.dirname(File.expand_path(__FILE__)) + '/../src/rappa'

describe "Rappa" do

  before(:each) do
    @generated = File.dirname(File.expand_path(__FILE__)) + '/generated'
    FileUtils.rm_rf(@generated) if File.exists?(@generated)
    Dir.mkdir(@generated)
  end

  it 'should create an archive of the current directory in the correct rap format with a rap deployment config file when calling package' do
    make_fake_project
    Rappa.new(:input_directory => "#{@generated}/test_rap/", :output_directory => @generated).package
    assert_file_exists("#{@generated}/test_rap.rap")
    Rappa.new(:input_archive => "#{@generated}/test_rap.rap", :output_archive => @generated + '/output').expand
    assert_expanded_archive
  end

  it 'should raise an exception if package is not passed a valid input directory' do
    expect { Rappa.new(:input_directory => 'missing', :output_directory => 'anything').package }.to raise_error(RappaError, 'input directory: missing/ does not exist')
  end

  it 'should raise an exception if expand is not passed a valid input file' do
    expect { Rappa.new(:input_archive => 'missing', :output_archive => 'anything').expand }.to raise_error(RappaError, 'input archive: missing does not exist')
  end

  it 'should raise exception on package if :input_directory or :output_directory properties are not supplied' do
    make_fake_project
    expect { Rappa.new(:output_directory => 'anything').package }.to raise_error(RappaError, 'property input_directory is mandatory but was not supplied')
    expect { Rappa.new(:input_directory => "#{@generated}/test_rap/").package }.to raise_error(RappaError, 'property output_directory is mandatory but was not supplied')
  end

  it 'should raise exception on expand if :input_archive or :output_archive properties are not supplied' do
    make_fake_project
    make_fake_rap
    expect { Rappa.new(:output_archive => 'anything').expand }.to raise_error(RappaError, 'property input_archive is mandatory but was not supplied')
    expect { Rappa.new(:input_archive => "#{@generated}/test_rap/test_rap.rap").expand }.to raise_error(RappaError, 'property output_archive is mandatory but was not supplied')
  end

  it 'should raise an exception on expand if :input_archive is not a valid .rap file' do
    make_fake_project
    expect { Rappa.new(:input_archive => 'spec/generated', :output_archive => @generated + '/output').expand }.to raise_error(RappaError, 'input archive: spec/generated is not a valid .rap archive')
  end

  it 'should raise an exception on package if archive with same name already exists' do
    make_fake_project
    Rappa.new(:input_directory => "#{@generated}/test_rap/", :output_directory => @generated).package
    expect { Rappa.new(:input_directory => "#{@generated}/test_rap/", :output_directory => @generated).package }.to raise_error(RappaError, 'a rap archive already exists with the name: test_rap.rap - please remove it and try again')
  end

  it 'should raise an exception when excludes property is specified but the value supplied is not an array' do
    make_fake_project
    expect { Rappa.new(:input_directory => "#{@generated}/test_rap/", :output_directory => @generated, :excludes => 'excluded_file').package }.to raise_error(RappaError, "property: excludes is optional but requires an array of files/folders to exclude e.g excludes: ['folder1','file1.txt']")
  end

  it 'should exclude specified files and folders from the rap package when excludes property is specified' do
    make_fake_project
    Rappa.new(:input_directory => "#{@generated}/test_rap/", :output_directory => @generated, :excludes => ['test_1.txt', 'nested']).package
    assert_file_exists("#{@generated}/test_rap.rap")
    Rappa.new(:input_archive => "#{@generated}/test_rap.rap", :output_archive => @generated + '/output').expand

    #should not be present
    %W(#{@generated}/output/test_rap/test_1.txt #{@generated}/output/test_rap/nested #{@generated}/output/test_rap/nested/test_2.txt).each do |path|
      File.exists?(path).should == false
    end

    #should be present
    %W(#{@generated}/output/test_rap).each do |path|
      File.exists?(path).should == true
    end

  end

  it 'should raise an exception on package if rap.yml is missing' do
    make_fake_project(false)
    expect { Rappa.new(:input_directory => "#{@generated}/test_rap/", :output_directory => @generated).package }.to raise_error(RappaError, 'rap.yml file is required - please run rappa generate to create a sample rap.yml')
  end

  it 'should raise an exception on package if rap.yml is missing :server_type' do
    make_fake_project(true, {:start_script => 'start.sh', :stop_script => 'stop.sh'})
    expect { Rappa.new(:input_directory => "#{@generated}/test_rap/", :output_directory => @generated).package }.to raise_error(RappaError, 'rap.yml :server_type is required and must be one of: ["thin", "unicorn", "webrick"]')
  end

  it 'should raise an exception on package if rap.yml contains an unsupported :server_type' do
    make_fake_project(true, {:server_type => 'unsupported', :start_script => 'start.sh', :stop_script => 'stop.sh'})
    expect { Rappa.new(:input_directory => "#{@generated}/test_rap/", :output_directory => @generated).package }.to raise_error(RappaError, 'rap.yml :server_type supplied: unsupported is not in the supported server list: ["thin", "unicorn", "webrick"]')
  end

  it 'should raise an exception on package if rap.yml is missing :start_script' do
    make_fake_project(true, {:server_type => 'thin', :stop_script => 'stop.sh'})
    expect { Rappa.new(:input_directory => "#{@generated}/test_rap/", :output_directory => @generated).package }.to raise_error(RappaError, 'rap.yml :start_script is required')
  end

  it 'should raise an exception on package if rap.yml is missing :stop_script' do
    make_fake_project(true, {:server_type => 'thin', :start_script => 'start.sh'})
    expect { Rappa.new(:input_directory => "#{@generated}/test_rap/", :output_directory => @generated).package }.to raise_error(RappaError, 'rap.yml :stop_script is required')
  end

  it 'should raise an exception on package if rap.yml is missing :pids' do
    make_fake_project(true, {:server_type => 'thin', :start_script => 'start.sh', :stop_script => 'stop.sh'})
    expect { Rappa.new(:input_directory => "#{@generated}/test_rap/", :output_directory => @generated).package }.to raise_error(RappaError, 'rap.yml :pids is required')
  end

  it 'should raise an exception on package if rap.yml is missing :name' do
    make_fake_project(true, {:server_type => 'thin', :start_script => 'start.sh', :stop_script => 'stop.sh', :pids => 'tmp/pids'})
    expect { Rappa.new(:input_directory => "#{@generated}/test_rap/", :output_directory => @generated).package }.to raise_error(RappaError, 'rap.yml :name is required')
  end

  it 'should raise an exception on package if rap.yml is missing :description' do
    make_fake_project(true, {:server_type => 'thin', :start_script => 'start.sh', :stop_script => 'stop.sh', :pids => 'tmp/pids', :name => 'Cool'})
    expect { Rappa.new(:input_directory => "#{@generated}/test_rap/", :output_directory => @generated).package }.to raise_error(RappaError, 'rap.yml :description is required')
  end

  it 'should raise an exception on package if rap.yml is missing :version' do
    make_fake_project(true, {:server_type => 'thin', :start_script => 'start.sh', :stop_script => 'stop.sh', :pids => 'tmp/pids', :name => 'Cool', :description => 'description'})
    expect { Rappa.new(:input_directory => "#{@generated}/test_rap/", :output_directory => @generated).package }.to raise_error(RappaError, 'rap.yml :version is required')
  end

  it 'is should deploy to target thundercat server' do
    make_fake_project
    rest_client = double('RestClient')
    file = double('File')
    file_instance = double('FileInstance')
    Rappa.new(:input_directory => "#{@generated}/test_rap/", :output_directory => @generated).package
    rest_client.should_receive(:put).with('http://localhost:8089/api/deploy?key=api_key', {:file => file_instance})
    file.should_receive(:new).and_return(file_instance)
    file.should_receive(:exists?).with(file_instance).and_return(true)
    file_instance.should_receive(:empty?).and_return(false)
    Rappa.new({:input_rap => file_instance, :url => 'http://localhost:8089/api/deploy', :api_key => 'api_key'}, rest_client, file).deploy
  end

  it 'should raise exception on deploy if :input_rap or :api_key or :url properties are not supplied' do
    make_fake_project
    make_fake_rap
    expect { Rappa.new(:api_key => 'anything', :url => 'anything').deploy }.to raise_error(RappaError, 'property input_rap is mandatory but was not supplied')
    expect { Rappa.new(:input_rap => "#{@generated}/test_rap/test_rap.rap", :api_key => 'anything').deploy }.to raise_error(RappaError, 'property url is mandatory but was not supplied')
    expect { Rappa.new(:input_rap => "#{@generated}/test_rap/test_rap.rap", :url => 'anything').deploy }.to raise_error(RappaError, 'property api_key is mandatory but was not supplied')
  end

  it 'should create a package called default.rap if package is called with .' do
    FileUtils.chdir('spec')
    Rappa.new(:input_directory => ".", :output_directory => @generated).package
    assert_file_exists("#{@generated}/default.rap")
  end

  def assert_expanded_archive
    %W(#{@generated}/output/test_rap/test_1.txt #{@generated}/output/test_rap/nested #{@generated}/output/test_rap/nested/test_2.txt).each do |path|
      assert_file_exists(path)
    end
  end

  def assert_file_exists(file)
    File.exists?(file).should == true
  end

  def make_fake_project(rap=true, rap_config={:server_type => 'thin', :start_script => 'start.sh', :stop_script => 'stop.sh', :pids => 'tmp/pids', :name => 'Cool', :description => 'Cool App', :version => '0.0.1'})
    project_path = "#{@generated}/test_rap"
    Dir.mkdir(project_path)
    Dir.mkdir(project_path + '/nested')
    File.open("#{@generated}/test_rap/test_1.txt", "w") { |f| f.puts 'This is test_1.txt' }
    File.open("#{@generated}/test_rap/nested/test_2.txt", "w") { |f| f.puts 'This is test_2.txt' }
    make_rap_yml(rap_config) if rap
  end

  def make_rap_yml(rap_config)
    File.open("#{@generated}/test_rap/rap.yml", 'w') { |f| f.puts rap_config.to_yaml }
  end

  def make_fake_rap
    File.open("#{@generated}/test_rap/test_rap.rap", "w") { |f| f.puts 'test rap' }
  end

end
require 'rspec'
require 'fileutils'
require File.dirname(File.expand_path(__FILE__)) + '/../src/rap_validator'

describe 'RapValidator' do

  it 'should validate package (success)' do
    file = double('File')
    yaml = double('YAML')
    file.should_receive(:exists?).with('/some/directory/rap.yml').and_return(true)

    rap = {
        :name => 'Cool',
        :version => '0.0.1',
        :description => 'Cool App',
        :server_type => 'thin',
        :start_script => 'start.sh',
        :stop_script => 'stop.sh',
        :pids => 'tmp/pids',
        :bootstrap => 'bootstrap.sh'
    }

    yaml.should_receive(:load_file).with('/some/directory/rap.yml').and_return(rap)
    rap_validator = RapValidator.new(file, yaml)
    rap_validator.validate_package('/some/directory').should == nil
  end

  it 'should validate package (name)' do
    rap = {
        :version => '0.0.1',
        :description => 'Cool App',
        :server_type => 'thin',
        :start_script => 'start.sh',
        :stop_script => 'stop.sh',
        :pids => 'tmp/pids',
        :bootstrap => 'bootstrap.sh'
    }
    assert_package_error(rap, :name)
  end

  it 'should validate package (version)' do
    rap = {
        :name => 'Cool',
        :description => 'Cool App',
        :server_type => 'thin',
        :start_script => 'start.sh',
        :stop_script => 'stop.sh',
        :pids => 'tmp/pids',
        :bootstrap => 'bootstrap.sh'
    }
    assert_package_error(rap, :version)
  end

  it 'should validate package (description)' do
    rap = {
        :name => 'Cool',
        :version => '0.0.1',
        :server_type => 'thin',
        :start_script => 'start.sh',
        :stop_script => 'stop.sh',
        :pids => 'tmp/pids',
        :bootstrap => 'bootstrap.sh'
    }
    assert_package_error(rap, :description)
  end

  it 'should validate package (server_type)' do
    rap = {
        :name => 'Cool',
        :version => '0.0.1',
        :description => 'Cool App',
        :start_script => 'start.sh',
        :stop_script => 'stop.sh',
        :pids => 'tmp/pids',
        :bootstrap => 'bootstrap.sh'
    }
    assert_server_type(rap, ':server_type is required and must be one of: ["thin", "unicorn", "webrick"]')
  end

  it 'should validate package (server_type unknown)' do
    rap = {
        :name => 'Cool',
        :version => '0.0.1',
        :server_type => 'unknown',
        :description => 'Cool App',
        :start_script => 'start.sh',
        :stop_script => 'stop.sh',
        :pids => 'tmp/pids',
        :bootstrap => 'bootstrap.sh'
    }
    assert_server_type(rap, ':server_type supplied: unknown is not in the supported server list: ["thin", "unicorn", "webrick"]')
  end

  it 'should validate package (start_script)' do
    rap = {
        :name => 'Cool',
        :version => '0.0.1',
        :description => 'Cool App',
        :server_type => 'thin',
        :stop_script => 'stop.sh',
        :pids => 'tmp/pids',
        :bootstrap => 'bootstrap.sh'
    }
    assert_package_error(rap, :start_script)
  end

  it 'should validate package (stop_script)' do
    rap = {
        :name => 'Cool',
        :version => '0.0.1',
        :description => 'Cool App',
        :server_type => 'thin',
        :start_script => 'start.sh',
        :pids => 'tmp/pids',
        :bootstrap => 'bootstrap.sh'
    }
    assert_package_error(rap, :stop_script)
  end

  it 'should validate package (pids)' do
    rap = {
        :name => 'Cool',
        :version => '0.0.1',
        :description => 'Cool App',
        :server_type => 'thin',
        :start_script => 'start.sh',
        :stop_script => 'stop.sh',
        :bootstrap => 'bootstrap.sh'
    }
    assert_package_error(rap, :pids)
  end

  it 'should raise an error if no rap file supplied' do
    file = double('File')
    yaml = double('YAML')
    file.should_receive(:exists?).with('/some/directory/rap.yml').and_return(false)
    rap_validator = RapValidator.new(file, yaml)
    expect { rap_validator.validate_package('/some/directory') }.to raise_error(RappaError, 'rap.yml file is required - please run rappa generate to create a sample rap.yml')
  end

  it 'should validate_is_rap_archive (Success)' do
    assert_valid_archive(:rap)
  end

  it 'should validate_is_rap_archive (Not a Rap)' do
    assert_invalid_archive(:rap)
  end

  it 'should validate_is_zip_archive (Success)' do
    assert_valid_archive(:zip)
  end

  it 'should validate_is_zip_archive (Not a Zip)' do
    assert_invalid_archive(:zip)
  end

  def assert_server_type(rap, message)
    rap_validator = rap_validation(rap)
    expect { rap_validator.validate_package('/some/directory') }.to raise_error(RappaError, "rap.yml #{message}")
  end

  def assert_package_error(rap, message)
    rap_validator = rap_validation(rap)
    expect { rap_validator.validate_package('/some/directory') }.to raise_error(RappaError, "rap.yml :#{message} is required")
  end

  def rap_validation(rap)
    file = double('File')
    yaml = double('YAML')
    file.should_receive(:exists?).with('/some/directory/rap.yml').and_return(true)
    yaml.should_receive(:load_file).with('/some/directory/rap.yml').and_return(rap)
    RapValidator.new(file, yaml)
  end

  private

  def assert_valid_archive(archive_type)
    archive_type = archive_type.to_s
    file = double('File')
    yaml = double('YAML')
    file.should_receive(:basename).with('/some/directory/some.'+archive_type).and_return('some.'+archive_type)
    file.should_receive(:extname).with('some.'+archive_type).and_return('.'+archive_type)
    rap_validator = RapValidator.new(file, yaml)
    rap_validator.send("validate_is_#{archive_type}_archive", file, '/some/directory/some.'+archive_type).should == nil
  end

  def assert_invalid_archive(archive_type)
    archive_type = archive_type.to_s
    file = double('File')
    yaml = double('YAML')
    file.should_receive(:basename).with('/some/directory/some.'+archive_type).and_return('some.'+archive_type)
    file.should_receive(:extname).with('some.'+archive_type).and_return('.pap')
    rap_validator = RapValidator.new(file, yaml)
    expect { rap_validator.send("validate_is_#{archive_type}_archive", file, '/some/directory/some.'+archive_type) }.to raise_error("input archive: /some/directory/some.#{archive_type} is not a valid .#{archive_type} archive")
  end


end
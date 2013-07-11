require 'rspec'
require 'fileutils'
require File.dirname(File.expand_path(__FILE__)) + '/../src/property_validator'

describe 'PropertyValidator' do

  it 'should return input directory when supplied an existing input directory' do
    config = {:input_directory => '/somewhere/cool'}
    file = double('File')
    file.should_receive(:basename).with('/somewhere/cool').and_return('/cool')
    file.should_receive(:exists?).with('/somewhere/cool/').and_return(true)
    property_validator = PropertyValidator.new(config, file)
    property_validator.input_directory.should == '/somewhere/cool/'
  end

  it 'should return input directory when supplied with a . for current directory' do
    config = {:input_directory => '.'}
    file = double('File')
    file.should_receive(:exists?).with('./').and_return(true)
    property_validator = PropertyValidator.new(config, file)
    property_validator.input_directory.should == './'
    config[:file_name].should == 'default'
  end

  it 'should raise error on non existing input directory' do
    config = {:input_directory => '/somewhere/cool'}
    file = double('File')
    file.should_receive(:basename).with('/somewhere/cool').and_return('/cool')
    file.should_receive(:exists?).with('/somewhere/cool/').and_return(false)
    property_validator = PropertyValidator.new(config, file)
    expect { property_validator.input_directory }.to raise_error(RappaError, 'input directory: /somewhere/cool/ does not exist')
  end

  it 'should raise error when input directory property is not supplied' do
    config = {}
    file = double('File')
    property_validator = PropertyValidator.new(config, file)
    expect { property_validator.input_directory }.to raise_error(RappaError, 'property input_directory is mandatory but was not supplied')
  end

  it 'should return output directory when supplied an output directory location' do
    config = {:output_directory => '/somewhere/out/there'}
    file = double('File')
    property_validator = PropertyValidator.new(config, file)
    property_validator.output_directory.should == config[:output_directory]
  end

  it 'should raise error when output directory property is not supplied' do
    config = {}
    file = double('File')
    property_validator = PropertyValidator.new(config, file)
    expect { property_validator.output_directory }.to raise_error(RappaError, 'property output_directory is mandatory but was not supplied')
  end

  it 'should return input archive when supplied an existing input archive' do
    config = {:input_archive => '/some/archive'}
    file = double('File')
    file.should_receive(:exists?).with('/some/archive').and_return(true)
    property_validator = PropertyValidator.new(config, file)
    property_validator.input_archive.should == '/some/archive'
  end

  it 'should raise error when supplied a non existing input archive' do
    config = {:input_archive => '/some/archive'}
    file = double('File')
    file.should_receive(:exists?).with('/some/archive').and_return(false)
    property_validator = PropertyValidator.new(config, file)
    expect { property_validator.input_archive }.to raise_error(RappaError, 'input archive: /some/archive does not exist')
  end

  it 'should return output archive when supplied an output archive location' do
    config = {:output_archive => '/somewhere/out/there'}
    file = double('File')
    property_validator = PropertyValidator.new(config, file)
    property_validator.output_archive.should == config[:output_archive]
  end

  it 'should raise error when output archive property is not supplied' do
    config = {}
    file = double('File')
    property_validator = PropertyValidator.new(config, file)
    expect { property_validator.output_archive }.to raise_error(RappaError, 'property output_archive is mandatory but was not supplied')
  end

  it 'should return input rap when supplied an existing input rap' do
    config = {:input_rap => '/some/rap.yml'}
    file = double('File')
    file.should_receive(:exists?).with('/some/rap.yml').and_return(true)
    property_validator = PropertyValidator.new(config, file)
    property_validator.input_rap.should == config[:input_rap]
  end

  it 'should raise an error for input rap when supplied a non existing input rap' do
     config = {:input_rap => '/some/rap.yml'}
     file = double('File')
     file.should_receive(:exists?).with('/some/rap.yml').and_return(false)
     property_validator = PropertyValidator.new(config, file)
     expect {property_validator.input_rap }.to raise_error(RappaError, 'input rap: /some/rap.yml does not exist')
  end

  it 'should raise error when input rap property is not supplied' do
    config = {}
    file = double('File')
    property_validator = PropertyValidator.new(config, file)
    expect { property_validator.input_rap }.to raise_error(RappaError, 'property input_rap is mandatory but was not supplied')
  end

  it 'should return url when supplied an existing input rap' do
    config = {:url => 'http://some/url'}
    file = double('File')
    property_validator = PropertyValidator.new(config, file)
    property_validator.url.should == config[:url]
  end

  it 'should raise error when url property is not supplied' do
    config = {}
    file = double('File')
    property_validator = PropertyValidator.new(config, file)
    expect { property_validator.url }.to raise_error(RappaError, 'property url is mandatory but was not supplied')
  end

  it 'should return api_key when supplied an api_key' do
    config = {:api_key => 'some_api_key'}
    file = double('File')
    property_validator = PropertyValidator.new(config, file)
    property_validator.api_key.should == config[:api_key]
  end

  it 'should raise error when api_key property is not supplied' do
    config = {}
    file = double('File')
    property_validator = PropertyValidator.new(config, file)
    expect { property_validator.api_key }.to raise_error(RappaError, 'property api_key is mandatory but was not supplied')
  end

  it 'should validate name during package' do
    name = 'some_rap'
    file = double('File')
    file.should_receive(:exists?).with('some_rap').and_return(false)
    property_validator = PropertyValidator.new({:file_name => 'some_rap'}, file)
    property_validator.validate_name(name).should == nil
  end


  it 'should raise error with validate name during package if name exists' do
    name = 'some_rap'
    file = double('File')
    file.should_receive(:exists?).with('some_rap').and_return(true)
    property_validator = PropertyValidator.new({:file_name => 'some_rap'}, file)
    expect { property_validator.validate_name(name) }.to raise_error(RappaError, 'a rap archive already exists with the name: some_rap.rap - please remove it and try again')
  end

end
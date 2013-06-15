require 'rspec'
require 'fileutils'
require File.dirname(File.expand_path(__FILE__)) + '/../src/rappa'

describe "Rappa" do

  before(:each) do
    @generated = File.dirname(File.expand_path(__FILE__)) + '/generated'
    FileUtils.rm_rf(@generated) if File.exists?(@generated)
    Dir.mkdir(@generated)
  end

  it 'should create an archive of the current directory in the correct rap format with a rap deployment config file' do
    make_fake_project
    Rappa.new(:input_directory => "#{@generated}/test_rap/", :output_directory => @generated).package
    assert_file_exists("#{@generated}/test_rap.rap")
    Rappa.new(:input_archive => "#{@generated}/test_rap.rap", :output_archive => @generated + '/output').expand
    assert_expanded_archive
  end



  #it 'should exclude files and directories when using exclude option in config file' do
  #
  #end
  #
  #it 'should include files and directories when using include option in config file' do
  #
  #end

  def assert_expanded_archive
    ["#{@generated}/output/test_rap/test_1.txt","#{@generated}/output/test_rap/nested","#{@generated}/output/test_rap/nested/test_2.txt"].each do |path|
      assert_file_exists(path)
    end
  end

  def assert_file_exists(file)
    File.exists?(file).should == true
  end

  def make_fake_project
    project_path = "#{@generated}/test_rap"
    Dir.mkdir(project_path)
    Dir.mkdir(project_path + '/nested')
    File.open("#{@generated}/test_rap/test_1.txt","w"){|f| f.puts "This is test_1.txt"}
    File.open("#{@generated}/test_rap/nested/test_2.txt","w"){|f| f.puts "This is test_2.txt"}
  end

end
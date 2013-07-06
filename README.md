# Package and deploy ruby rack based applications

Rappa is a tool which lets you package your rack based application e.g. Sinatra, Rails etc for easy deployment to a ThunderCat container.
Visit the ThunderCat project to understand how this works.

[![Build Status](https://secure.travis-ci.org/masterthought/rappa.png)](http://travis-ci.org/masterthought/rappa)


## Background

Rappa is written in ruby and was created to simplify the package and deploy process of Sinatra and Rails apps. The idea is to have a single artifact
that is propagated through various environments and into a production environment via a deployment pipeline.

## Install

gem install rappa

## Config

The first thing you need is a rap.yml file which needs to live in the root of your project:

     :name: My Awesome App
     :version: 0.0.1
     :description: This App rocks
     :server_type: thin
     :start_script: start.sh
     :stop_script: stop.sh
     :pids: tmp/pids
     :bootstrap: bootstrap.sh

All fields are mandatory apart from the bootstrap field. All the fields are pretty self explanatory but here is a detailed breakdown:

  * :name: - the name of the application
  * :version: - the version of the application
  * :description: - the description of the application
  * :server_type: - the type of server - supported servers currently are: thin, unicorn, webrick
  * :start_script: - the path relative to the root of your project which contains a script that starts your application
  * :stop_script: - the path relative to the root of your project which contains a script that stops your application
  * :pids: - the path relative to the root of your project that contains the pids generated when your application starts
  * :bootstrap: - the path relative to the root of your project to a script that contains extra commands to run before starting

Rappa works by trying to start and stop your application via the start and stop scripts you provide. It also uses the pids to figure out if
your application is running or not. You can supply a script to run before start is called via the bootstrap field.

An example would be to have a thin project which uses Rake and has the following content:

### Rakefile

     require 'rake'

     namespace :thin do

       desc "Start The Application"
       task :start do
         puts "Starting The Application..."
         system("thin start -e production -p 9991 -s 1 -d")
       end

       desc "Stop The Application"
       task :stop do
         puts "Stopping The Application..."
         Dir.new(File.dirname(__FILE__) + '/tmp/pids').each do |file|
           prefix = file.to_s
           if prefix[0, 4] == 'thin'
             str = "thin stop -P#{File.dirname(__FILE__)}/tmp/pids/#{file}"
             puts "Stopping server on port #{file[/\d+/]}..."
             system(str)
           end
         end
       end
     end

### Start and Stop Scripts

./start.sh

     rake thin:start

./stop.sh

     rake thin:stop

./config.ru

     require File.dirname(__FILE__) + '/sinatra_app'
     run Sinatra::Application

./bootstrap.sh

     echo "Inside the bootstrap"
     bundle install
     mkdir -p /some/dir/some/where
     echo "Done with bootstrap"

(Recommended that you bundle package instead of putting a bundle install in the bootstrap.sh though)

### Rap file

./rap.yml

    :name: My Awesome App
    :version: 0.0.1
    :description: This App rocks
    :server_type: thin
    :start_script: start.sh
    :stop_script: stop.sh
    :pids: tmp/pids
    :bootstrap: bootstrap.sh

## Usage

Once you have your rap.yml in the root of your project you must navigate one level up and you can perform the following things:

  * package
  * expand
  * deploy

### package

This packages your application. You need a rap.yml in the root of your project and must be executed from one level up from your application e.g.

     rappa package -i path/to/your/app -o path/to/destination

The -i is for input directory and the -o is for output directory e.g.

     rappa package -i ./myapp -o .

Will produce a myapp.rap in the current directory. The name of the folder of your application is what will be used in the rap archive.

### expand

This expands an existing rap archive e.g.

     rappa -a myapp.rap -d .

This will expand the myapp.rap into the current directory. (it will be inside a directory called myapp)

### deploy

This deploys a rap archive to a thundercat server e.g.

     rappa deploy -r myapp.rap -u http://thundercat/api/deploy -k your_api_key

-r is to specify your rap archive and -u is the url of the deploy api where your thundercat instance is running. -k is your api_key which is configured in your
thundercat server.

## Develop

Interested in contributing? Great just let me know how you want to help.


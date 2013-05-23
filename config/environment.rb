#!/usr/bin/env ruby
# encoding: utf-8

# Boot process

require 'yaml'
require 'bundler/setup'
require 'sequel'

RACK_ENV = (ENV['RACK_ENV'] || 'development').dup.freeze

lib_dir = File.expand_path('../lib', File.dirname(__FILE__))
$:.unshift(lib_dir) unless $:.include?(lib_dir)

## Database connection

database_yml    = File.expand_path('database.yml', File.dirname(__FILE__))
database_config = YAML.load_file(database_yml)[RACK_ENV]
DB = Sequel.connect(database_config)

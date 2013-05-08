#!/usr/bin/env ruby
# encoding: utf-8

# Boot process

require 'yaml'
require 'bundler/setup'

RACK_ENV = ENV['RACK_ENV'].dup.freeze

lib_dir = File.expand_path('../lib', File.dirname(__FILE__))
$:.unshift(lib_dir) unless $:.include?(lib_dir)

## Require

require 'mdwnin'

## Database connection

database_yml    = File.expand_path('database.yml', File.dirname(__FILE__))
database_config = YAML.load_file(database_yml)[RACK_ENV]
Sequel.connect(database_config)

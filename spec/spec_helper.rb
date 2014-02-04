# Spec helper for Rails-less tests

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..'))
ENV["RAILS_ENV"] ||= 'test'

require 'rspec/mocks'
require "codeclimate-test-reporter"

CodeClimate::TestReporter.start if ENV['RAILS_ENV'] == 'testing'

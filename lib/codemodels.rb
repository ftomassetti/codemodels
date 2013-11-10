# encoding: utf-8

curr_dir = File.dirname(__FILE__)

Dir["#{curr_dir}/codemodels/*.rb"].each { |rb| require rb }

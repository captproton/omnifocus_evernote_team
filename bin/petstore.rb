#!/usr/bin/env ruby

require 'rubygems'
require 'thor'
# require 'term/ansicolor'
require 'rails/generators/actions'

class PetStore < Thor
    include Thor::Actions
    include Rails::Generators::Actions

    desc 'hello', 'say hello'
    def hello
        puts "Hello World"
    end
end

PetStore.start
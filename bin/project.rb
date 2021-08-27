#!/usr/bin/env ruby
require 'fileutils'
require 'nokogiri'
require 'rubygems'
require 'thor'
# require 'term/ansicolor'
require 'rails/generators/actions'

class Project < Thor
    include Thor::Actions
    include Rails::Generators::Actions

    desc 'generate', 'generate project folder and contents'
    def generate(name)
        app_url = "omnifocus:///task/bEGFarO1njv"
        project_title = _create_project_title(name)
        puts "generating project `#{project_title}`"

        # create folder & initiate @project_folder
        folder_path = _create_project_folder(project_title)
        puts "generating folder `#{folder_path}`"

        # generate files for project folder
        link_file = _create_inetloc_file(folder_path, app_url)
        puts "generating file `#{link_file}`"

    end

    desc '_sanitize', 'clean up user input to create safe folder or file names'
    def _sanitize(folder_or_file_name)
        # Remove any character that aren't 0-9, A-Z, or a-z
        folder_or_file_name.gsub(/[^0-9A-Z]/i, '_')
    end

    desc '_create_project_folder', 'create project folder with a safe name'
    def _create_project_folder(folder_name)
        clean_folder_name = _sanitize(folder_name)
        @project_folder = FileUtils.mkdir_p("./projects/#{clean_folder_name}")
        @project_folder.first.to_s + "/"
    end

    desc '_create_project_title', 'create project title'
    def _create_project_title(name)
        date_string = Time.new.strftime("%Y-%m-%d")
        project_title = "#{date_string}||#{name}"
    end
    desc '_create_inetloc_file', 'create project linking file'
    def _create_inetloc_file(folder_path, app_url)
        file_path = "#{folder_path}note.inetloc"
        file_content = _new_inetloc_xml(app_url)

        File.write(file_path, file_content.to_xml)
        file_path
    end

    desc '_new_inetloc_xml', 'create inetlocl xml'
    def _new_inetloc_xml(app_url)
        content = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
              xml.doc.create_internal_subset(
    'plist',
    "-//Apple//DTD PLIST 1.0//EN",
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd"
  )
            xml.plist {
                xml.dict {
                    xml.key "URL"
                    xml.string app_url
                }
            }
        end
#         <?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
# <plist version="1.0">
# <dict>
#     <key>URL</key>
#     <string>smb://server/share</string>
# </dict>
# </plist>
    end
end

Project.start(ARGV)
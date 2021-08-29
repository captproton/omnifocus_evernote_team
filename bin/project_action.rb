#!/usr/bin/env ruby
require_relative '../config/environment'

class ProjectAction < Thor
    include Thor::Actions
    include Rails::Generators::Actions
  
    ## Overall steps
    #   • new_project_title
    #   • initialize_source_directory
    #   • create YAML entry with project_title and source_directory path
    #   • make evernote note manually (since we haven't set up API call yet)
    #   • update YAML entry with evernote uri
    #   • initialize_omnifocus_project with links to:
    #       • project source directory
    #       • link to evernote note 
    #   • update YAML omnifocus URI
    #   • add_inetloc_files_to_source_directory


    desc 'new_project_title', 'generates formatted project title'
    def new_project_title(name)
        project_title = _create_project_title(name)
        puts project_title
    end

    desc 'initialize_omnifocus_project', 'takes the project title and sets it in the OF pop-up'
    def initialize_omnifocus_project(project_title, omnifocus_link)
        omnifocus_url = _generate_omnifocus_url(project_title, omnifocus_link)
        puts omnifocus_url
    end
    
    desc 'initialize_project_directory', 'creates a project folder based on the formatted title'
    def initialize_project_directory(project_title)
        # create safe project directory
        folder = _create_project_folder(project_title)
    end
    
    desc 'add_inetloc_files_to_project_directory', 'creates project inetloc files based on the formatted title'
    def add_inetloc_files_to_project_directory(project_title, 
        omnifocus_url="omnifocus:///task/morning", 
        evernote_url="evernote:///view/[userId]/[shardId]/[noteGuid]/[noteGuid]/")
        # get directory path with project title
        folder_name = _sanitize(project_title)

        folder_base_path = _set_base_path

        folder_path = "#{folder_base_path}#{folder_name}/"
        puts folder_path

        folder_base_url = _set_base_url
        folder_url = "#{folder_base_url}#{folder_name}/"
        puts folder_url

        # add omnifocus.inetloc to directory

        # add evernote.inetloc to directory
        puts "Foldler path: #{folder_path}"
         _create_inetloc_file(folder_path, "omnifocus", omnifocus_url)
         _create_inetloc_file(folder_path, "evernote", evernote_url)
         _create_readme_file(folder_path, project_title)
    end
    
    desc 'generate', 'wizard for generating '
    def generate(name)
        # initiate project hash
        say(set_color "…generating meta data based on project name", :green, :on_black, :bold)
        @project = _create_project_title(name)

        # prompt user to create a note
        say(set_color "Make a note in evernote with this title:", :cyan, :on_black, :bold)
        say(set_color "#{@project.formatted_title}", :magenta, :on_black)

        # get app link for evernote note & add to data
        evernote_link = ask("What is the evernote app link for the new note (Ctrl ⌥ ⌘ C)?")
        puts "#{evernote_link}"
        @project.evernote_link = evernote_link

        # create project's source folder
        folder = FileUtils.mkdir_p(@project.source_directory_path)
        say(set_color "…created source folder: `#{@project.source_directory_path}`", :green, :on_black, :bold)

        # add README
        file_path = "#{@project.source_directory_path}/readme.md"
        file_content = "readme for #{@project.formatted_title}"
        File.write(file_path, file_content)
        say(set_color "…created README in source folder: `#{file_path}`", :green, :on_black, :bold) 

        # prompt user to create task with an Omnifocus add link
        omnifocus_add_link = _generate_omnifocus_url(@project.formatted_title, @project.evernote_link)
                say(set_color "Click on this link and press `save` when prompted:", :cyan, :on_black, :bold)
        say(set_color "#{omnifocus_add_link}", :magenta)

        # # prompt user
        omnifocus_link = ask("What is the link for the omnifocus project (right click on project and 'copy as link')?")
        @project.omnifocus_link = omnifocus_link

        # add links to omnifocus project and note to source directory
        
        say(set_color "…adding link project link and notes link file to project source folder", :green, :on_black, :bold)
        omnifocus_link_file = LinkFile.new.add_interloc_file_to_project_directory(@project.source_directory_path, "omnifocus", @project.omnifocus_link)
        evernote_link_file = LinkFile.new.add_interloc_file_to_project_directory(@project.source_directory_path, "evernote", @project.evernote_link)
        say(set_color "Here's their folder", :green, :on_black, :bold)
        say(set_color "#{@project.source_directory_path}", :magenta, :on_black)

        puts @project
    end

    desc '_set_base_path', 'set project base path with username'
    def _set_base_path
        project_base_path = "#{ENV['HOME']}/Documents/projects/"
    end

    desc '_set_base_url', 'set project base url with username'
    def _set_base_url
        project_base_path = _set_base_path
        project_base_url = "file://#{project_base_path}"
    end

    desc '_sanitize', 'clean up user input to create safe folder or file names'
    def _sanitize(folder_or_file_name)
        # Remove any character that aren't 0-9, A-Z, or a-z
        folder_or_file_name.gsub(/[^0-9A-Z]/i, '_')
    end

    desc '_set_evernote_inetloc_app_url', 'collect and set app link for evernote app'
    def _set_evernote_inetloc_app_url(app)
        file_path = "#{folder_path}note.inetloc"
        file_content = _new_inetloc_xml(app_url)

        File.write(file_path, file_content.to_xml)
        file_path
    end

    desc '_set_omnifocus_inetloc_app_url', 'collect and set app link for omnifocus app'
    def _set_omnifocus_inetloc_app_url(app)
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
    #  should render this:
    # <?xml version="1.0" encoding="UTF-8"?>
    # <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    # <plist version="1.0">
    #   <dict>
    #     <key>URL</key>
    #     <string>smb://server/share</string>
    #   </dict>
    # </plist>
    end
# ====================
    private

    def _create_project_title(name)
        @project = ProjectController.new.create(params={title: name})
        # Project.new.generate_data_from_title(name)
    end

    def _generate_omnifocus_url(project_title, evernote_link)
        data = Project.new.generate_data_from_title(project_title)
        url_encoded_project_title = data[:url_encoded_project_title]
        project_folder_uri = data[:file_uri]

        notes   = "source: #{project_folder_uri}\n\n  notes: #{evernote_link}".gsub(/\s/, '%20')   
        url     = "omnifocus:///add?project=#{url_encoded_project_title}&name=default%20task&note=#{notes}"
    end

    def _create_project_folder(formal_project_title)
        source_directory_path = Project.new.generate_data_from_title(formal_project_title)[:source_directory_path]
        @project_folder = FileUtils.mkdir_p(source_directory_path)
        # @project_folder.first.to_s + "/"
    end

    def _create_inetloc_file(folder_path, app_name, app_url)
        file_path = "#{folder_path}#{app_name}.inetloc"
        file_content = _new_inetloc_xml(app_url)

        File.write(file_path, file_content.to_xml)
        puts file_path
        file_path
    end

    def _create_readme_file(folder_path, project_title)
        file_path = "#{folder_path}readme.md"
        file_content = "readme for #{project_title}"

        File.write(file_path, file_content)
        puts file_path
        file_path
    end





end

ProjectAction.start(ARGV)
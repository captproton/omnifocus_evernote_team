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
    def initialize_omnifocus_project(project_title)
        omnifocus_url = _generate_omnifocus_url(project_title)
        puts omnifocus_url
        #  omnifocus:///add?project=chores&name=Pick%20up%20milk&note=You%20gotta
        # open omnifocus link
        # _open_link(omnifocus_url)
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
    
    desc 'generate', 'generate project folder and contents'
    def generate(name)
        apps = %w[evernote omnifocus]
        project_title = _create_project_title(name)
        ## steps 
            # gather input
            # perform work -- 
                # * create project folder and link files
                # * record work in a YAML entry
            # Deliver Results
                # return YAML record in a way that can be grepped and cut
            # handle failure

        puts "generating project `#{project_title}`"

        # create folder & initiate @project_folder
        folder_path = _create_project_folder(project_title)
        puts "generating folder `#{folder_path}`"

        # generate files for project folder
        apps.each do |app|
            app_url = "omnifocus:///task/bEGFarO1njv"
            link_file = _create_inetloc_file(folder_path, app_url)
            puts "generating file `#{link_file}`"            
        end

    end

    desc '_set_user_name', 'set computer username'
    def _set_user_name
        user_name = 'carltanner'
    end

    desc '_set_base_path', 'set project base path with username'
    def _set_base_path
        user_name = _set_user_name
        project_base_path = "/Users/#{user_name}/Documents/projects/"
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

    desc '_generate_omnifocus_url', 'pieces together omnifocus add url'
    def _generate_omnifocus_url(project_title, project_folder_url="~/Documents/projects/")
        url = "omnifocus:///add?project=#{project_title}&name=default%20task&note=#{project_folder_url}"
    end

    desc '_create_project_folder', 'create project folder with a safe name'
    def _create_project_folder(formal_project_title)
        clean_folder_name = _sanitize(formal_project_title)
        project_base_path = _set_base_path
        @project_folder = FileUtils.mkdir_p("#{project_base_path}#{clean_folder_name}")
        # @project_folder.first.to_s + "/"
    end

    desc '_create_project_title', 'create project title'
    def _create_project_title(name)
        date_string = Time.new.strftime("%Y-%m-%d")
        project_title = "#{date_string}||#{name}"
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

    desc '_create_inetloc_file', 'create project linking file'
    def _create_inetloc_file(folder_path, app_name, app_url)
        file_path = "#{folder_path}#{app_name}.inetloc"
        file_content = _new_inetloc_xml(app_url)

        File.write(file_path, file_content.to_xml)
        puts file_path
        file_path
    end

    desc '_create_readme_file', 'create default readme.md file'
    def _create_readme_file(folder_path, project_title)
        file_path = "#{folder_path}readme.md"
        file_content = "readme for #{project_title}"

        File.write(file_path, file_content)
        puts file_path
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
end

ProjectAction.start(ARGV)
#!/usr/bin/env ruby
require_relative '../config/environment'

class ProjectAction < Thor
    include Thor::Actions
    include Rails::Generators::Actions

    ## Overall steps
    #   • new_project_title
    #   • initialize_source_directory
    #   • create YAML entry with project_title and source_directory path
    #   • create obsidian note automatically
    #   • initialize_omnifocus_project with links to:
    #       • project source directory
    #       • link to obsidian note
    #   • update YAML omnifocus URI
    #   • add_inetloc_files_to_source_directory

    desc 'new_project_title', 'generates formatted project title'
    def new_project_title(name)
        project_title = _create_project_title(name)
        puts project_title
    end

    desc 'initialize_omnifocus_project', 'takes the project title and sets it in the OF pop-up'
    def initialize_omnifocus_project(project_title, omnifocus_link)
        omnifocus_url = _generate_omnifocus_url(project_title, omnifocus_link, "")
        puts omnifocus_url
    end

    desc 'initialize_project_directory', 'creates a project folder based on the formatted title'
    def initialize_project_directory(project_title)
        _create_project_folder(project_title)
    end

    no_commands do
        def add_inetloc_files_to_project_directory(project_title, omnifocus_url="omnifocus:///task/morning")
            folder_name = _sanitize(project_title)
            folder_base_path = _set_base_path
            folder_path = File.join(folder_base_path, folder_name)
            
            LinkFile.new.add_inetloc_file(folder_path, "omnifocus", omnifocus_url)
            LinkFile.new.add_readme_file(folder_path, project_title)
        end
    end

    desc 'generate [project_title]', 'Wizard for generating a project in OmniFocus with an Obsidian note and source folder.'
    def generate(name)
        say(set_color "…generating meta data based on project name", :green, :on_black, :bold)
        @project = _create_project_title(name)

        # create project's source folder
        FileUtils.mkdir_p(@project.source_directory_path)

        # add README and Obsidian note
        @project.create_obsidian_note
        LinkFile.new.add_readme_file(@project.source_directory_path, @project.formatted_title)

        # prompt user to create task with an Omnifocus add link
        omnifocus_add_link = _generate_omnifocus_url(@project.formatted_title, @project.obsidian_uri, @project.file_uri)
        say(set_color "the formatted title: `#{@project.formatted_title}`", :green, :on_black, :bold)
        say(set_color "Click on this link and press `save` when prompted:", :cyan, :on_black, :bold)
        say(set_color "#{omnifocus_add_link}", :magenta)

        # prompt user for OmniFocus project link
        @project.omnifocus_link = ask("OmniFocus Project Link (Right-click > Copy as Link):")

        say(set_color "…finalizing links", :green, :on_black, :bold)
        link_tool = LinkFile.new
        link_tool.add_inetloc_file(@project.source_directory_path, "omnifocus", @project.omnifocus_link)
        
        # update obsidian note with the now-available omnifocus link
        @project.create_obsidian_note

        say(set_color "\nSuccess! Project Orchestrated.", :green, :on_black, :bold)
        say "Project:  #{@project.formatted_title}"
        say "Folder:   #{@project.source_directory_path}"
        say "Obsidian: #{@project.obsidian_uri}"
        say "OF Link:  #{@project.omnifocus_link}"
    end

    private

    def _create_project_title(name)
        ProjectController.new.create(title: name)
    end

    def _generate_omnifocus_url(formatted_title, note_link, file_uri)
        notes = URI.encode_www_form_component("source: #{file_uri}\n\nnotes: #{note_link}").gsub('+', '%20')
        "omnifocus:///add?project=#{URI.encode_www_form_component(formatted_title).gsub('+', '%20')}&name=default%20task&note=#{notes}"
    end

    def _create_project_folder(formal_project_title)
        source_directory_path = Project.new.generate_data_from_title(formal_project_title)[:source_directory_path]
        FileUtils.mkdir_p(source_directory_path)
    end


    def _sanitize(folder_or_file_name)
        folder_or_file_name.gsub(/[^0-9A-Z]/i, '_')
    end

    def _set_base_path
        Project.new._set_base_path
    end

    def _set_base_url
        "file://#{_set_base_path}"
    end
end

ProjectAction.start(ARGV)

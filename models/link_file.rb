class LinkFile
    
    def add_interloc_file_to_project_directory(source_directory, app_name, app_url)
        file_path = "#{source_directory}#{app_name}.inetloc"
        file_content = _new_inetloc_xml(app_url)

        File.write(file_path, file_content.to_xml)
        puts file_path
        file_path
    end
    def add_inetloc_files_to_project_directory(project_title, 
                                               omnifocus_url="omnifocus:///task/morning")
        # get directory path with project title
        folder_name = _sanitize(project_title)

        folder_base_path = _set_base_path

        folder_path = "#{folder_base_path}#{folder_name}/"
        puts folder_path

        folder_base_url = _set_base_url
        folder_url = "#{folder_base_url}#{folder_name}/"
        puts folder_url

        # add omnifocus.inetloc to directory
        puts "Foldler path: #{folder_path}"
            _create_inetloc_file(folder_path, "omnifocus", omnifocus_url)
            _create_readme_file(folder_path, project_title)
    end

    def _new_inetloc_xml(app_url)
        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
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
    end


end
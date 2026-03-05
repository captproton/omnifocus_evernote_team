class LinkFile
    
    def add_inetloc_file(source_directory, app_name, app_url)
        file_path = File.join(source_directory, "#{app_name}.inetloc")
        file_content = _new_inetloc_xml(app_url)

        File.write(file_path, file_content.to_xml)
        file_path
    end

    def add_readme_file(source_directory, project_title)
        file_path = File.join(source_directory, "readme.md")
        File.write(file_path, "readme for #{project_title}")
        file_path
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
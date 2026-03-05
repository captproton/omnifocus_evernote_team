require 'uri'
class Project
    attr_accessor(
                    :title, 
                    :formatted_title, 
                    :url_encoded_project_title, 
                    :source_directory_path, 
                    :file_uri, 
                    :evernote_link, 
                    :omnifocus_link, 
                    :params
    )

    # {:title=>"get back", :formatted_title=>"2021-08-29||get back", :url_encoded_project_title=>"get%20back", :source_directory_path=>"/Users/carltanner/Documents/projects/2021_08_29__get_back/", :file_uri=>"file:///Users/carltanner/Documents/projects/2021_08_29__get_back/", :evernote_link=>"evernote:///view/3203701/s29/b7c3394c-fc9a-47f1-56e0-ff71c29f57b1/a63a6bf3-a81a-43c1-9b58-0298097c0691", :omnifocus_link=>"omnifocus:///task/oU4kh8gWfeX"}
    def initialize(title:"",
                    formatted_title: "",
                    url_encoded_project_title: "",
                    source_directory_path: "",
                    file_uri: "", 
                    evernote_link: "", 
                    omnifocus_link: "",
                    params: {}                    
        )
        @title                      = title.to_s
        @formatted_title            = formatted_title.to_s
        @url_encoded_project_title  = url_encoded_project_title.to_s
        @source_directory_path      = source_directory_path.to_s
        @file_uri                   = file_uri.to_s
        @evernote_link              = evernote_link.to_s
        @omnifocus_link             = omnifocus_link.to_s
        @params = params
    end
    
    # attributes: title, source_directory_path, evernote_link, omnifocus_link 
    def hello
        "hello world"
    end


    def _find_by_title(title)
        
    end

    def save
        puts "project saved!"
        self
    end

    def generate_data_from_title(title)
        formatted_title             = self.generate_formatted_title(title)
        url_encoded_project_title   = self.generate_omnifocus_encoded_project_title(title)
        source_directory_path       = self._generate_source_directory_path(formatted_title)
        evernote_link               = ""
        omnifocus_link              = ""
        file_uri                    = "file://#{source_directory_path}"
        {title: title, 
                        formatted_title: formatted_title,
                        url_encoded_project_title: url_encoded_project_title,
                        source_directory_path: source_directory_path,
                        file_uri: file_uri,
                        evernote_link: evernote_link,
                        omnifocus_link: omnifocus_link
                       }
    end

    def generate_formatted_title(title)
        date_string = Time.new.strftime("%Y-%m-%d")
        "#{date_string}||#{title}"        
    end

    def generate_omnifocus_encoded_project_title(title)
        title.gsub(/\s/, '%20')              
    end

    def _generate_source_directory_path(formatted_title)
        "#{_set_base_path}#{_sanitize(formatted_title)}/"
    end

    def _sanitize(formatted_title)
        formatted_title.gsub(/[^0-9A-Z]/i, '_')
    end

    def _set_base_path
        path = ENV['PROJECTS_BASE_PATH'].to_s.strip
        if path.empty?
            path = "#{ENV['HOME']}/Documents/projects/"
        else
            path = File.expand_path(path)
        end
        path += "/" unless path.end_with?("/")
        path
    end

    def _obsidian_vault_path
        ENV['OBSIDIAN_VAULT_PATH']
    end

    def _obsidian_vault_name
        ENV['OBSIDIAN_VAULT_NAME']
    end

    def obsidian_uri
        vault = URI.encode_www_form_component(_obsidian_vault_name.to_s).gsub('+', '%20')
        # Ensure we have a formatted title to work with
        title_to_use = formatted_title.empty? ? generate_formatted_title(@title) : formatted_title
        file = URI.encode_www_form_component(_sanitize(title_to_use)).gsub('+', '%20')
        "obsidian://open?vault=#{vault}&file=#{file}"
    end

    def create_obsidian_note
        vault_path = _obsidian_vault_path
        return unless vault_path
        
        # Ensure we have a formatted title
        title_to_use = formatted_title.empty? ? generate_formatted_title(@title) : formatted_title
        
        FileUtils.mkdir_p(vault_path)
        
        filename = "#{_sanitize(title_to_use)}.md"
        full_path = File.join(vault_path, filename)
        
        content = <<~MARKDOWN
          # #{title_to_use}
          
          Created: #{Time.new.strftime("%Y-%m-%d")}
          
          ## Links
          - [Local Directory](#{file_uri})
          - [OmniFocus](#{omnifocus_link})
        MARKDOWN
        
        File.write(full_path, content)
    end

end

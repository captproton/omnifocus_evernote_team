require 'uri'
class Project
    attr_accessor(
                    :title, 
                    :formatted_title, 
                    :url_encoded_project_title, 
                    :source_directory_path, 
                    :file_uri, 
                    :omnifocus_link, 
                    :params
    )

    # {:title=>"get back", :formatted_title=>"2021-08-29||get back", :url_encoded_project_title=>"get%20back", :source_directory_path=>"/Users/carltanner/Documents/projects/2021_08_29__get_back/", :file_uri=>"file:///Users/carltanner/Documents/projects/2021_08_29__get_back/", :evernote_link=>"evernote:///view/3203701/s29/b7c3394c-fc9a-47f1-56e0-ff71c29f57b1/a63a6bf3-a81a-43c1-9b58-0298097c0691", :omnifocus_link=>"omnifocus:///task/oU4kh8gWfeX"}
    def initialize(title:"",
                    formatted_title: "",
                    url_encoded_project_title: "",
                    source_directory_path: "",
                    file_uri: "", 
                    omnifocus_link: "",
                    params: {}                    
        )
        @title                      = title.to_s
        @formatted_title            = formatted_title.to_s
        @url_encoded_project_title  = url_encoded_project_title.to_s
        @source_directory_path      = source_directory_path.to_s
        @file_uri                   = file_uri.to_s
        @omnifocus_link             = omnifocus_link.to_s
        @params = params
    end
    
    # attributes: title, source_directory_path, omnifocus_link 
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
        fmt = generate_formatted_title(title)
        dir = _generate_source_directory_path(fmt)
        { title: title, formatted_title: fmt, url_encoded_project_title: generate_omnifocus_encoded_project_title(title),
          source_directory_path: dir, file_uri: "file://#{dir}", omnifocus_link: "" }
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

    def _set_base_path
        path = _env_path('PROJECTS_BASE_PATH') || "#{ENV['HOME']}/Documents/projects/"
        path += "/" unless path.end_with?("/")
        path
    end

    def obsidian_uri
        return unless _obsidian_vault_name
        "obsidian://open?vault=#{_url_encode(_obsidian_vault_name)}&file=#{_url_encode(_sanitize(_effective_title))}"
    end

    def create_obsidian_note
        return unless _obsidian_vault_path
        FileUtils.mkdir_p(_obsidian_vault_path)
        File.write(File.join(_obsidian_vault_path, "#{_sanitize(_effective_title)}.md"), _note_content)
    end

    private

    def _sanitize(formatted_title)
        formatted_title.gsub(/[^0-9A-Z]/i, '_')
    end

    def _env_path(key)
        val = ENV[key].to_s.strip
        val.empty? ? nil : File.expand_path(val)
    end

    def _blank?(val)
        val.to_s.strip.empty?
    end

    def _obsidian_vault_path
        _env_path('OBSIDIAN_VAULT_PATH')
    end

    def _obsidian_vault_name
        name = ENV['OBSIDIAN_VAULT_NAME'].to_s.strip
        name.empty? ? nil : name
    end

    def _effective_title
        formatted_title.empty? ? generate_formatted_title(@title) : formatted_title
    end

    def _url_encode(str)
        URI.encode_www_form_component(str).gsub('+', '%20')
    end

    def _note_content
        <<~MARKDOWN
          # #{_effective_title}
          
          Created: #{Time.new.strftime("%Y-%m-%d")}
          
          ## Links
          - [Local Directory](#{file_uri})
          - [OmniFocus](#{omnifocus_link})
        MARKDOWN
    end
end

class Project
    attr_writer :title
    attr_writer :formatted_title
    attr_writer :url_encoded_project_title
    attr_writer :source_directory_path
    attr_writer :file_uri
    attr_writer :evernote_link
    attr_writer :omnifocus_link
    attr_writer :params

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
        data_hash = {}
        formatted_title             = self.generate_formatted_title(title)
        url_encoded_project_title   = self.generate_omnifocus_encoded_project_title(title)
        source_directory_path       = self._generate_source_directory_path(formatted_title)
        evernote_link               = ""
        omnifocus_link              = ""
        file_uri                    = "file://#{source_directory_path}"
        data_hash =    {title: title, 
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
        project_title = "#{date_string}||#{title}"        
    end

    def generate_omnifocus_encoded_project_title(title)
        url_encoded_project_title = title.gsub(/\s/, '%20')              
    end

    def _generate_source_directory_path(formatted_title)
        clean_folder_name = "#{_sanitize(formatted_title)}/"
        project_base_path = _set_base_path
        "#{project_base_path}#{clean_folder_name}"
    end
    def _generate_clean_folder_name(formatted_title)
        project_base_path = _set_base_path
    end

    def _sanitize(formatted_title)
        clean_folder_name = formatted_title.gsub(/[^0-9A-Z]/i, '_')
    end

    def _set_base_path
        project_base_path = "#{ENV['HOME']}/Documents/projects/"

    end

end

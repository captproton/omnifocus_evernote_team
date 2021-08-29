class Project
    attr_writer :title
    attr_writer :source_directory_path
    attr_writer :evernote_link
    attr_writer :omnifocus_link
    attr_writer :params

    def initialize(title:"",
                    source_directory_path: "",
                    evernote_link: "", 
                    omnifocus_link: "",
                    params: {}                    
        )
        @title = title.to_s
        @source_directory_path = source_directory_path.to_s
        @evernote_link = evernote_link.to_s
        @omnifocus_link = omnifocus_link.to_s
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
    end
end

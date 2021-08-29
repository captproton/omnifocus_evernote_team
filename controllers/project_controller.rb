class ProjectController

    def new
        @project = Project.new
    end

    def show
        @project = Project.new.find_by_title()
    end

    def create(title, params={})
        @project = Project.new(title: title)
        params.each { |k,v| @project.public_send("#{k}=", v) }
        @project.save
    end

    def update(title,params={})
        @item = self._find_by_title(title)

    end

    def project_params
        params.require(:project).permit(:title,
                    :source_directory_path,
                    :evernote_link, 
                    :omnifocus_link)
    end
end
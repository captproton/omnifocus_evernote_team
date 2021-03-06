class ProjectController

    def new
        @project = Project.new
    end

    def show
        @project = Project.new.find_by_title()
    end

    def create(params={})
        @project = Project.new
        params.each { |k,v| @project.public_send("#{k}=", v) }
        data = @project.generate_data_from_title(params[:title])
        # update attributes in data hash
        data.each { |k,v| @project.public_send("#{k}=", v) }
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
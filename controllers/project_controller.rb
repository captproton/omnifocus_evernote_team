class ProjectController

    def new
        @project = Project.new
    end

    def index
        @projects = Project.all
    end

    def show(title)
        @project = Project.find_by_title(title)
    end

    def create(params={})
        @project = Project.new
        params.each { |k,v| @project.public_send("#{k}=", v) }
        data = @project.generate_data_from_title(params[:title])
        # update attributes in data hash
        data.each { |k,v| @project.public_send("#{k}=", v) }
        @project.save
    end

    def update(title, params={})
        @project = Project.find_by_title(title)
        return unless @project
        params.each { |k,v| @project.public_send("#{k}=", v) }
        @project.save
    end

    def destroy(title)
        @project = Project.find_by_title(title)
        @project&.delete
    end

    def project_params
        params.require(:project).permit(:title,
                    :source_directory_path, 
                    :omnifocus_link)
    end
end
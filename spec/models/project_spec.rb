RSpec.describe Project do
  let(:project) { Project.new }

  describe '#generate_formatted_title' do
    it 'returns a title prefixed with today\'s date' do
      today = Time.new.strftime("%Y-%m-%d")
      result = project.generate_formatted_title("superzooks")
      expect(result).to eq("#{today}||superzooks")
    end

    it 'preserves spaces in the title' do
      today = Time.new.strftime("%Y-%m-%d")
      result = project.generate_formatted_title("my cool project")
      expect(result).to eq("#{today}||my cool project")
    end
  end

  describe '#generate_omnifocus_encoded_project_title' do
    it 'replaces spaces with %20' do
      result = project.generate_omnifocus_encoded_project_title("my cool project")
      expect(result).to eq("my%20cool%20project")
    end

    it 'returns a title with no spaces unchanged' do
      result = project.generate_omnifocus_encoded_project_title("superzooks")
      expect(result).to eq("superzooks")
    end
  end

  describe '#_sanitize' do
    it 'replaces spaces with underscores' do
      result = project._sanitize("my cool project")
      expect(result).to eq("my_cool_project")
    end

    it 'replaces hyphens with underscores' do
      result = project._sanitize("2021-08-27||superzooks")
      expect(result).to eq("2021_08_27__superzooks")
    end

    it 'replaces all special characters with underscores' do
      result = project._sanitize("hello world!")
      expect(result).to eq("hello_world_")
    end

    it 'preserves alphanumeric characters unchanged' do
      result = project._sanitize("superzooks123")
      expect(result).to eq("superzooks123")
    end
  end

  describe '#_set_base_path' do
    it 'returns the projects directory in the user\'s home folder' do
      result = project._set_base_path
      expect(result).to eq("#{ENV['HOME']}/Documents/projects/")
    end
  end

  describe '#_generate_source_directory_path' do
    it 'builds a sanitized path under the base projects directory' do
      formatted_title = "2021-08-27||superzooks"
      result = project._generate_source_directory_path(formatted_title)
      expect(result).to start_with("#{ENV['HOME']}/Documents/projects/")
      expect(result).to include("2021_08_27__superzooks")
      expect(result).to end_with("/")
    end
  end

  describe '#generate_data_from_title' do
    let(:data) { project.generate_data_from_title("superzooks") }
    let(:today) { Time.new.strftime("%Y-%m-%d") }

    it 'returns a hash with the correct keys' do
      expect(data.keys).to contain_exactly(
        :title, :formatted_title, :url_encoded_project_title,
        :source_directory_path, :file_uri, :evernote_link, :omnifocus_link
      )
    end

    it 'sets the formatted_title with today\'s date' do
      expect(data[:formatted_title]).to eq("#{today}||superzooks")
    end

    it 'sets the file_uri as a file:// path' do
      expect(data[:file_uri]).to start_with("file://")
      expect(data[:file_uri]).to include("superzooks")
    end

    it 'leaves evernote_link blank' do
      expect(data[:evernote_link]).to eq("")
    end

    it 'leaves omnifocus_link blank' do
      expect(data[:omnifocus_link]).to eq("")
    end
  end

  describe '#initialize' do
    it 'accepts keyword arguments and sets attributes' do
      p = Project.new(
        title: "Test",
        formatted_title: "2021-08-27||Test",
        evernote_link: "evernote:///view/123",
        omnifocus_link: "omnifocus:///task/abc"
      )
      expect(p.title).to eq("Test")
      expect(p.formatted_title).to eq("2021-08-27||Test")
      expect(p.evernote_link).to eq("evernote:///view/123")
      expect(p.omnifocus_link).to eq("omnifocus:///task/abc")
    end

    it 'defaults all string fields to empty strings' do
      p = Project.new
      expect(p.title).to eq("")
      expect(p.formatted_title).to eq("")
      expect(p.evernote_link).to eq("")
      expect(p.omnifocus_link).to eq("")
    end
  end
end

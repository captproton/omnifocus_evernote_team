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
    it 'returns the projects directory in the user\'s home folder by default' do
      # Ensure env var is cleared for this test
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('PROJECTS_BASE_PATH').and_return(nil)
      result = project._set_base_path
      expect(result).to eq("#{ENV['HOME']}/Documents/projects/")
    end

    it 'respects the PROJECTS_BASE_PATH environment variable if set' do
      custom_path = "/tmp/other_projects/"
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('PROJECTS_BASE_PATH').and_return(custom_path)
      result = project._set_base_path
      expect(result).to eq(custom_path)
    end

    it 'adds a trailing slash if PROJECTS_BASE_PATH is missing one' do
      custom_path = "/tmp/no_slash"
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('PROJECTS_BASE_PATH').and_return(custom_path)
      result = project._set_base_path
      expect(result).to eq("/tmp/no_slash/")
    end

    it 'falls back to default if PROJECTS_BASE_PATH is a blank string' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('PROJECTS_BASE_PATH').and_return("  ")
      result = project._set_base_path
      expect(result).to eq("#{ENV['HOME']}/Documents/projects/")
    end

    it 'expands paths (like ~) if present in PROJECTS_BASE_PATH' do
      custom_path = "~/custom_projects"
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('PROJECTS_BASE_PATH').and_return(custom_path)
      result = project._set_base_path
      expect(result).to eq("#{ENV['HOME']}/custom_projects/")
    end
  end

  describe '#_obsidian_vault_path' do
    it 'returns nil if OBSIDIAN_VAULT_PATH is not set' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('OBSIDIAN_VAULT_PATH').and_return(nil)
      expect(project._obsidian_vault_path).to be_nil
    end

    it 'returns the vault path if set' do
      vault_path = "/Users/test/Vault"
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('OBSIDIAN_VAULT_PATH').and_return(vault_path)
      expect(project._obsidian_vault_path).to eq(vault_path)
    end
  end

  describe '#_obsidian_vault_name' do
    it 'returns nil if OBSIDIAN_VAULT_NAME is not set' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('OBSIDIAN_VAULT_NAME').and_return(nil)
      expect(project._obsidian_vault_name).to be_nil
    end

    it 'returns the vault name if set' do
      vault_name = "MyProjects"
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('OBSIDIAN_VAULT_NAME').and_return(vault_name)
      expect(project._obsidian_vault_name).to eq(vault_name)
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

  describe '#obsidian_uri' do
    let(:project) { Project.new(title: "My New Project") }

    before do
      allow(ENV).to receive(:[]).with('OBSIDIAN_VAULT_NAME').and_return('WorkVault')
    end

    it 'generates a valid obsidian open URI' do
      fixed_time = Time.new(2026, 3, 5)
      allow(Time).to receive(:new).and_return(fixed_time)
      
      expected_uri = "obsidian://open?vault=WorkVault&file=2026_03_05__My_New_Project"
      expect(project.obsidian_uri).to eq(expected_uri)
    end

    it 'URL encodes vault and file names' do
      project.title = "Project & Co"
      allow(ENV).to receive(:[]).with('OBSIDIAN_VAULT_NAME').and_return('My Vault')
      
      fixed_time = Time.new(2026, 3, 5)
      allow(Time).to receive(:new).and_return(fixed_time)
      
      expect(project.obsidian_uri).to include("vault=My%20Vault")
      expect(project.obsidian_uri).to include("file=2026_03_05__Project___Co")
    end
  end

  describe '#create_obsidian_note' do
    let(:project) { Project.new(title: "Obsidian Test") }
    let(:vault_path) { "/tmp/obsidian_vault/" }

    before do
      allow(ENV).to receive(:[]).with('OBSIDIAN_VAULT_PATH').and_return(vault_path)
      
      fixed_time = Time.new(2026, 3, 5)
      allow(Time).to receive(:new).and_return(fixed_time)
      
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:write)
    end

    it 'creates a markdown file in the correct vault path' do
      expected_file_path = "/tmp/obsidian_vault/2026_03_05__Obsidian_Test.md"
      project.create_obsidian_note
      expect(File).to have_received(:write).with(expected_file_path, anything)
    end

    it 'includes the project title and date in the note content' do
      project.create_obsidian_note
      expect(File).to have_received(:write) do |_path, content|
        expect(content).to include("# 2026-03-05||Obsidian Test")
        expect(content).to include("Created: 2026-03-05")
      end
    end

    it 'ensures the vault directory exists' do
      project.create_obsidian_note
      expect(FileUtils).to have_received(:mkdir_p).with(vault_path)
    end
  end
end

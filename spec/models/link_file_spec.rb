require 'tmpdir'

RSpec.describe LinkFile do
  let(:link_file) { LinkFile.new }

  describe '#_new_inetloc_xml' do
    let(:app_url) { "omnifocus:///task/abc123" }
    let(:xml_output) { link_file._new_inetloc_xml(app_url).to_xml }

    it 'generates valid XML output' do
      expect(xml_output).to include("<?xml version=\"1.0\"")
    end

    it 'includes a plist DOCTYPE declaration' do
      expect(xml_output).to include("DOCTYPE plist")
      expect(xml_output).to include("Apple//DTD PLIST 1.0//EN")
    end

    it 'wraps the URL in a plist dict structure' do
      expect(xml_output).to include("<plist>")
      expect(xml_output).to include("<dict>")
      expect(xml_output).to include("<key>URL</key>")
    end

    it 'embeds the app_url as a string element' do
      expect(xml_output).to include("<string>#{app_url}</string>")
    end
  end

  describe '#add_inetloc_file' do
    let(:tmp_dir) { Dir.mktmpdir }

    after { FileUtils.rm_rf(tmp_dir) }

    it 'creates an .inetloc file at the expected path' do
      result_path = link_file.add_inetloc_file(
        tmp_dir, "omnifocus", "omnifocus:///task/abc123"
      )
      expect(File.exist?(result_path)).to be true
      expect(result_path).to end_with("omnifocus.inetloc")
    end

    it 'writes valid XML content to the file' do
      link_file.add_inetloc_file(
        tmp_dir, "omnifocus", "omnifocus:///task/abc123"
      )
      content = File.read(File.join(tmp_dir, "omnifocus.inetloc"))
      expect(content).to include("<key>URL</key>")
      expect(content).to include("omnifocus:///task/abc123")
    end

    it 'returns the path to the created file' do
      result = link_file.add_inetloc_file(
        tmp_dir, "evernote", "evernote:///view/123"
      )
      expect(result).to eq(File.join(tmp_dir, "evernote.inetloc"))
    end

    it 'uses the provided app_name as the filename base' do
      link_file.add_inetloc_file(
        tmp_dir, "obsidian", "obsidian://open?vault=MyVault&file=test"
      )
      expect(File.exist?(File.join(tmp_dir, "obsidian.inetloc"))).to be true
    end
  end

  describe '#add_readme_file' do
    let(:tmp_dir) { Dir.mktmpdir }

    after { FileUtils.rm_rf(tmp_dir) }

    it 'creates a readme.md file' do
      result_path = link_file.add_readme_file(tmp_dir, "My Project")
      expect(File.exist?(result_path)).to be true
      expect(result_path).to end_with("readme.md")
    end

    it 'includes the project title in the content' do
      link_file.add_readme_file(tmp_dir, "Super Project")
      content = File.read(File.join(tmp_dir, "readme.md"))
      expect(content).to eq("readme for Super Project")
    end
  end
end

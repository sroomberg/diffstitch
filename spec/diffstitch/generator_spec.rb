# frozen_string_literal: true

require 'tmpdir'
require 'json'

RSpec.describe Diffstitch::Generator do
  let(:base)      { 'main' }
  let(:branches)  { ['feature-a'] }
  let(:diffs)     { { 'feature-a' => "diff --git a/x.rb b/x.rb\n" } }
  let(:title)     { 'Test Diff Report' }
  let(:generator) { described_class.new(base: base, branches: branches, diffs: diffs, title: title) }

  describe '#write' do
    around do |example|
      Dir.mktmpdir { |dir| @output_dir = dir; example.run }
    end

    it 'creates all expected output files' do
      generator.write(@output_dir)
      %w[index.html data.js styles.css app.js bootstrap.min.css].each do |file|
        expect(File).to exist(File.join(@output_dir, file)), "expected #{file} to exist"
      end
    end

    it 'embeds the base name in data.js' do
      generator.write(@output_dir)
      content = File.read(File.join(@output_dir, 'data.js'))
      expect(content).to include('"base":"main"')
    end

    it 'embeds branch diffs in data.js' do
      generator.write(@output_dir)
      content = File.read(File.join(@output_dir, 'data.js'))
      payload = content.sub(/\Aconst DIFF_DATA = /, '').chomp(";\n")
      data = JSON.parse(payload)
      expect(data['branches']['feature-a']).to include('diff --git')
    end

    it 'renders the title into index.html' do
      generator.write(@output_dir)
      html = File.read(File.join(@output_dir, 'index.html'))
      expect(html).to include('Test Diff Report')
    end

    it 'creates the output directory if it does not exist' do
      nested = File.join(@output_dir, 'a', 'b', 'c')
      generator.write(nested)
      expect(Dir).to exist(nested)
    end

    it 'copies styles.css from gem assets unchanged' do
      generator.write(@output_dir)
      source  = File.read(File.join(Diffstitch::Generator::ASSETS_DIR, 'styles.css'))
      written = File.read(File.join(@output_dir, 'styles.css'))
      expect(written).to eq(source)
    end
  end
end

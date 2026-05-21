# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Diffstitch::CLI do
  subject(:cli) { described_class.new }

  def run(*args)
    cli.run(args)
  end

  describe '--version' do
    it 'prints the version and exits 0' do
      expect { run('--version') }
        .to output("#{Diffstitch::VERSION}\n").to_stdout
        .and raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    end
  end

  describe '--help' do
    it 'prints usage information and exits 0' do
      expect { run('--help') }
        .to output(/Usage:.*diffstitch/m).to_stdout
        .and raise_error(SystemExit) { |e| expect(e.status).to eq(0) }
    end
  end

  describe '#derived_output (private)' do
    it 'builds the path from base and branch names' do
      path = cli.send(:derived_output, 'main', ['feature-a', 'feature-b'])
      expect(path).to eq(File.join('.diffstitch', 'output', 'main_vs_feature-a_feature-b'))
    end

    it 'replaces forward slashes with hyphens' do
      path = cli.send(:derived_output, 'main', ['feature/auth', 'fix/login'])
      expect(path).to eq(File.join('.diffstitch', 'output', 'main_vs_feature-auth_fix-login'))
    end

    it 'replaces backslashes with hyphens' do
      path = cli.send(:derived_output, 'main', ['feature\\thing'])
      expect(path).to eq(File.join('.diffstitch', 'output', 'main_vs_feature-thing'))
    end
  end

  context 'when not inside a git repository' do
    before { allow(Diffstitch::Git).to receive(:in_repo?).and_return(false) }

    it 'aborts with an error message' do
      expect { run('main', 'feature') }
        .to raise_error(SystemExit) { |e| expect(e.status).not_to eq(0) }
    end
  end

  context 'when called with too few arguments' do
    before { allow(Diffstitch::Git).to receive(:in_repo?).and_return(true) }

    it 'aborts with an error message' do
      expect { run('main') }
        .to raise_error(SystemExit) { |e| expect(e.status).not_to eq(0) }
    end
  end

  context 'when a ref does not exist' do
    before do
      allow(Diffstitch::Git).to receive(:in_repo?).and_return(true)
      allow(Diffstitch::Git).to receive(:verify_ref!).and_raise(Diffstitch::Git::Error, 'bad ref')
    end

    it 'aborts with an error message' do
      expect { run('main', 'ghost') }
        .to raise_error(SystemExit) { |e| expect(e.status).not_to eq(0) }
    end
  end

  context 'with valid arguments' do
    around { |ex| Dir.mktmpdir { |d| @dir = d; ex.run } }

    before do
      allow(Diffstitch::Git).to receive(:in_repo?).and_return(true)
      allow(Diffstitch::Git).to receive(:verify_ref!)
      allow(Diffstitch::Git).to receive(:diff).and_return('')
    end

    it 'prints the path to the generated index.html' do
      expect { run('main', 'feature', '--output', @dir) }
        .to output(/Generated:.*index\.html/).to_stdout
    end

    it 'writes the output files' do
      run('main', 'feature', '--output', @dir)
      expect(File).to exist(File.join(@dir, 'index.html'))
    end

    it 'uses a custom title when --title is given' do
      run('main', 'feature', '--output', @dir, '--title', 'My Report')
      html = File.read(File.join(@dir, 'index.html'))
      expect(html).to include('My Report')
    end

    it 'defaults output to .diffstitch/output/<derived> when --output is omitted' do
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          run('main', 'feature')
          expect(Dir).to exist(File.join(tmpdir, '.diffstitch', 'output', 'main_vs_feature'))
        end
      end
    end
  end
end

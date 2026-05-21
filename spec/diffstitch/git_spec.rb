# frozen_string_literal: true

require 'open3'

RSpec.describe Diffstitch::Git do
  let(:ok)      { double('status', success?: true) }
  let(:failure) { double('status', success?: false) }

  describe '.in_repo?' do
    it 'returns true when git reports a git dir' do
      allow(Open3).to receive(:capture3).with('git', 'rev-parse', '--git-dir')
                                        .and_return(['', '', ok])
      expect(described_class.in_repo?).to be true
    end

    it 'returns false outside a git repo' do
      allow(Open3).to receive(:capture3).with('git', 'rev-parse', '--git-dir')
                                        .and_return(['', '', failure])
      expect(described_class.in_repo?).to be false
    end
  end

  describe '.verify_ref!' do
    it 'does not raise for a valid ref' do
      allow(Open3).to receive(:capture3).with('git', 'rev-parse', '--verify', 'main^{commit}')
                                        .and_return(['abc123', '', ok])
      expect { described_class.verify_ref!('main') }.not_to raise_error
    end

    it 'raises Git::Error for an invalid ref' do
      allow(Open3).to receive(:capture3).with('git', 'rev-parse', '--verify', 'ghost^{commit}')
                                        .and_return(['', 'fatal: Needed a single revision', failure])
      expect { described_class.verify_ref!('ghost') }.to raise_error(Diffstitch::Git::Error, /'ghost'/)
    end
  end

  describe '.diff' do
    it 'returns diff output on success' do
      allow(Open3).to receive(:capture3).with('git', 'diff', 'main..feature', '--no-color')
                                        .and_return(["diff --git a/foo.rb b/foo.rb\n", '', ok])
      result = described_class.diff('main', 'feature')
      expect(result).to include('diff --git')
    end

    it 'raises Git::Error on failure' do
      allow(Open3).to receive(:capture3).with('git', 'diff', 'main..bad', '--no-color')
                                        .and_return(['', 'fatal: bad revision', failure])
      expect { described_class.diff('main', 'bad') }.to raise_error(Diffstitch::Git::Error)
    end
  end
end

# frozen_string_literal: true

require 'open3'

module Diffstitch
  module Git
    class Error < StandardError; end

    def self.in_repo?
      _, _, status = Open3.capture3('git', 'rev-parse', '--git-dir')
      status.success?
    end

    def self.verify_ref!(ref)
      _, err, status = Open3.capture3('git', 'rev-parse', '--verify', "#{ref}^{commit}")
      raise Error, "'#{ref}' is not a valid branch or commit.\n#{err.strip}" unless status.success?
    end

    def self.diff(base, branch)
      out, err, status = Open3.capture3('git', 'diff', "#{base}..#{branch}", '--no-color')
      raise Error, "git diff #{base}..#{branch} failed:\n#{err.strip}" unless status.success?

      out
    end
  end
end

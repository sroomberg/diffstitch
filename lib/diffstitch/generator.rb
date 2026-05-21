# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'erb'

module Diffstitch
  class Generator
    ASSETS_DIR = File.expand_path('assets', __dir__)

    def initialize(base:, branches:, diffs:, title:)
      @base     = base
      @branches = branches
      @diffs    = diffs
      @title    = title
    end

    def write(output_dir)
      FileUtils.mkdir_p(output_dir)
      write_data_js(output_dir)
      %w[bootstrap.min.css styles.css app.js].each { |f| FileUtils.cp(asset(f), output_dir) }
      write_html(output_dir)
    end

    private

    def asset(name)
      File.join(ASSETS_DIR, name)
    end

    def write_data_js(dir)
      payload = JSON.generate({ base: @base, title: @title, branches: @diffs })
      File.write(File.join(dir, 'data.js'), "const DIFF_DATA = #{payload};\n")
    end

    def write_html(dir)
      title    = @title
      template = ERB.new(File.read(asset('index.html.erb')), trim_mode: '-')
      File.write(File.join(dir, 'index.html'), template.result(binding))
    end
  end
end

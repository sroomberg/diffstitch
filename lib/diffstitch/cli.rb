# frozen_string_literal: true

require 'optparse'

module Diffstitch
  class CLI
    OUTPUT_BASE = File.join('.diffstitch', 'output')

    def self.start(argv = ARGV)
      new.run(argv)
    end

    def run(argv)
      options = { output: nil, open: false }

      parser = OptionParser.new do |opts|
        opts.banner = <<~BANNER
          diffstitch — compare multiple git branches against a base in a split HTML view

          Usage: diffstitch <base> <branch1> [branch2 ...] [options]
        BANNER

        opts.on('-o', '--output DIR', "Output directory (default: #{OUTPUT_BASE}/<base>_vs_<branches>)") { |v| options[:output] = v }
        opts.on('--open', 'Open result in browser after generating') { options[:open] = true }
        opts.on('--title TITLE', 'Custom page title') { |v| options[:title] = v }
        opts.on_tail('-v', '--version', 'Show version') { puts VERSION; exit }
        opts.on_tail('-h', '--help', 'Show this help') { puts opts; exit }
      end

      parser.parse!(argv)

      abort 'Error: not inside a git repository.' unless Git.in_repo?

      if argv.length < 2
        abort "Error: provide a base branch and at least one comparison branch.\n" \
              'Usage: diffstitch <base> <branch1> [branch2 ...]'
      end

      base     = argv[0]
      branches = argv[1..]

      begin
        [base, *branches].each { |ref| Git.verify_ref!(ref) }
      rescue Git::Error => e
        abort "Error: #{e.message}"
      end

      title      = options[:title] || "diffstitch: #{branches.join(' | ')} vs #{base}"
      output_dir = options[:output] || derived_output(base, branches)

      diffs = begin
        branches.each_with_object({}) { |branch, h| h[branch] = Git.diff(base, branch) }
      rescue Git::Error => e
        abort "Error: #{e.message}"
      end

      Generator.new(base: base, branches: branches, diffs: diffs, title: title)
               .write(output_dir)

      index = File.expand_path(File.join(output_dir, 'index.html'))
      puts "Generated: #{index}"

      open_in_browser(index) if options[:open]
    end

    private

    def derived_output(base, branches)
      sanitize = ->(b) { b.gsub(%r{[/\\]}, '-') }
      name = "#{sanitize.(base)}_vs_#{branches.map(&sanitize).join('_')}"
      File.join(OUTPUT_BASE, name)
    end

    def open_in_browser(path)
      system("open '#{path}' 2>/dev/null || xdg-open '#{path}' 2>/dev/null || start '#{path}'")
    end
  end
end

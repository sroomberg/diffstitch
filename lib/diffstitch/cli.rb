# frozen_string_literal: true

require 'optparse'

module Diffstitch
  class CLI
    OUTPUT_BASE = File.join('.diffstitch', 'output')

    def self.start(argv = ARGV)
      new.run(argv)
    end

    def run(argv)
      options = parse_options!(argv)
      validate_repo!
      validate_args!(argv)

      base     = argv[0]
      branches = argv[1..]

      verify_refs!(base, branches)

      title      = options[:title] || "diffstitch: #{branches.join(' | ')} vs #{base}"
      output_dir = options[:output] || derived_output(base, branches)
      diffs      = collect_diffs(base, branches)

      Generator.new(base: base, branches: branches, diffs: diffs, title: title).write(output_dir)

      index = File.expand_path(File.join(output_dir, 'index.html'))
      puts "Generated: #{index}"
      open_in_browser(index) if options[:open]
    end

    private

    def parse_options!(argv)
      options = { output: nil, open: false }

      OptionParser.new do |opts|
        opts.banner = <<~BANNER
          diffstitch — compare multiple git branches against a base in a split HTML view

          Usage: diffstitch <base> <branch1> [branch2 ...] [options]
        BANNER

        opts.on('-o', '--output DIR', "Output directory (default: #{OUTPUT_BASE}/<base>_vs_<branches>)") do |v|
          options[:output] = v
        end
        opts.on('--open', 'Open result in browser after generating') { options[:open] = true }
        opts.on('--title TITLE', 'Custom page title') { |v| options[:title] = v }
        opts.on_tail('-v', '--version', 'Show version') do
          puts VERSION
          exit
        end
        opts.on_tail('-h', '--help', 'Show this help') do
          puts opts
          exit
        end
      end.parse!(argv)

      options
    end

    def validate_repo!
      abort 'Error: not inside a git repository.' unless Git.in_repo?
    end

    def validate_args!(argv)
      return if argv.length >= 2

      abort "Error: provide a base branch and at least one comparison branch.\n" \
            'Usage: diffstitch <base> <branch1> [branch2 ...]'
    end

    def verify_refs!(base, branches)
      [base, *branches].each { |ref| Git.verify_ref!(ref) }
    rescue Git::Error => e
      abort "Error: #{e.message}"
    end

    def collect_diffs(base, branches)
      branches.to_h { |branch| [branch, Git.diff(base, branch)] }
    rescue Git::Error => e
      abort "Error: #{e.message}"
    end

    def derived_output(base, branches)
      sanitize = ->(b) { b.gsub(%r{[/\\]}, '-') }
      name = "#{sanitize.call(base)}_vs_#{branches.map(&sanitize).join('_')}"
      File.join(OUTPUT_BASE, name)
    end

    def open_in_browser(path)
      system("open '#{path}' 2>/dev/null || xdg-open '#{path}' 2>/dev/null || start '#{path}'")
    end
  end
end

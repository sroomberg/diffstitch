# diffstitch

[![CI](https://github.com/sroomberg/diffstitch/actions/workflows/ci.yml/badge.svg)](https://github.com/sroomberg/diffstitch/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/diffstitch.svg)](https://rubygems.org/gems/diffstitch)

Compare multiple git branches against a base in a side-by-side HTML diff view.

diffstitch generates a self-contained HTML report that lets you compare several feature branches against a common base at once. The left panel always shows the base branch; the right panel shows the selected branch's changes and includes a dropdown to switch between branches on the fly.

## Installation

```sh
gem install diffstitch
```

Or add it to your `Gemfile`:

```ruby
gem 'diffstitch'
```

## Usage

```
diffstitch <base> <branch1> [branch2 ...] [options]
```

| Flag | Description |
|------|-------------|
| `-o`, `--output DIR` | Output directory (default: `./diffstitch_output`) |
| `--open` | Open the result in your browser after generating |
| `--title TITLE` | Custom page title |
| `-v`, `--version` | Print version |
| `-h`, `--help` | Show help |

### Examples

Compare two feature branches against `main`:

```sh
diffstitch main feature-auth feature-payments
```

Open in the browser immediately:

```sh
diffstitch main feature-auth --open
```

Custom output location and title:

```sh
diffstitch main feature-a feature-b feature-c \
  --output ./reports/sprint-42 \
  --title "Sprint 42 branch review"
```

## Output

diffstitch writes four files to the output directory — open `index.html` in any browser:

| File | Description |
|------|-------------|
| `index.html` | Main page |
| `data.js` | Branch diff data (JSON) |
| `app.js` | Client-side rendering and dropdown logic |
| `styles.css` | Diff-specific overrides |
| `bootstrap.min.css` | Bootstrap 5 (bundled — no CDN required for layout/theme) |

Diff rendering uses [diff2html](https://diff2html.xyz/) loaded from jsDelivr.

## Development

```sh
git clone https://github.com/sroomberg/diffstitch
cd diffstitch
bundle install
bundle exec rspec        # run tests
bundle exec rake         # same, via default Rake task
```

### Project layout

```
bin/diffstitch                  # executable entry point
lib/
  diffstitch.rb                 # top-level require
  diffstitch/
    version.rb                  # VERSION constant
    git.rb                      # Git module (in_repo?, verify_ref!, diff)
    generator.rb                # writes output directory
    cli.rb                      # OptionParser + orchestration
    assets/
      index.html.erb            # ERB template
      styles.css                # diff2html overrides and scrollbar
      app.js                    # browser-side rendering and sync scroll
      bootstrap.min.css         # Bootstrap 5.3.3 (bundled)
spec/
  diffstitch/
    git_spec.rb
    generator_spec.rb
    cli_spec.rb
```

### Releasing

1. Update `CHANGELOG.md` — add a `## [x.y.z] - YYYY-MM-DD` section.
2. Bump `VERSION` in `lib/diffstitch/version.rb`.
3. Commit and push.
4. Tag and push the tag:
   ```sh
   git tag v0.1.0
   git push origin v0.1.0
   ```
   The [Release workflow](.github/workflows/release.yml) will run CI and, if it passes, create a GitHub Release using the CHANGELOG entry for that version.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

[MIT](https://opensource.org/licenses/MIT)

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.1] - 2026-05-20

### Added
- RuboCop and rubocop-rspec as development dependencies
- `.rubocop.yml` with project-appropriate configuration
- RuboCop lint step added to CI and default Rake task

## [0.3.0] - 2026-05-20

### Changed
- Default output directory is now `.diffstitch/output/<base>_vs_<branches>`, derived
  from the branch names being compared (e.g. `main_vs_feature-auth_fix-login`)
- Slashes in branch names (e.g. `feature/auth`) are replaced with hyphens in the path

## [0.2.1] - 2026-05-20

### Fixed
- Line numbers now stay frozen at the left edge during horizontal scroll

## [0.2.0] - 2026-05-20

### Changed
- Restyled output HTML to mirror GitHub's diff color palette
- Switched from Bootstrap dark mode to light mode with a custom dark top nav
- Added CSS variables for the full color palette
- Line number gutters, addition/deletion backgrounds, and hunk headers now match GitHub exactly

## [0.1.0] - 2026-05-20

### Added
- `diffstitch` CLI command to generate a split-panel HTML diff report
- Support for diffing multiple branches against a single base
- Dark-themed side-by-side diff view powered by [diff2html](https://diff2html.xyz/)
- Bootstrap 5 for layout and component styling (bundled as a gem asset)
- Dropdown to switch between comparison branches without reloading
- Synchronized vertical scrolling between the base and branch panels
- `--output` flag to set a custom output directory (default: `./diffstitch_output`)
- `--open` flag to launch the output in the system browser after generating
- `--title` flag for a custom page title
- `--version` / `--help` flags

[Unreleased]: https://github.com/sroomberg/diffstitch/compare/v0.3.1...HEAD
[0.3.1]: https://github.com/sroomberg/diffstitch/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/sroomberg/diffstitch/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/sroomberg/diffstitch/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/sroomberg/diffstitch/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/sroomberg/diffstitch/releases/tag/v0.1.0

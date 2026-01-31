# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2026-01-31

### Added
-   Development docs and Makefile workflow.
-   Tested support for Chainlit 2.9.6.
-   CSS vendor prefixes for better Safari/Chrome support.

## [1.1.0] - 2026-01-31

### Added
-   New dock positions: `bottom-left` and `bottom-right`.
-   `Makefile` for streamlined local development (`make develop`, `make run`).
-   Improved default configuration handling.

### Changed
-   Updated `bottom-left` and `bottom-right` offsets to 80px for better aesthetics.
-   Removed `top-left` and `top-right` positions (use `bottom` variants or standard `top`).

## [1.0.0] - 2026-01-30

### Added
-   Initial release of Chainlit Docked Docs (CLDD).
-   Dockable UI with support for Bottom, Top, Left, and Right positioning.
-   Configurable dimensions (Width/Height) using CSS units.
-   Theme-aware styling (Light/Dark mode support).
-   Maximize modal with backdrop.

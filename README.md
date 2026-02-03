# Chainlit Docked Docs (CLDD)

![Version](https://img.shields.io/badge/version-1.3.1-blue) ![License](https://img.shields.io/badge/license-MIT-green) ![Chainlit](https://img.shields.io/badge/Chainlit-Compatible-F70069)
![Tested](https://img.shields.io/badge/Tested%20on-Chainlit%202.9.6-success)


A standalone UI extension for [Chainlit](https://github.com/Chainlit/chainlit) that adds a dockable, collapsible, and theme-aware documentation drawer to your application.

![Demo](assets/demo.gif)

## Features

-   **Dockable Positioning**: Pin the documentation tab to any edge or corner (Bottom, Top, Left, Right, Bottom-Left, Bottom-Right).
-   **Theme Aware**: Automatically adapts to Light/Dark mode settings (requires Chainlit's standard theme classes).
-   **Responsive**: Percentage-based sizing (`vw`/`vh`) that is fully configurable.
-   **Zero Python Dependencies**: Works purely via CSS injection and JavaScript.
-   **Namespace Safe**: All classes and IDs are prefixed with `cldd-` to avoid collisions.
-   **Browser Support**: Modern browsers only (Chrome, Firefox, Safari, Edge). **Internet Explorer is not supported**.

## Installation

### Automated (Recommended)
Run this command in the root of your Chainlit project:
```bash
curl -fsSL https://raw.githubusercontent.com/simingy/cldd/main/install.sh | bash
```

This script will:
1.  Download `custom.css` and `custom.js` to your `public/` directory.
2.  **Smart Update**: If you already have these files, it will append (or update) the CLDD code in a safe block, preserving your existing code.

### Manual
1.  **Add Files**: Copy `public/custom.css` and `public/custom.js` to your project's `public/` folder.
2.  **Configure Chainlit**: Edit `.chainlit/config.toml`:
    ```toml
    [UI]
    custom_css = "/public/custom.css"
    custom_js = "/public/custom.js"
    ```

## Configuration
    
### Global Configuration (Recommended)

You can configure options by setting `window.CLDD_CONFIG` **before** the script loads (or in a separate script).

```javascript
window.CLDD_CONFIG = {
    dockPosition: 'bottom',
    expandedWidth: '80vw',
    openDelay: '0.5s',  // Wait before expanding
    closeDelay: '0.2s'  // Wait before collapsing
};
```

### Options

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `dockPosition` | string | `'bottom'` | 'bottom', 'top', 'left', 'right', 'bottom-left', 'bottom-right' |
| `docsUrl` | string | *(Built-in)* | URL or path to embed. |
| `expandedWidth` | string | `'80vw'` | Width when expanded (CSS units). |
| `expandedHeight` | string | `'70vh'` | Height when expanded (CSS units). |
| `openDelay` | string | `'0s'` | Delay before expanding on hover. |
| `closeDelay` | string | `'0.2s'` | Delay before collapsing on mouse leave. |
| `buttonLabel` | string | `'DOCUMENTATION'` | Text label on the tab. |

## Usage

-   **Expand**: Hover over the "DOCUMENTATION" tab to peek at the docs.
-   **Maximize**: Click the Maximize icon (`⤢`) to open a full-screen modal with backdrop.
-   **Lock**: The drawer stays open while you interact with the iframe content.

---


## Development

This project includes a `Makefile` to automate the development environment setup.

### Prerequisites

-   Python 3.11+
-   `pyenv` (recommended for Python version management)

### Commands

-   **Setup**: `make develop` - Creates a virtual environment, installs dependencies, and sets up a dummy Chainlit app for testing.
-   **Run**: `make run` - Starts the development server with hot-reloading.
-   **Clean**: `make clean` - Removes the virtual environment and temporary files.

### Workflow

1.  Run `make develop` to initialize the environment.
2.  Run `make run` to start the app.
3.  Edit `public/custom.css` or `public/custom.js` and see changes instantly.

---

Created by [Siming Yuan](https://www.linkedin.com/in/simingy/)

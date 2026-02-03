/**
 * Chainlit Docked Docs (CLDD)
 * Version: 1.3.0
 * Author: Siming Yuan
 * License: MIT
 */

(function () {
    const initCLDD = () => {
        if (document.getElementById('cldd-drawer')) return; // Prevent duplicate init
        console.log('CLDD: Loading ChainLit Docked Docs...');

        // --- CONFIGURATION ---
        // You can customize the dock position, specific documentation URL, dimensions, and label here.
        const DEFAULTS = {
            // Dock Position
            // Options: 'bottom', 'bottom-left', 'bottom-right', 'top', 'left', 'right'
            // Default: 'bottom'
            dockPosition: 'bottom',

            // Documentation URL
            // Can be an external URL (e.g. 'https://docs.chainlit.io') or a local path (e.g. '/docs/')
            docsUrl: 'https://squidfunk.github.io/mkdocs-material/getting-started/',

            // Expanded Dimensions (when hovered/opened via mouse)
            // 'expandedWidth': Horizontal size (CSS units: px, %, vw)
            // 'expandedHeight': Vertical size (CSS units: px, %, vh)
            // Default: '50vw' / '50vh'
            expandedWidth: '80vw',
            expandedHeight: '70vh',

            // Transition Delays (CSS time units: s, ms)
            // 'openDelay': specific wait time before opening on hover
            // 'closeDelay': specific wait time before closing when mouse leaves
            openDelay: '0s',
            closeDelay: '0.2s',

            // Button Label
            // The text displayed on the collapsed tab.
            // Default: 'DOCUMENTATION'
            buttonLabel: 'DOCUMENTATION'
        };

        const CONFIG = Object.assign({}, DEFAULTS, window.CLDD_CONFIG || {});

        // Apply Configured Dimensions to CSS Variables
        const r = document.querySelector(':root');
        r.style.setProperty('--cldd-expand-width', CONFIG.expandedWidth);
        r.style.setProperty('--cldd-expand-height', CONFIG.expandedHeight);
        r.style.setProperty('--cldd-open-delay', CONFIG.openDelay);
        r.style.setProperty('--cldd-close-delay', CONFIG.closeDelay);


        // Create Backdrop
        const backdrop = document.createElement('div');
        backdrop.className = 'cldd-backdrop';

        // Create container
        const drawer = document.createElement('div');
        drawer.className = 'cldd-drawer';
        drawer.setAttribute('data-dock', CONFIG.dockPosition);

        // Header
        const header = document.createElement('div');
        header.className = 'cldd-header';
        header.tabIndex = 0;
        header.setAttribute('role', 'button');
        header.setAttribute('aria-expanded', 'false');
        header.setAttribute('aria-label', 'Toggle Documentation');

        // Label
        const label = document.createElement('div');
        label.className = 'cldd-label';
        label.innerText = CONFIG.buttonLabel;

        // Controls
        const controls = document.createElement('div');
        controls.className = 'cldd-controls';

        // Maximize Button
        const btnMax = document.createElement('button');
        btnMax.className = 'cldd-btn cldd-btn-maximize';
        btnMax.setAttribute('aria-label', 'Maximize Documentation');
        btnMax.title = 'Maximize';

        // Close Button
        const btnClose = document.createElement('button');
        btnClose.className = 'cldd-btn cldd-btn-close';
        btnClose.setAttribute('aria-label', 'Close Documentation');
        btnClose.title = 'Minimize';

        controls.appendChild(btnMax);
        controls.appendChild(btnClose);

        header.appendChild(label);
        header.appendChild(controls);
        drawer.appendChild(header);

        // Iframe
        const iframe = document.createElement('iframe');
        iframe.className = 'cldd-frame';
        iframe.src = CONFIG.docsUrl;
        drawer.appendChild(iframe);

        // Append to body (Order matters for CSS sibling selector ~)
        document.body.appendChild(drawer);    // Drawer first (Source)
        document.body.appendChild(backdrop);  // Backdrop second (Target)

        // --- LOGIC ---

        // Maximization
        const toggleMaximize = (forceState) => {
            const isMax = drawer.classList.toggle('maximized', forceState);
            header.setAttribute('aria-expanded', isMax);

            if (isMax) {
                backdrop.classList.add('visible');
            } else {
                backdrop.classList.remove('visible');

                // Immediate transition reset logic
                drawer.style.transitionDelay = '0s';
                setTimeout(() => {
                    drawer.style.transitionDelay = '';
                }, 300);
            }
        };

        btnMax.addEventListener('click', (e) => {
            e.stopPropagation();
            toggleMaximize(true);
        });

        btnClose.addEventListener('click', (e) => {
            e.stopPropagation();
            toggleMaximize(false);
        });

        header.addEventListener('dblclick', () => {
            const currentlyMax = drawer.classList.contains('maximized');
            toggleMaximize(!currentlyMax);
        });

        header.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                const currentlyMax = drawer.classList.contains('maximized');
                toggleMaximize(!currentlyMax);
            }
        });

        console.log('CLDD: Injected successfully.');
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initCLDD);
    } else {
        initCLDD();
    }
})();

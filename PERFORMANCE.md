# Performance changes

Applied across the homepage and all eight standalone pages.

## Images and slow connections

- Gallery photos have 480 px and 960 px JPEG variants. Responsive image hints select the appropriate download for the viewport and pixel density.
- The complete set of 960 px gallery variants totals 4.19 MB, compared with 34.55 MB for the originals, a reduction of 87.9%. These figures describe file sizes, not measured page load times.
- The navigation headshot uses a 72 px thumbnail. The main portrait has 320 px and 640 px variants and high fetch priority.
- The project logo has 400 px and 800 px PNG variants, preserving transparency.
- Certificate previews use compressed JPEG images and load only when opened. Original certificate downloads remain available in the viewer, including after a preview error.
- Below-the-fold images use native lazy loading. Explicit dimensions reserve space, and asynchronous decoding reduces interference with rendering.
- Local system fonts replace the external Google Fonts stylesheet and font downloads.
- Shared JavaScript uses `defer`. Hero text appears without waiting for entrance animations.

## Mobile and desktop

- Added narrow-screen text sizing, wrapping, and flexible action and statistics rows.
- Added minimum-width protection to grid children and long-text wrapping.
- Mobile navigation respects dynamic viewport height and scrolls within its available space.
- Menu controls have an accessible label, close with Escape, and reset when returning to desktop width.
- Supported browsers with Save-Data enabled or a 2G connection skip reveal effects, counters, continuous decorative animation, and header blur. Other browsers retain normal behavior. Reduced-motion preferences remain supported.

## Validation

- All nine HTML pages returned HTTP 200 through the local preview server.
- All local `src`, `href`, and certificate-preview references resolved.
- All 82 image elements include dimensions and asynchronous decoding.
- JavaScript syntax and normal/low-data startup checks passed.
- `git diff --check` passed.
- Browser visual verification and throttled load-time measurements were unavailable because the browser connector failed to connect.

## Updating images

Original assets remain unchanged. Regenerate image exports from the project root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/optimize-images.ps1
```

For newly added markup pointing at original assets, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/update-performance-markup.ps1
```

This static site requires no build step. Changes are local and ready for the existing publishing workflow.

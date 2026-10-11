# Tokpah V. Sanjue Portfolio

Static portfolio website built with HTML, CSS, and vanilla JavaScript. No build step is required.

Responsive image exports and performance changes are documented in [PERFORMANCE.md](PERFORMANCE.md). Original photos and certificates are retained. The site uses local system fonts without external font requests.

## Publish with GitHub Pages

1. Create a GitHub repository and upload this folder's contents to its default branch.
2. In the repository, open **Settings → Pages**.
3. Select **Deploy from a branch**, choose the default branch and the **/(root)** folder, then save.
4. GitHub will provide the public URL after deployment.

## Local preview

Open `index.html` directly in a browser, or use any local web server. The homepage includes all portfolio sections and works without fetching other pages. Existing standalone pages remain available, and their navigation links return to homepage sections.

Navigation order: Home, About, Certificates, Skills, Projects, Experience, Capabilities, Gallery. The homepage contains the introduction, all seven detailed portfolio sections, and contact section. Navigation scrolls to each section.

## Site structure

- `index.html` — complete portfolio with section navigation
- `public/about.html`, `public/experience.html`, `public/capabilities.html`, `public/skills.html`, `public/certificates.html` — standalone portfolio routes
- `public/gallery.html` — work-photo gallery
- `public/projects.html` — project page
- `assets/` — images, certificates, and gallery media

All HTML pages except index.html live in public/, including 404.html. Shared styles, scripts, and assets stay in the root folder.

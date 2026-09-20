const certificateViewer = document.querySelector('.certificate-viewer');
if (certificateViewer) {
  const content = certificateViewer.querySelector('.certificate-viewer-content');
  const title = certificateViewer.querySelector('#certificate-viewer-title');
  let opener;
  document.querySelectorAll('.certificate-view').forEach((link) => {
    link.addEventListener('click', (event) => {
      if (typeof certificateViewer.showModal !== 'function') return;
      event.preventDefault();
      opener = link;
      const name = link.closest('.certificate-card').querySelector('h4').textContent;
      title.textContent = name;
      const preview = document.createElement('img');
      preview.src = link.dataset.preview || link.href;
      preview.alt = name;
      preview.decoding = 'async';
      content.replaceChildren(preview);
      certificateViewer.showModal();
      document.documentElement.classList.add('certificate-viewer-open');
    });
  });
  certificateViewer.querySelector('.certificate-close').addEventListener('click', () => certificateViewer.close());
  certificateViewer.addEventListener('click', (event) => {
    if (event.target !== certificateViewer) return;
    const bounds = certificateViewer.getBoundingClientRect();
    if (event.clientX < bounds.left || event.clientX > bounds.right || event.clientY < bounds.top || event.clientY > bounds.bottom) certificateViewer.close();
  });
  certificateViewer.addEventListener('close', () => {
    content.replaceChildren();
    document.documentElement.classList.remove('certificate-viewer-open');
    opener?.focus({ preventScroll: true });
  });
}

const toggle = document.querySelector('.menu-toggle');
const navLinks = document.querySelector('.nav-links');
const themeToggle = document.querySelector('.theme-toggle');
const root = document.documentElement;

const savedTheme = window.localStorage.getItem('portfolio-theme');
if (savedTheme === 'light') root.classList.remove('dark-mode');

const updateThemeControl = () => {
  const darkMode = root.classList.contains('dark-mode');
  themeToggle?.setAttribute('aria-pressed', String(darkMode));
  themeToggle?.setAttribute('aria-label', darkMode ? 'Switch to light mode' : 'Switch to dark mode');
  const label = themeToggle?.querySelector('.theme-label');
  const icon = themeToggle?.querySelector('.theme-icon');
  if (label) label.textContent = darkMode ? 'Light mode' : 'Dark mode';
  if (icon) icon.textContent = darkMode ? '☼' : '☾';
};

updateThemeControl();
themeToggle?.addEventListener('click', () => {
  root.classList.toggle('dark-mode');
  window.localStorage.setItem('portfolio-theme', root.classList.contains('dark-mode') ? 'dark' : 'light');
  updateThemeControl();
});

toggle?.addEventListener('click', () => {
  const isOpen = navLinks.classList.toggle('open');
  toggle.setAttribute('aria-expanded', String(isOpen));
});

document.querySelectorAll('.nav-links a').forEach((link) => {
  link.addEventListener('click', () => {
    navLinks.classList.remove('open');
    toggle?.setAttribute('aria-expanded', 'false');
  });
});

const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
const revealElements = document.querySelectorAll('.reveal');
let revealObserver;
const showAllReveals = () => {
  revealObserver?.disconnect();
  root.classList.remove('reveal-enabled');
  revealElements.forEach((element) => element.classList.add('visible'));
};

if (!reducedMotion.matches && 'IntersectionObserver' in window) {
  revealObserver = new IntersectionObserver((entries) => {
    const entering = entries.filter((entry) => entry.isIntersecting);
    entering.forEach((entry, index) => {
      entry.target.style.setProperty('--reveal-delay', `${Math.min(index, 3) * 65}ms`);
      entry.target.classList.add('visible');
      revealObserver.unobserve(entry.target);
    });
  }, { threshold: 0, rootMargin: '0px 0px -24px 0px' });
  root.classList.add('reveal-enabled');
  revealElements.forEach((element) => revealObserver.observe(element));
} else {
  showAllReveals();
}
reducedMotion.addEventListener('change', (event) => {
  if (event.matches) showAllReveals();
});

const sectionPage = document.querySelector('[data-source-section]');
if (sectionPage) {
  const sourceSection = sectionPage.dataset.sourceSection;
  fetch('index.html')
    .then((response) => {
      if (!response.ok) throw new Error('Portfolio content could not be loaded.');
      return response.text();
    })
    .then((html) => {
      const sourceDocument = new DOMParser().parseFromString(html, 'text/html');
      const source = sourceDocument.querySelector(sourceSection);
      if (!source) throw new Error('Requested portfolio section was not found.');
      sectionPage.replaceChildren(source);
      sectionPage.removeAttribute('aria-busy');
    })
    .catch(() => {
      sectionPage.removeAttribute('aria-busy');
      sectionPage.querySelector('.page-loading')?.removeAttribute('hidden');
    });
}

const stats = document.querySelector('.hero-meta');
if (stats) {
  const counters = [...stats.querySelectorAll('strong')].map((element) => ({
    element,
    finalText: element.textContent,
    target: Number.parseInt(element.textContent, 10),
    suffix: element.textContent.replace(/^\d+/, ''),
  }));
  let frame;
  let statObserver;
  const finishCounters = () => {
    window.cancelAnimationFrame(frame);
    counters.forEach(({ element, finalText }) => { element.textContent = finalText; });
    statObserver?.disconnect();
  };
  const startCounters = () => {
    statObserver?.disconnect();
    const start = performance.now() + 250;
    const duration = 1800;
    counters.forEach(({ element, suffix }) => { element.textContent = `0${suffix}`; });
    const animate = (now) => {
      if (reducedMotion.matches) { finishCounters(); return; }
      const progress = Math.min(1, Math.max(0, (now - start) / duration));
      const eased = 1 - Math.pow(1 - progress, 3);
      counters.forEach(({ element, target, suffix, finalText }) => {
        element.textContent = progress === 1 ? finalText : `${Math.floor(target * eased)}${suffix}`;
      });
      if (progress < 1) frame = window.requestAnimationFrame(animate);
    };
    frame = window.requestAnimationFrame(animate);
  };
  if (!reducedMotion.matches && 'IntersectionObserver' in window) {
    statObserver = new IntersectionObserver((entries) => {
      if (entries.some((entry) => entry.isIntersecting)) startCounters();
    }, { threshold: 0.4 });
    statObserver.observe(stats);
  }
  reducedMotion.addEventListener('change', (event) => {
    if (event.matches) finishCounters();
  });
}

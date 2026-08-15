(() => {
  if (document.querySelector('[data-ray-home-navigation]')) return;
  const current = window.location.pathname.split('/').pop() || 'index.html';
  if (current === 'index.html') return;

  const link = document.createElement('a');
  link.href = 'index.html';
  link.setAttribute('data-ray-home-navigation', 'true');
  link.setAttribute('aria-label', 'Ir a la página principal');
  link.textContent = '🏠 Inicio';
  Object.assign(link.style, {
    position: 'fixed',
    left: 'max(14px, env(safe-area-inset-left))',
    bottom: 'max(14px, env(safe-area-inset-bottom))',
    zIndex: '9000',
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: '42px',
    padding: '9px 14px',
    borderRadius: '999px',
    background: '#0f172a',
    color: '#ffffff',
    border: '1px solid rgba(255,255,255,.22)',
    boxShadow: '0 8px 22px rgba(15,23,42,.28)',
    fontFamily: 'system-ui,-apple-system,sans-serif',
    fontSize: '13px',
    fontWeight: '750',
    lineHeight: '1',
    textDecoration: 'none'
  });
  document.body.appendChild(link);
})();

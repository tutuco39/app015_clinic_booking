// ハンバーガー開閉・アクセシビリティ対応
(function(){
  const toggle = document.querySelector('.nav-toggle');
  const nav = document.getElementById('nav');
  if(!toggle || !nav) return;

  const openMenu = () => { nav.classList.add('open');  toggle.setAttribute('aria-expanded','true'); }
  const closeMenu= () => { nav.classList.remove('open');toggle.setAttribute('aria-expanded','false'); }

  toggle.addEventListener('click', () => {
    nav.classList.toggle('open');
    const open = nav.classList.contains('open');
    toggle.setAttribute('aria-expanded', String(open));
  });

  // リンクをクリックしたら閉じる
  nav.addEventListener('click', (e) => {
    if (e.target.closest('a')) closeMenu();
  });

  // 外側クリックで閉じる
  document.addEventListener('click', (e) => {
    if (!nav.contains(e.target) && !toggle.contains(e.target)) closeMenu();
  });

  // ESCで閉じる
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeMenu();
  });
})();

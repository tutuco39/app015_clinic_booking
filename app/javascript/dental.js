// モバイルナビの開閉
const toggle = document.querySelector('.nav-toggle');
const nav = document.getElementById('nav');
toggle?.addEventListener('click', () => {
  const open = nav.style.display === 'block';
  nav.style.display = open ? 'none' : 'block';
  toggle.setAttribute('aria-expanded', String(!open));
});

// フッター年 & 予約日min
document.getElementById('year')?.append(new Date().getFullYear());
const dateInput = document.getElementById('date');
if (dateInput) {
  const t = new Date();
  const y = t.getFullYear();
  const m = String(t.getMonth()+1).padStart(2,'0');
  const d = String(t.getDate()).padStart(2,'0');
  dateInput.min = `${y}-${m}-${d}`;
}

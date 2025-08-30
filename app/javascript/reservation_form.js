document.addEventListener("turbo:load", () => {
  const dateEl     = document.getElementById("res_date");
  const timeEl     = document.getElementById("res_time");
  const hiddenDate = document.querySelector('input[name="reservation[date]"]');
  const hiddenTime = document.querySelector('input[name="reservation[time]"]');

  if (!dateEl || !timeEl || !hiddenDate || !hiddenTime) return;

  // 今日以降のみ選択可能
  const t = new Date();
  const y = t.getFullYear(), m = String(t.getMonth()+1).padStart(2,'0'), d = String(t.getDate()).padStart(2,'0');
  dateEl.min = `${y}-${m}-${d}`;

  dateEl.addEventListener("change", async () => {
    hiddenDate.value = dateEl.value;
    timeEl.innerHTML = `<option value="">読み込み中...</option>`;
    try {
      const res = await fetch(`/reservations/slots?date=${dateEl.value}`, { headers: { "Accept": "application/json" }});
      const data = await res.json();

      timeEl.innerHTML = "";
      if (Array.isArray(data.slots) && data.slots.length) {
        for (const hhmm of data.slots) {
          const opt = document.createElement("option");
          opt.value = hhmm; opt.textContent = hhmm;
          timeEl.appendChild(opt);
        }
      } else {
        timeEl.innerHTML = `<option value="">この日は予約枠がありません</option>`;
      }
    } catch (e) {
      console.error(e);
      timeEl.innerHTML = `<option value="">取得に失敗しました</option>`;
    }
  });

  timeEl.addEventListener("change", () => { hiddenTime.value = timeEl.value; });
});

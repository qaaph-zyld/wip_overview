(async function () {
  const metaEl = document.getElementById("meta");
  const tableEl = document.getElementById("table");

  async function load() {
    try {
      const ts = Date.now();
      const resp = await fetch(`./data/inventory.json?_ts=${ts}`, { cache: "no-store" });
      const rows = await resp.json();
      metaEl.textContent = `Records: ${rows.length}  Last updated: ${new Date().toLocaleString()}`;
      renderTable(rows);
    } catch (e) {
      metaEl.textContent = "Failed to load data.";
      console.error(e);
    }
  }

  function renderTable(rows) {
    if (!rows || !rows.length) { tableEl.innerHTML = "<p>No data.</p>"; return; }
    const cols = Object.keys(rows[0]);
    const thead = `<thead><tr>${cols.map(c=>`<th>${c}</th>`).join("")}</tr></thead>`;
    const tbody = "<tbody>" + rows.map(r => {
      return "<tr>" + cols.map(c => `<td>${r[c] ?? ""}</td>`).join("") + "</tr>";
    }).join("") + "</tbody>";
    tableEl.innerHTML = `<table>${thead}${tbody}</table>`;
  }

  await load();
})();

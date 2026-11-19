function formatProducts(products) {
  if (!Array.isArray(products) || products.length === 0) {
    return ["No products available right now."];
  }
  return products.map(
    (item) => `${item.name} — $${Number(item.price).toFixed(2)}`
  );
}

async function loadStorefront() {
  const statusEl = document.getElementById("status");
  const listEl = document.getElementById("product-list");
  if (!statusEl || !listEl) return;

  try {
    const response = await fetch("/api/products");
    if (!response.ok) throw new Error("Failed to reach API");
    const data = await response.json();
    statusEl.textContent = "Status: Connected to API";
    listEl.innerHTML = "";
    for (const line of formatProducts(data.products)) {
      const li = document.createElement("li");
      li.textContent = line;
      listEl.appendChild(li);
    }
  } catch (_err) {
    statusEl.textContent = "Status: Showing sample items";
    listEl.innerHTML = "";
    const fallback = formatProducts([
      { id: 1, name: "ShopNest Cotton Tee", price: 24.99 },
      { id: 2, name: "ShopNest Canvas Tote", price: 18.5 }
    ]);
    for (const line of fallback) {
      const li = document.createElement("li");
      li.textContent = line;
      listEl.appendChild(li);
    }
  }
}

if (typeof window !== "undefined") {
  window.addEventListener("DOMContentLoaded", loadStorefront);
}

if (typeof module !== "undefined") {
  module.exports = { formatProducts };
}

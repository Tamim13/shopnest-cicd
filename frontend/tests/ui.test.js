const test = require("node:test");
const assert = require("node:assert/strict");
const { formatProducts } = require("../src/app.js");

test("formatProducts formats items with dollar prices", () => {
  const result = formatProducts([{ id: 1, name: "Mug", price: 12 }]);
  assert.deepEqual(result, ["Mug — $12.00"]);
});

test("formatProducts handles empty product list", () => {
  const result = formatProducts([]);
  assert.deepEqual(result, ["No products available right now."]);
});

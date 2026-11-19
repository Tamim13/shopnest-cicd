const test = require("node:test");
const assert = require("node:assert/strict");
const http = require("node:http");
const app = require("../src/app");

function requestJson(port, path) {
  return new Promise((resolve, reject) => {
    http
      .get(`http://127.0.0.1:${port}${path}`, (res) => {
        let raw = "";
        res.on("data", (chunk) => {
          raw += chunk;
        });
        res.on("end", () => {
          resolve({ status: res.statusCode, body: JSON.parse(raw) });
        });
      })
      .on("error", reject);
  });
}

test("GET /health returns 200 and status UP", async () => {
  const server = app.listen(0);
  const { port } = server.address();
  try {
    const res = await requestJson(port, "/health");
    assert.equal(res.status, 200);
    assert.equal(res.body.status, "UP");
  } finally {
    server.close();
  }
});

test("GET /api/products returns product items", async () => {
  const server = app.listen(0);
  const { port } = server.address();
  try {
    const res = await requestJson(port, "/api/products");
    assert.equal(res.status, 200);
    assert.ok(Array.isArray(res.body.products));
    assert.ok(res.body.products.length > 0);
  } finally {
    server.close();
  }
});

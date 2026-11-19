const { Pool } = require("pg");

const pool = new Pool({
  host: process.env.DB_HOST || "127.0.0.1",
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME || "shopnest",
  user: process.env.DB_USER || "shopnest_user",
  password: process.env.DB_PASSWORD || ""
});

async function getProducts() {
  if (!process.env.DB_HOST) {
    return [
      { id: 1, name: "ShopNest Cotton Tee", price: 24.99 },
      { id: 2, name: "ShopNest Canvas Tote", price: 18.50 }
    ];
  }

  const result = await pool.query(
    "SELECT id, name, price FROM products ORDER BY id ASC"
  );
  return result.rows;
}

async function checkDatabase() {
  if (!process.env.DB_HOST) {
    return true;
  }
  await pool.query("SELECT 1");
  return true;
}

module.exports = {
  getProducts,
  checkDatabase
};

const express = require("express");
const cors = require("cors");
const { getProducts, checkDatabase } = require("./db");

const app = express();
app.use(cors());
app.use(express.json());

app.get("/health", async (_req, res) => {
  try {
    await checkDatabase();
    res.status(200).json({
      status: "UP",
      service: "shopnest-backend",
      commit: process.env.APP_COMMIT || "local"
    });
  } catch (err) {
    res.status(503).json({
      status: "DOWN",
      error: err.message
    });
  }
});

app.get("/api/products", async (_req, res) => {
  try {
    const products = await getProducts();
    res.status(200).json({ products });
  } catch (_err) {
    res.status(500).json({ error: "Could not fetch products" });
  }
});

module.exports = app;

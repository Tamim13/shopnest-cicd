CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  price NUMERIC(10, 2) NOT NULL
);

INSERT INTO products (name, price)
VALUES
  ('ShopNest Cotton Tee', 24.99),
  ('ShopNest Canvas Tote', 18.50),
  ('ShopNest Ceramic Mug', 14.00)
ON CONFLICT DO NOTHING;

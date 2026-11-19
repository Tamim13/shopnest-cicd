const app = require("./app");

const PORT = Number(process.env.PORT || 4001);

app.listen(PORT, "0.0.0.0", () => {
  console.log(`ShopNest backend running on port ${PORT}`);
});

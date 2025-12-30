const express = require("express");
const app = express();

app.use(express.json());

app.get("/health", (req, res) => {
  res.json({ status: "OK" });
});

app.get("/users", (req, res) => {
  res.json([{ id: 1, name: "Admin" }]);
});

app.listen(3000, () => {
  console.log("Backend running on port 3000");
});

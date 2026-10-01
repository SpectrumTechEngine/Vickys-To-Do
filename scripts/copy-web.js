// vickys-lists.html is the one file you edit; this copies it to www/ where Capacitor picks it up.
const fs = require("fs");
const path = require("path");

const root = path.join(__dirname, "..");
const www = path.join(root, "www");
fs.mkdirSync(www, { recursive: true });
fs.copyFileSync(path.join(root, "vickys-lists.html"), path.join(www, "index.html"));
console.log("Copied vickys-lists.html -> www/index.html");

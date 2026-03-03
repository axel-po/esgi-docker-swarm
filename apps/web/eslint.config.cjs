const tseslint = require("typescript-eslint");

module.exports = tseslint.config(
  { ignores: [".next/**", "dist/**"] },
  ...tseslint.configs.recommended
);

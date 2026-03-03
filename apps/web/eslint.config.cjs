const tseslint = require("typescript-eslint");

module.exports = tseslint.config(
  { ignores: [".next/**", "dist/**"] },
  {
    files: ["src/**/*.{ts,tsx}"],
    extends: tseslint.configs.recommended,
    languageOptions: {
      parserOptions: {
        project: "./tsconfig.json",
        tsconfigRootDir: __dirname,
      },
    },
  }
);

const tseslint = require("typescript-eslint");

module.exports = tseslint.config(
  { ignores: ["dist/**"] },
  {
    files: ["src/**/*.ts", "*.ts"],
    extends: tseslint.configs.recommended,
    languageOptions: {
      parserOptions: {
        project: "./tsconfig.json",
        tsconfigRootDir: __dirname,
      },
    },
  },
);

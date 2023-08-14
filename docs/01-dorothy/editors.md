# Conventions for Editors

Before you configure you editor, first ensure the necessary tooling is installed by running:

```bash
dorothy dev
```

## Visual Studio Code

Visual Studio Code is recommended, as VSCode will detect Dorothy's preferences and adapt accordingly, enabling automatic correct formatting and linting as you go.

When you open the Dorothy directory inside Visual Studio Code, you will get a prompt to install is recommended extensions, you should do so.

## All other editors

The other editors will require manual configuration, please make sure they are configured for the following:

-   [shfmt](https://github.com/mvdan/sh#shfmt)
-   [shellcheck](https://github.com/koalaman/shellcheck)
-   [prettier](https://prettier.io), [editor installation instructions](https://prettier.io/docs/en/editors.html)
-   [editorconfig](https://editorconfig.org), [editor installation instructions](https://editorconfig.org/#download)

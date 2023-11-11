# Contributing

## Deciding what to work on

1. [GitHub Issues](https://github.com/bevry/dorothy/issues) is for our roadmap items, you are free to get started on any item there.

1. For items that don't have a GitHub Issue, then join our [Bevry Software community on Discord](https://discord.gg/nQuXddV7VP) and discuss your proposal there.

1. Running `dorothy todos` will reveal plenty of small beginner friendly tasks that can be immediately worked on, without posting a GitHub Issue.

## Starting work

[Install Dorothy](https://github.com/bevry/dorothy/tree/master#install)

[Fork and clone](https://docs.github.com/en/get-started/quickstart/fork-a-repo) the [Dorothy repository](https://github.com/bevry/dorothy)

Update Dorothy to use your fork, and create a branch for your development:

```bash
cd "$DOROTHY"
git remote add fork 'the git url of your fork'
git fetch fork
git checkout -b dev-username # or issue-1337
```

## Developing your changes

Install all development dependencies:

```bash
dorothy dev
```

[Visual Studio Code](https://code.visualstudio.com) is recommended, as VSCode will detect Dorothy's preferences and adapt accordingly, enabling automatic correct formatting and linting as you go. When you open the Dorothy directory inside Visual Studio Code, you will get a prompt to install is recommended extensions, you should do so.

For other editors, we use [Trunk Check](https://docs.trunk.io/check) for linting and formatting. If Trunk is not available for your setup, use [shfmt](https://github.com/mvdan/sh#shfmt) and [ShellCheck](https://github.com/koalaman/shellcheck).

You can auto-format your changes via `dorothy format`, check them via `dorothy check`, and format and check via `dorothy lint`.

You can test whether or not your changes broke anything by running `dorothy test`.

For everything else, refer to the [documentation](https://github.com/bevry/dorothy/tree/master/docs).

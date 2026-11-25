# lsd-cluster

Manage several [lsd-docker](https://github.com/Fran6nd/lsd-docker)
servers as one: where each runs, how it is set up, and their state, from
one place.

One lsd-docker container is one server. lsd-cluster sits above them and
drives each through what lsd-docker already offers (`docker` and
`lsdctl`); it does not change the image.

Nothing is built yet. What is planned and decided lives in
[WORK.md](WORK.md).

## Developing

Once per clone, turn on the repository's hooks:

```sh
git config core.hooksPath githooks
```

`githooks/commit-msg` refuses a message that mentions Claude or AI or
carries a co-author or generated-by line. Rebase and cherry-pick skip
hooks; check a range with `githooks/commit-msg --range <range>`.

## License

GPL-3.0, as lsd-docker. See [LICENSE](LICENSE).

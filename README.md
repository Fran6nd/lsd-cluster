# lsd-cluster

Several [lsd-docker](https://github.com/Fran6nd/lsd-docker) servers in
one container, administered with one command, `lsdc`: set an instance
up on a port, run any `lsdctl` command on one, some or all of them, see
which are outdated and update them all. Admin work is shared: accounts
(who is admin) and bans are one database every instance uses.

Linux and macOS.

## How it is built

The cluster is one container running a Docker engine of its own; each
lsd-docker instance is a container inside it, with its own data volume,
plus one shared volume (`lsd-shared`) that holds every instance's
`auth.db` and `bans.db`. Everything lives on the cluster's one volume.

The cluster runs `--privileged` (an engine inside a container needs
it) and publishes a range of UDP ports, 32887-32906 by default; each
instance takes one of them.

lsd-cluster drives lsd-docker only through what lsd-docker offers
(`docker`, `lsdctl`, its `setup` and `update`); it does not change the
image.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/Fran6nd/lsd-cluster/main/install.sh | sh
```

`LSDC_PORTS=32887-32920` before `sh` widens the port range (it is fixed
when the cluster's container is created). The installer puts `lsdc` on
your PATH, short for `docker exec -it lsd-cluster lsdc`.

## Use

```sh
lsdc new ctf --port 32887       # a server on lsd-docker's defaults, started on 32887
lsdc new tdm                    # ...on the first free port
lsdc ctf setup                  # then lsdctl takes over: the wizard, or set, gamemode, map...
lsdc ls                         # every instance: port, state, version, outdated or not
lsdc ports                      # the cluster's ports: whose, and which are free
lsdc port tdm 32890             # move an instance (lsdc tdm set port 32890 is the same)

lsdc ctf status                 # any lsdctl command, on one instance
lsdc ctf,tdm set masterlist_enabled false
lsdc all say "restart in five"

lsdc account add alice admin    # an admin on every instance (password asked for)
lsdc account list

lsdc outdated                   # fetch the newest lsd-docker; who is behind
lsdc update all                 # move them to it (lsd-docker's own update, one by one)

lsdc stop tdm; lsdc start all; lsdc logs ctf -f
lsdc rm tdm [--keep-data]
```

An instance's port is the cluster's to keep: after any lsdctl command
(`setup` and `edit` may change it too), lsdc moves the instance to the
port its settings name, or puts the settings back if that port is
outside the range or another instance's.

## Developing

Once per clone, turn on the repository's hooks:

```sh
git config core.hooksPath githooks
```

`githooks/commit-msg` refuses a message that mentions Claude or AI or
carries a co-author or generated-by line. Rebase and cherry-pick skip
hooks; check a range with `githooks/commit-msg --range <range>`.

To try a change: `docker build -t lsd-cluster:dev .`, then run it as
install.sh does with that image. `LSDC_IMAGE` (inside the cluster)
names the lsd-docker image instances use; a local build of lsd-docker
gets in with `docker save <image> | docker exec -i <cluster> docker load`.

## License

GPL-3.0, as lsd-docker. See [LICENSE](LICENSE).

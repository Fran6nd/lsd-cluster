# Work in hand

The list of what the owner asked for and where each item stands, kept
here so it survives a change of AI session. Whoever works on an item
updates its line and adds a dated entry to the log at the end. This file
only says what is open, who has it, and what was decided.

States: TODO, DOING (who), REVIEW (waiting to be checked and committed),
DONE (commit), BLOCKED (on what).

## Decisions that bind every item

- lsd-cluster drives lsd-docker servers only through what lsd-docker
  offers (`docker`, `lsdctl`); it does not patch the image. What it
  needs and lsd-docker lacks is added to lsd-docker first.
- lsd-cluster is itself one container on one host; the lsd-docker
  servers run inside it (Docker in Docker), not beside it on the host.
- Linux and macOS hosts only; no Windows.
- Docker is the only record of the instances: a label (lsd-cluster.instance), the published port, the image's version label. No state file.
- Admin work is shared: every instance's auth_db, irc_console_db and bans_db point at the volume lsd-shared (/shared). Settings such as cap_groups stay per instance.
- An instance's host port equals its server's port (lsd-docker's update assumes it).
- Start simple: no layer that is not needed yet.

## Items

| # | Item | State |
|---|---|---|
| 1 | This file, README, LICENSE | DONE (uncommitted) |
| 2 | Scope: a CLI that creates lsd-docker instances and runs lsdctl on one, several or all of them | DONE (study 2026-11-25; decisions above) |
| 4 | commit-msg hook: no mention of Claude/AI in commit messages | DONE (uncommitted) |
| 6 | The cluster: Dockerfile (dind), install.sh, `lsdc` new/ls/outdated/update/start/stop/restart/logs/rm/account and lsdctl on one, several or all | DONE (tested live in a test cluster, see log) |
| 7 | Publish the image: CI building ghcr.io/fran6nd/lsd-cluster (install.sh pulls it), and tests (a smoke run like lsd-docker's dev/smoke.sh) | TODO |
| 8 | Shared content: maps, bot trees, catalog entries -- shared by every instance or per instance? | TODO (owner) |
| 9 | lsd-docker: a listed server cannot start without DNS (masterlist_connect raises, the server exits and restarts every 30 s) | TODO (in lsd-docker) |
| 10 | `new` only takes a port (lsd-docker's defaults, then lsdctl configures it); `ports`; `port <name> <P>`; the published port follows the settings after any lsdctl command | DONE (tested live) |
| 5 | Interactive terminal: a shell inside the cluster with autocomplete (instances, lsdctl commands) to move between instances and run commands on the current one | TODO |
| 3 | lsd-docker: `lsdctl account list\|add\|caps\|passwd\|rm` (patches 0003-accounts, 0004-console-redact) | DONE (lsd-docker fd004e5; reaches instances with lsd-docker's next release) |

## Log

- 2026-11-25: repository set up (README, WORK.md, LICENSE, .gitignore).
- 2026-11-25: studied lsd-docker for item 2. Instances are already parametrised (container name, volume, port) but nothing tracks them; lsdctl reaches one container; accounts live per volume in /data/rw/auth.db with no lsdctl command.
- 2026-11-25: owner: the servers are sub-containers of the cluster's container, all on one host. Costs noted: the outer container runs --privileged; UDP ports are published at both levels; the inner images and volumes live on the cluster's own volume.
- 2026-11-25: owner: Linux and macOS only.
- 2026-11-25: githooks/commit-msg added and enabled (core.hooksPath); no commits existed yet, so no message needed editing.
- 2026-11-25: owner: lsd-cluster provides an interactive terminal with autocomplete to navigate between instances (item 5).
- 2026-11-25: item 3 built in lsd-docker. auth.lua gains useradd/userpasswd/userdel and auth_account(s) (patch 0003); lsdctl account drives them over the console and checks the result by reading the account back. Found and fixed on the way: the socket/websocket/IRC consoles logged passwords of /register and /login in clear (patch 0004).
- 2026-11-25: owner: a command sets up an instance on a port; all admin work is shared across instances; list outdated instances and update them all.
- 2026-11-25: item 6 built and tried in a test cluster (dind on Docker Desktop, macOS): new on a given and on the first free port; refused a port outside the range, a taken name, a bad name; an admin made through one instance logs in on another; lsdctl on one, a list, all; stop/start; outdated and update (one, all) on a newer local image, keeping port, volumes, label and restart policy; instances back after the cluster restarts; rm with and without its data. The tests blocked the masterlist port (32886/udp) so nothing was announced, except perhaps for a few seconds after the cluster restart, before the rule was set again.
- 2026-11-25: owner: new takes only --port, lsdctl's config takes over; change ports, list them. Item 10 built and tested in a test cluster: new with and without --port, ports, port (and set port) to a free port, refused for a taken one or one outside the range; a port changed in the settings behind lsdc's back moved the instance on the next lsdc command, and was put back when the port was another instance's.

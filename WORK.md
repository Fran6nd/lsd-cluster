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
- Start simple: no layer that is not needed yet.

## Items

| # | Item | State |
|---|---|---|
| 1 | This file, README, LICENSE | DONE (uncommitted) |
| 2 | Scope: a host-side CLI that creates lsd-docker instances and runs lsdctl on one, several or all of them (e.g. make someone admin everywhere) | REVIEW (study done 2026-11-25; owner to confirm the open questions) |
| 4 | commit-msg hook: no mention of Claude/AI in commit messages | DONE (uncommitted) |
| 5 | Interactive terminal: a shell inside the cluster with autocomplete (instances, lsdctl commands) to move between instances and run commands on the current one | TODO |
| 3 | lsd-docker gap: no lsdctl command for accounts/admins (today: /register in game, then `lsdctl exec authcaps`) | TODO (in lsd-docker first) |

## Log

- 2026-11-25: repository set up (README, WORK.md, LICENSE, .gitignore).
- 2026-11-25: studied lsd-docker for item 2. Instances are already parametrised (container name, volume, port) but nothing tracks them; lsdctl reaches one container; accounts live per volume in /data/rw/auth.db with no lsdctl command.
- 2026-11-25: owner: the servers are sub-containers of the cluster's container, all on one host. Costs noted: the outer container runs --privileged; UDP ports are published at both levels; the inner images and volumes live on the cluster's own volume.
- 2026-11-25: owner: Linux and macOS only.
- 2026-11-25: githooks/commit-msg added and enabled (core.hooksPath); no commits existed yet, so no message needed editing.
- 2026-11-25: owner: lsd-cluster provides an interactive terminal with autocomplete to navigate between instances (item 5).

# mummy
An Emacs backup utility.

## Instructions
1. Define variables `mummy-backup-drives` and `mummy-backup-script` in `mummy.el`.
2. Define backup commands in `mummy.sh`.
3. To initiate backup, plug in one of the drives in `mummy-backup-drives` and execute command `M-x` `mummy-backup`, in any order.
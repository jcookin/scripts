# Scripts

General purposes scripts for various uses.

> All scripts should conform to [shellcheck](https://www.shellcheck.net/)

## Bootstrap

Configuration for each host.
To run, move into the host's directory and run the script of the same name.

### Creating a new host script

1. Use `#!/usr/bin/env bash` as the schebang (some OS configurations use a unique path for Bash, this is more robust)
2. source `config.sh` and `install_scripts.sh` to use pretty print function and shared install functions
3. `.txt` files for package installs
   1. Some install processes can leverage package lists to make configuration easier; Currently supported are:
      1. `packages.txt` - APT repository packages (if using custom PPA be sure to setup first)
         1. Rule: one per line; `#` comments out a package from being installed
      2. `vscode-extensions.txt` - VSCode extensions
         1. Rule: one per line
4. Suggest setting `set -x` for debugging until the new script is stabilized

### Design Philosophy

These bootstrap scripts should never downgrade existing system state.
The scripts should always run cleanly and successfully on an already bootstrapped machine.

Changes to the host machine should be reflected in these update scripts.
Ideally, packages and tools should be installed via this tool; However, manual experimentation is needed in most cases so it is expected these bootstrap scripts should be updated after the final state is manually obtained.

In working theory, a machine could be completely rebuilt and reconfigured with originally expected packages.
User configurations may not be entirely preserved in all cases.

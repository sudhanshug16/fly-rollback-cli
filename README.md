# fly-rollback-cli
A small CLI to rollback fly.io deploys

## Installation

To install(or update) the CLI, follow these steps:

1. Clone the repository:
```bash
git clone https://github.com/sudhanshug16/fly-rollback-cli.git
```
2. Navigate to the cloned directory:
```bash
cd fly-rollback-cli
```
3. Make the install script executable:
```bash
chmod +x install.sh
```
4. Run the install script with root permissions:
```bash
sudo ./install.sh
```

## Usage

### rollback

```bash
fly-rollback [version] [flags]
```

Where:
- `version` is the version to rollback to. It can be in the format `HEAD^n` or `vN`.
  - `HEAD^n`: This will rollback to the nth version from the latest. For example, `HEAD^1` will rollback to the previous version, `HEAD^2` will rollback to the version before the previous one, and so on.
- `flags` are any extra flags that need to be passed to fly.

Example:
```bash
fly-rollback HEAD^1 --env production
```
This will rollback to the previous version in the production environment.

**Disclaimer:** Only complete releases can be rolled back to. If the release's status is not complete, the rollback will not be performed.

### list releases

```bash
fly-rollback list
```
This will list all the releases.


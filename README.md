### Script for git pre-commit hook
The `pre-commit.sh` script checks for secrets using gitleaks (https://github.com/gitleaks/gitleaks)

#### Installation

1. Go to your repository where you want to install pre-coomit and run the command:
```bash
   curl -sS https://raw.githubusercontent.com/Njrk/pre-commit/main/pre-commit.sh | bash -
```
2. Enable gitleaks validation before committing:
```bash
git config hooks.gitleaks enable
```
> To disable gitleaks checks before committing:
> ```bash
> git config hooks.gitleaks disable
> ```

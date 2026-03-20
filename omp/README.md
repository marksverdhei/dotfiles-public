# Oh My Posh Configs

DRY configuration system for machine-specific Oh My Posh themes.

## Files

- **`base.omp.json`** - Base template with all common configuration
- **`colors.json`** - Machine name to session color mappings
- **`generate.py`** - Script to generate machine-specific configs
- **`*.omp.json`** - Generated machine-specific configs (do not edit directly)

## Usage

To modify the prompt configuration:

1. Edit `base.omp.json` for structural changes
2. Edit `colors.json` to add/modify machine colors
3. Run `./generate.py` to regenerate all configs

## Adding a new machine

```bash
# 1. Add the machine color to colors.json
echo '  "newmachine": "#123456"' >> colors.json

# 2. Regenerate configs
./generate.py
```

## Testing

After generation, test your config:

```bash
oh-my-posh print primary --config ./yourmachine.omp.json
```

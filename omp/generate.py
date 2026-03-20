#!/usr/bin/env python3
"""Generate machine-specific Oh My Posh configs from base template."""

import json
from pathlib import Path


def main():
    base_dir = Path(__file__).parent

    # Load base template
    with open(base_dir / "base.omp.json") as f:
        base_template = f.read()

    # Load color mappings
    try:
        with open(base_dir / "colors.json") as f:
            colors = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        colors = {
            "marksverdhei": "#ffe093",
        }


    # Generate configs for each machine
    for machine, color in colors.items():
        config = base_template.replace("SESSION_COLOR_PLACEHOLDER", color)
        output_path = base_dir / f"{machine}.omp.json"

        with open(output_path, "w") as f:
            f.write(config)

        print(f"Generated {output_path.name}")


if __name__ == "__main__":
    main()

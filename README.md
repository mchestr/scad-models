# OpenSCAD Models

A collection of parametric 3D models designed in OpenSCAD for 3D printing.

## Projects

| Project | Description |
|---------|-------------|
| [PSU + QuinLED Enclosure](projects/psu-quinled-enclosure/) | Combined enclosure for a 350W PSU and QuinLED-Dig-Quad controller |

## Structure

```
scad-models/
├── projects/           # Individual model projects
│   └── <project-name>/
│       ├── *.scad      # OpenSCAD source files
│       ├── exports/    # Exported STL files
│       └── README.md   # Project documentation
└── README.md
```

## Usage

1. Open any `.scad` file in [OpenSCAD](https://openscad.org/)
2. Use the Customizer panel to adjust parameters
3. Render (F6) and export to STL for printing

## Requirements

- [OpenSCAD](https://openscad.org/) 2019.05 or later (for Customizer support)

## License

See [LICENSE](LICENSE) for details.

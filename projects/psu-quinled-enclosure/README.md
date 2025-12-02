# PSU + QuinLED Enclosure

A combined enclosure for a 350W power supply and QuinLED-Dig-Quad LED controller, designed for LED lighting projects.

## Features

- Side-by-side layout with PSU and QuinLED controller
- Divider wall with U-shaped cable routing slits
- Ventilation slots on sides and honeycomb lid vents
- Sliding lid design (no screws needed)
- Antenna hole for WiFi/Zigbee connectivity
- LED cable slit for wire routing
- Parametric design - all dimensions customizable

## Components

| Component | Dimensions | Mounting |
|-----------|------------|----------|
| PSU | 215.9mm x 115mm x 50mm | M4 screws from bottom |
| QuinLED-Dig-Quad | 100mm x 48mm x 25mm | M2.5 standoffs |

## File Structure

| File | Description |
|------|-------------|
| `config.scad` | Shared parameters and helper modules |
| `body.scad` | Main enclosure body |
| `lid.scad` | Sliding lid with honeycomb vents |
| `grommet.scad` | Strain relief grommet for power cable |
| `assembled.scad` | Combined view of all parts |

## Parts to Print

- `body.scad` - Main enclosure body (240mm x 186mm x 64mm)
- `lid.scad` - Sliding lid, prints rails-up (240mm x 186mm x 4mm)
- `grommet.scad` - Strain relief grommet

## Assembly

1. Print body and lid
2. Mount PSU with M4 screws from bottom (countersunk)
3. Mount QuinLED board on standoffs with M2.5 screws
4. Route power cables through divider U-slits
5. Route LED cables through side slit
6. Install antenna through back hole
7. Insert grommet into power cable hole
8. Slide lid in from right side until it stops

## Customization

Edit `config.scad` to adjust parameters:

- **PSU Dimensions** - Adjust for different power supplies
- **QuinLED Board** - Board dimensions and mounting holes
- **Wire Routing** - Antenna, LED slit, and power hole sizes
- **Ventilation** - Slot dimensions and spacing

## Exports

Pre-exported STL files in `exports/` directory.

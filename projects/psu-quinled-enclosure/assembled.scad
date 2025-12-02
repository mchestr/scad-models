// Assembled View
// Shows all components in their assembled positions

include <config.scad>
use <body.scad>
use <lid.scad>
use <grommet.scad>

// Grommet dimensions (matching grommet.scad)
grommet_flange_thickness = 2;

// Body
enclosure_body();

// Lid in assembled position
translate([0, 0, outer_height])
    lid();

// Grommet at PSU power cable hole (front wall)
translate([-grommet_flange_thickness, psu_area_start_y + psu_width/2, wall + 15])
    rotate([0, 90, 0])
        grommet();

// Info
echo("=== ASSEMBLED VIEW ===");
echo("Total dimensions:", outer_length, "x", outer_width, "x", outer_height + wall);
echo("Lid slides in from RIGHT side (Y=max)");

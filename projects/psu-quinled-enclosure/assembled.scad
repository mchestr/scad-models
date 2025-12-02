// Assembled View
// Shows all components in their assembled positions

include <config.scad>
use <body.scad>
use <lid.scad>

// Body
enclosure_body();

// Lid in assembled position
translate([0, 0, outer_height])
    lid();

// Info
echo("=== ASSEMBLED VIEW ===");
echo("Total dimensions:", outer_length, "x", outer_width, "x", outer_height + wall);
echo("Lid slides in from RIGHT side (Y=max)");

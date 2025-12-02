// Sliding Lid
// Slides in from Y=max (right side) with rails engaging grooves

include <config.scad>

module lid() {
    // Rail dimensions (slightly smaller than groove for clearance)
    rail_actual_depth = rail_depth - rail_tolerance;
    rail_actual_height = rail_height - rail_tolerance;

    // Honeycomb vent area - near back, 100mm length
    vent_width = outer_width * vent_coverage;
    vent_length = 100;
    vent_start_x = outer_length - wall - vent_length - 10;  // 10mm from back wall
    vent_start_y = (outer_width - vent_width) / 2;

    // Honeycomb parameters
    hex_hole_dia = 8;
    hex_spacing = 11;

    difference() {
        union() {
            // Main lid plate - full outer dimensions
            cube([outer_length, outer_width, wall]);

            // Front rail (projects DOWN into front wall groove)
            translate([wall - rail_actual_depth, wall, -rail_actual_height])
                cube([rail_actual_depth, inner_width, rail_actual_height]);

            // Back rail (projects DOWN into back wall groove)
            translate([outer_length - wall, wall, -rail_actual_height])
                cube([rail_actual_depth, inner_width, rail_actual_height]);
        }

        // Corner chamfers on lid plate
        translate([0, 0, -0.1])
            corner_chamfer(chamfer_size, wall + 0.2);
        translate([0, outer_width, -0.1])
            rotate([0, 0, -90])
                corner_chamfer(chamfer_size, wall + 0.2);
        translate([outer_length, 0, -0.1])
            rotate([0, 0, 90])
                corner_chamfer(chamfer_size, wall + 0.2);
        translate([outer_length, outer_width, -0.1])
            rotate([0, 0, 180])
                corner_chamfer(chamfer_size, wall + 0.2);

        // Honeycomb ventilation pattern
        hex_rows_x = floor(vent_length / hex_spacing);
        hex_rows_y = floor(vent_width / (hex_spacing * 0.866));

        for (row = [0 : hex_rows_y]) {
            row_offset = (row % 2) * hex_spacing / 2;
            for (col = [0 : hex_rows_x]) {
                hx = vent_start_x + col * hex_spacing + row_offset;
                hy = vent_start_y + row * hex_spacing * 0.866;
                if (hx > vent_start_x + hex_hole_dia/2 &&
                    hx < vent_start_x + vent_length - hex_hole_dia/2 &&
                    hy > vent_start_y + hex_hole_dia/2 &&
                    hy < vent_start_y + vent_width - hex_hole_dia/2) {
                    translate([hx, hy, -1])
                        cylinder(d=hex_hole_dia, h=wall + 2, $fn=6);
                }
            }
        }
    }
}

// Lid in print orientation (rails facing up for no supports)
module lid_for_print() {
    translate([0, outer_width, wall])
        rotate([180, 0, 0])
            lid();
}

// Render for printing
lid_for_print();

// Info
echo("Lid dimensions:", outer_length, "x", outer_width, "x", wall);
echo("Print with rails facing UP (no supports needed)");

// Strain Relief Grommet
// Prints separately, snaps into cable holes

/* [Grommet Size] */
hole_dia = 8;          // Diameter of hole in enclosure
cable_dia = 5;         // Diameter of cable passing through
wall_thickness = 4;    // Enclosure wall thickness

/* [Grommet Design] */
flange_thickness = 2;  // Thickness of outer flange
flange_dia = 14;       // Diameter of outer flange
grip_length = 8;       // Length of strain relief grip section
slot_width = 1.5;      // Width of cable insertion slot

/* [Tolerances] */
hole_tolerance = 0.2;  // Clearance for hole fit
cable_tolerance = 0.3; // Clearance for cable

/* [Hidden] */
$fn = 60;

// Calculated
insert_dia = hole_dia - hole_tolerance;
cable_hole = cable_dia + cable_tolerance;

module grommet() {
    difference() {
        union() {
            // Outer flange (sits against outside of enclosure)
            cylinder(d=flange_dia, h=flange_thickness);

            // Insert section (goes through wall)
            translate([0, 0, flange_thickness])
                cylinder(d=insert_dia, h=wall_thickness);

            // Inner grip/strain relief section
            translate([0, 0, flange_thickness + wall_thickness])
                cylinder(d=insert_dia, h=grip_length);
        }

        // Cable hole through entire grommet
        translate([0, 0, -0.1])
            cylinder(d=cable_hole, h=flange_thickness + wall_thickness + grip_length + 0.2);

        // Slot for cable insertion (so you don't have to thread cable through)
        translate([0, -slot_width/2, -0.1])
            cube([flange_dia/2 + 1, slot_width, flange_thickness + wall_thickness + grip_length + 0.2]);
    }

    // Add grip ridges on inner section
    for (i = [0:2]) {
        translate([0, 0, flange_thickness + wall_thickness + 2 + i * 2.5])
            difference() {
                cylinder(d=insert_dia, h=1);
                translate([0, 0, -0.1])
                    cylinder(d=cable_hole - 0.5, h=1.2);
                // Keep the slot open through ridges
                translate([0, -slot_width/2, -0.1])
                    cube([flange_dia/2 + 1, slot_width, 1.2]);
            }
    }
}

// Render
grommet();

// Info
echo("Grommet for hole diameter:", hole_dia);
echo("Cable diameter:", cable_dia);
echo("Total length:", flange_thickness + wall_thickness + grip_length);

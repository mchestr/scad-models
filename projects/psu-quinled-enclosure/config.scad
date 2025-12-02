// Shared Configuration for PSU + QuinLED Enclosure
// Include this file in other modules to access parameters

/* [PSU Dimensions] */
psu_length = 215.9;  // 8.5 inches
psu_width = 115;
psu_height = 50;

/* [PSU Mounting Holes] */
psu_hole_spacing_length = 150;  // Center-to-center distance lengthwise
psu_hole_spacing_width = 50;    // Center-to-center distance widthwise
psu_screw_dia = 4;  // M4 screws from bottom
psu_screw_head_dia = 8;  // M4 screw head

/* [QuinLED Board] */
quinled_length = 100;
quinled_width = 48;
quinled_height = 25;
quinled_hole_edge = 3;
quinled_hole_offset_back_right = 13;  // Back-right hole is 13mm from right edge
quinled_hole_dia = 2.5;  // M2.5
quinled_standoff_dia = 6;
quinled_standoff_height = 6;

/* [Enclosure Settings] */
clearance = 3;  // General clearance around components
terminal_clearance = 10;  // Extra space at back for PSU terminal wiring
wall = 4;  // Wall thickness
lid_tolerance = 0.3;
chamfer_size = 3;  // Corner chamfer size

/* [Sliding Lid] */
rail_height = 4;  // Height of the rail/groove
rail_depth = 2;   // How far rail projects into groove
rail_tolerance = 0.3;  // Sliding clearance

/* [Layout] */
gap_between = 3;  // Gap between PSU and QuinLED section
divider_slit_width = 30;  // Slit in divider for power cables
divider_slit_height = 25; // Depth of U-slit from top

/* [Wire Routing] */
antenna_dia = 6;
led_slit_width = 80;
led_slit_height = 15;
psu_power_hole_dia = 10;  // PSU AC power cable hole

/* [Ventilation] */
slot_width = 3;
slot_length = 20;
slot_spacing = 6;
vent_coverage = 0.8;  // Percentage of lid width covered by honeycomb

/* [Hidden] */
$fn = 60;

// Calculated dimensions
quinled_section_width = quinled_width + clearance * 2;
inner_length = psu_length + clearance * 2 + terminal_clearance;
inner_width = psu_width + clearance * 2 + gap_between + quinled_section_width;
inner_height = psu_height + 10;  // 10mm clearance above PSU for wiring
outer_length = inner_length + wall * 2;
outer_width = inner_width + wall * 2;
outer_height = inner_height + wall;

// Area positions
psu_area_start_x = wall + clearance;
psu_area_start_y = wall + clearance;
psu_area_end_y = psu_area_start_y + psu_width;
quinled_area_start_y = psu_area_end_y + gap_between;
quinled_area_center_y = quinled_area_start_y + quinled_section_width / 2;

// QuinLED board position (20mm from back wall/antenna)
quinled_board_x = outer_length - wall - 20 - quinled_length;
quinled_board_y = quinled_area_start_y + clearance;

// Helper modules
module corner_chamfer(size, height) {
    linear_extrude(height)
        polygon([[0, 0], [size, 0], [0, size]]);
}

module cylinder_fillet(d, fillet_r) {
    rotate_extrude()
        translate([d/2 - fillet_r, 0, 0])
            difference() {
                square([fillet_r + 0.1, fillet_r + 0.1]);
                translate([fillet_r, fillet_r, 0])
                    circle(r=fillet_r);
            }
}

module internal_fillet(length, radius) {
    difference() {
        cube([length, radius, radius]);
        translate([-0.1, radius, radius])
            rotate([0, 90, 0])
                cylinder(r=radius, h=length + 0.2);
    }
}

module standoff(outer_d, inner_d, height, fillet_r=1.5) {
    difference() {
        union() {
            cylinder(d=outer_d, h=height);
            cylinder_fillet(outer_d, fillet_r);
        }
        translate([0, 0, -0.5])
            cylinder(d=inner_d, h=height + 1);
    }
}

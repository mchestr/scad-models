// Shared Configuration for PSU + QuinLED Enclosure
// Include this file in other modules to access parameters

/* [Print Compensation] */
// Shrinkage compensation factor (1.0 = none, 1.0135 = ~1.35% for PLA)
// If 150mm prints as 148mm: 150/148 = 1.0135
shrinkage_comp = 1.0135;

/* [PSU Dimensions] */
psu_length = 216;  // 8.5 inches
psu_width = 115;
psu_height = 50;

/* [PSU Mounting Holes] */
psu_hole_spacing_length = 150 * shrinkage_comp;  // Center-to-center distance lengthwise
psu_hole_spacing_width = 50 * shrinkage_comp;    // Center-to-center distance widthwise
psu_screw_dia = 4;  // M4 screws from bottom
psu_screw_head_dia = 8;  // M4 screw head

/* [QuinLED Board] */
quinled_length = 100 * shrinkage_comp;
quinled_width = 48 * shrinkage_comp;
quinled_height = 25;
quinled_hole_edge = 3 * shrinkage_comp;
quinled_hole_offset_back_right = 13 * shrinkage_comp;  // Back-right hole is 13mm from right edge
quinled_hole_dia = 2.5;  // M2.5
quinled_standoff_dia = 6;
quinled_standoff_height = 6;

/* [Enclosure Settings] */
clearance = 3;  // General clearance around components
terminal_clearance = 18;  // Extra space at back for PSU terminal wiring (actual measured offset)
wall = 4;  // Wall thickness
lid_tolerance = 0.3;
chamfer_size = 3;  // Corner chamfer size
internal_fillet_r = 3;  // Internal corner fillet radius for strength

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
antenna_offset_from_back = 20;   // Antenna hole distance from back wall
antenna_offset_from_top = 15;    // Antenna hole distance from top
led_slit_width = 80;
led_slit_height = 15;
psu_power_hole_dia = 10;         // PSU AC power cable hole
psu_power_hole_z = 15;           // Height of power cable hole from floor
extra_wire_hole_dia = 10;        // Extra wire routing hole diameter

/* [JST-SM Connectors] */
jst_width = 10;           // Width of JST-SM panel cutout
jst_height = 6;           // Height of JST-SM panel cutout
jst_spacing = 15;         // Spacing between connectors
jst_corner_radius = 1;    // Corner radius for rounded cutouts
jst_count = 4;            // Number of JST connectors

/* [QuinLED Placement] */
quinled_offset_from_back = 20;   // Distance from back wall to QuinLED board

/* [Ventilation] */
slot_width = 3;
slot_length = 20;
slot_spacing = 6;
slot_bridge = 2;      // Bridge between split slots for printability
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

// QuinLED board position
quinled_board_x = outer_length - wall - quinled_offset_from_back - quinled_length;
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

// Teardrop hole for horizontal holes (printable without supports)
// Oriented to extrude along X-axis
module teardrop_h(d, len) {
    r = d/2;
    rotate([0, 90, 0]) linear_extrude(len) rotate([0, 0, 90])
    union() {
        circle(r=r);
        polygon([[r*cos(45), r*sin(45)], [0, r*sqrt(2)], [r*cos(135), r*sin(135)]]);
    }
}

// Ventilation slot pattern with bridge for printability
// count: number of slots, spacing: center-to-center distance
module vent_slot_pattern(count, spacing, width, length, bridge, wall_thickness) {
    slot_half = (length - bridge) / 2;
    for (i = [0 : count - 1]) {
        for (z_off = [bridge/2 + slot_half/2, -bridge/2 - slot_half/2])
            translate([i * spacing, 0, z_off])
                cube([width, wall_thickness + 2, slot_half], center=true);
    }
}

// Rounded rectangle cutout (for panel mount connectors)
module rounded_rect_cutout(width, height, radius, depth) {
    hull() {
        for (x = [radius, width - radius])
            for (z = [radius, height - radius])
                translate([x, 0, z]) rotate([-90, 0, 0]) cylinder(r=radius, h=depth);
    }
}

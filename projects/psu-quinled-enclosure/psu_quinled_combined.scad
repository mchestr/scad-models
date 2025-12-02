// Combined PSU + QuinLED Enclosure
// Single box with PSU and QuinLED side by side
// Sliding lid design

/* [Part Selection] */
// Which part to render
part = "all"; // [body,lid,all,assembled,labeled]

/* [PSU Dimensions] */
psu_length = 215.9;  // 8.5 inches
psu_width = 115;
psu_height = 50;

/* [PSU Mounting Holes] */
psu_hole_spacing_length = 150;  // Center-to-center distance lengthwise
psu_hole_spacing_width = 50;    // Center-to-center distance widthwise
psu_screw_dia = 4;  // M4 screws from bottom
psu_screw_head_dia = 8;  // M4 screw head

/* [PSU Fan] */
fan_diameter = 60;
fan_from_front = 48;  // X offset from front of PSU
fan_from_left = 38;   // Y offset from left edge of PSU

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
clearance = 5;  // General clearance around components
terminal_clearance = 15;  // Extra space at back for PSU terminal wiring
wall = 3;
lid_tolerance = 0.3;
chamfer_size = 3;  // Corner chamfer size

/* [Sliding Lid] */
rail_height = 4;    // Height of the rail/groove
rail_depth = 2.5;   // How far rail projects into groove
rail_tolerance = 0.2;  // Sliding clearance

/* [Layout - Side by Side] */
gap_between = 5;  // Gap between PSU and QuinLED section
divider_slit_width = 30;  // Slit in divider for power cables
divider_slit_height = 25; // Depth of U-slit from top

/* [Wire Routing] */
antenna_dia = 6;
led_slit_width = 80;
led_slit_height = 15;
psu_power_hole_dia = 8;  // PSU AC power cable hole

/* [Ventilation] */
slot_width = 3;
slot_length = 20;
slot_spacing = 6;

/* [Hidden] */
$fn = 60;

// Calculated dimensions
quinled_section_width = quinled_width + clearance * 2;
inner_length = psu_length + clearance * 2 + terminal_clearance;
inner_width = psu_width + clearance * 2 + gap_between + quinled_section_width;
inner_height = psu_height + clearance;
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

// Standoff module (cylindrical with base fillet)
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

// Vertical corner chamfer cut (triangular prism)
module corner_chamfer(size, height) {
    linear_extrude(height)
        polygon([[0, 0], [size, 0], [0, size]]);
}

// Fillet for cylinder base (quarter torus)
module cylinder_fillet(d, fillet_r) {
    rotate_extrude()
        translate([d/2 - fillet_r, 0, 0])
            difference() {
                square([fillet_r + 0.1, fillet_r + 0.1]);
                translate([fillet_r, fillet_r, 0])
                    circle(r=fillet_r);
            }
}

// Internal fillet for walls (runs along an edge)
module internal_fillet(length, radius) {
    difference() {
        cube([length, radius, radius]);
        translate([-0.1, radius, radius])
            rotate([0, 90, 0])
                cylinder(r=radius, h=length + 0.2);
    }
}

// Main enclosure body
module enclosure_body() {
    // PSU mount positions (centered on PSU with specified center-to-center spacing)
    psu_center_x = psu_area_start_x + psu_length / 2;
    psu_center_y = psu_area_start_y + psu_width / 2;
    psu_mounts = [
        [psu_center_x - psu_hole_spacing_length / 2, psu_center_y - psu_hole_spacing_width / 2],
        [psu_center_x - psu_hole_spacing_length / 2, psu_center_y + psu_hole_spacing_width / 2],
        [psu_center_x + psu_hole_spacing_length / 2, psu_center_y - psu_hole_spacing_width / 2],
        [psu_center_x + psu_hole_spacing_length / 2, psu_center_y + psu_hole_spacing_width / 2]
    ];

    // Rail groove position (near top of walls)
    rail_z = outer_height - rail_height;

    difference() {
        // Outer shell
        cube([outer_length, outer_width, outer_height]);

        // Inner cavity
        translate([wall, wall, wall])
            cube([inner_length, inner_width, inner_height + 1]);

        // Lid sliding grooves on front wall (X=0, inner face)
        translate([wall - rail_depth, wall - 0.1, rail_z])
            cube([rail_depth + 0.1, inner_width + 0.2, rail_height + 1]);

        // Lid sliding grooves on back wall (X=max, inner face)
        translate([outer_length - wall - 0.1, wall - 0.1, rail_z])
            cube([rail_depth + 0.1, inner_width + 0.2, rail_height + 1]);

        // Corner chamfers
        // Front-left (X=0, Y=0)
        translate([0, 0, -0.1])
            corner_chamfer(chamfer_size, outer_height + 0.2);
        // Front-right (X=0, Y=max)
        translate([0, outer_width, -0.1])
            rotate([0, 0, -90])
                corner_chamfer(chamfer_size, outer_height + 0.2);
        // Back-left (X=max, Y=0)
        translate([outer_length, 0, -0.1])
            rotate([0, 0, 90])
                corner_chamfer(chamfer_size, outer_height + 0.2);
        // Back-right (X=max, Y=max)
        translate([outer_length, outer_width, -0.1])
            rotate([0, 0, 180])
                corner_chamfer(chamfer_size, outer_height + 0.2);

        // PSU mounting holes through floor with tapered countersink
        for (pos = psu_mounts) {
            // Through hole
            translate([pos[0], pos[1], -0.1])
                cylinder(d=psu_screw_dia + 0.5, h=wall + 0.2);
            // Tapered countersink on bottom (outside)
            translate([pos[0], pos[1], -0.1])
                cylinder(d1=psu_screw_head_dia + 1, d2=psu_screw_dia + 0.5, h=2.5);
        }

        // FRONT WALL (X=0): PSU power cable hole (8mm)
        translate([-1, psu_area_start_y + psu_width/2, wall + 15])
            rotate([0, 90, 0])
                cylinder(d=psu_power_hole_dia, h=wall + 2);

        // LEFT SIDE (Y=0): PSU ventilation slots with center bridge
        slot_bridge = 2;  // Bridge thickness
        slot_half = (slot_length - slot_bridge) / 2;
        for (i = [0:7]) {
            // Upper half of slot
            translate([outer_length/2 - 3.5 * slot_spacing + i * slot_spacing, -0.5, wall + psu_height/2 + slot_bridge/2 + slot_half/2])
                cube([slot_width, wall + 1, slot_half], center=true);
            // Lower half of slot
            translate([outer_length/2 - 3.5 * slot_spacing + i * slot_spacing, -0.5, wall + psu_height/2 - slot_bridge/2 - slot_half/2])
                cube([slot_width, wall + 1, slot_half], center=true);
        }

        // BACK WALL (X=max): PSU ventilation slots with center bridge
        for (i = [0:5]) {
            // Upper half of slot
            translate([outer_length + 0.5, psu_area_start_y + psu_width/2 - 2.5 * slot_spacing + i * slot_spacing, wall + psu_height/2 + slot_bridge/2 + slot_half/2])
                cube([wall + 1, slot_width, slot_half], center=true);
            // Lower half of slot
            translate([outer_length + 0.5, psu_area_start_y + psu_width/2 - 2.5 * slot_spacing + i * slot_spacing, wall + psu_height/2 - slot_bridge/2 - slot_half/2])
                cube([wall + 1, slot_width, slot_half], center=true);
        }

        // RIGHT SIDE (Y=max): QuinLED LED cable slit (aligned with board, rounded corners)
        slit_corner_r = 3;
        led_slit_x = quinled_board_x + quinled_length/2 - led_slit_width/2;  // Centered on QuinLED board
        translate([0, outer_width - wall - 1, 0])
            hull() {
                translate([led_slit_x + slit_corner_r, 0, wall + quinled_standoff_height + 5 + slit_corner_r])
                    rotate([-90, 0, 0])
                        cylinder(r=slit_corner_r, h=wall + 2);
                translate([led_slit_x + led_slit_width - slit_corner_r, 0, wall + quinled_standoff_height + 5 + slit_corner_r])
                    rotate([-90, 0, 0])
                        cylinder(r=slit_corner_r, h=wall + 2);
                translate([led_slit_x + slit_corner_r, 0, wall + quinled_standoff_height + 5 + led_slit_height - slit_corner_r])
                    rotate([-90, 0, 0])
                        cylinder(r=slit_corner_r, h=wall + 2);
                translate([led_slit_x + led_slit_width - slit_corner_r, 0, wall + quinled_standoff_height + 5 + led_slit_height - slit_corner_r])
                    rotate([-90, 0, 0])
                        cylinder(r=slit_corner_r, h=wall + 2);
            }

        // RIGHT SIDE (Y=max): Antenna hole (towards back corner, higher up)
        translate([outer_length - wall - 20, outer_width - wall - 1, outer_height - 15])
            rotate([-90, 0, 0])
                cylinder(d=antenna_dia, h=wall + 2);
    }

    // QuinLED mounting standoffs
    quinled_mounts = [
        [quinled_board_x + quinled_hole_edge, quinled_board_y + quinled_hole_edge],
        [quinled_board_x + quinled_length - quinled_hole_edge, quinled_board_y + quinled_hole_edge],
        [quinled_board_x + quinled_hole_edge, quinled_board_y + quinled_width - quinled_hole_edge],
        [quinled_board_x + quinled_length - quinled_hole_edge, quinled_board_y + quinled_width - quinled_hole_offset_back_right]
    ];
    for (pos = quinled_mounts) {
        translate([pos[0], pos[1], wall])
            standoff(quinled_standoff_dia, quinled_hole_dia, quinled_standoff_height);
    }

    // Divider wall with U-shaped cable slits
    divider_height = inner_height * 0.6;
    difference() {
        translate([wall, psu_area_end_y, wall])
            cube([inner_length, gap_between, divider_height]);

        // Front U-slit
        translate([quinled_board_x + quinled_hole_edge, psu_area_end_y - 1, wall + divider_height - divider_slit_height])
            cube([divider_slit_width, gap_between + 2, divider_slit_height + 1]);

        // Back U-slit
        translate([quinled_board_x + quinled_length - quinled_hole_edge - divider_slit_width, psu_area_end_y - 1, wall + divider_height - divider_slit_height])
            cube([divider_slit_width, gap_between + 2, divider_slit_height + 1]);
    }

    // Internal fillets where walls meet floor (strengthens corners)
    floor_fillet = 2;
    // Front wall (X=0 side, along Y)
    translate([wall, wall, wall])
        internal_fillet(inner_width, floor_fillet);
    // Back wall (X=max side, along Y)
    translate([outer_length - wall, wall + inner_width, wall])
        rotate([0, 0, 180])
            internal_fillet(inner_width, floor_fillet);
    // Left wall (Y=0 side, along X)
    translate([wall + inner_length, wall, wall])
        rotate([0, 0, -90])
            internal_fillet(inner_length, floor_fillet);
    // Right wall (Y=max side, along X)
    translate([wall, outer_width - wall, wall])
        rotate([0, 0, 90])
            internal_fillet(inner_length, floor_fillet);

    // End stop for sliding lid (left side, Y=0)
    // Small block at the end of the rail grooves to stop the lid
    translate([wall - rail_depth, wall - 0.5, outer_height - rail_height])
        cube([rail_depth, 0.5, rail_height]);
    translate([outer_length - wall, wall - 0.5, outer_height - rail_height])
        cube([rail_depth, 0.5, rail_height]);
}

// Sliding lid module
module lid() {
    fan_x = psu_area_start_x + fan_from_front;
    fan_y = psu_area_start_y + fan_from_left;
    quinled_center_x = quinled_board_x + quinled_length/2;
    quinled_center_y = quinled_board_y + quinled_width/2;

    // Rail dimensions (slightly smaller than groove for clearance)
    rail_actual_depth = rail_depth - rail_tolerance;
    rail_actual_height = rail_height - rail_tolerance;

    difference() {
        union() {
            // Main lid plate
            cube([outer_length, outer_width, wall]);

            // Front rail (slides into front wall groove)
            translate([wall - rail_actual_depth, wall, wall])
                cube([rail_actual_depth, inner_width, rail_actual_height]);

            // Back rail (slides into back wall groove)
            translate([outer_length - wall, wall, wall])
                cube([rail_actual_depth, inner_width, rail_actual_height]);
        }

        // Corner chamfers
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

        // Fan grille - hexagonal hole pattern (honeycomb)
        hex_hole_dia = 6;
        hex_spacing = 8;
        hex_rows = floor(fan_diameter / hex_spacing);
        for (row = [-hex_rows/2 : hex_rows/2]) {
            row_offset = (abs(row) % 2) * hex_spacing / 2;
            for (col = [-hex_rows/2 : hex_rows/2]) {
                hx = col * hex_spacing + row_offset;
                hy = row * hex_spacing * 0.866;  // sqrt(3)/2 for hex packing
                // Only place holes within fan radius
                if (sqrt(hx*hx + hy*hy) < fan_diameter/2 - 2) {
                    translate([fan_x + hx, fan_y + hy, -1])
                        cylinder(d=hex_hole_dia, h=wall + 2, $fn=6);
                }
            }
        }

        // QuinLED ventilation holes
        for (i = [-2:2]) {
            for (j = [-3:3]) {
                translate([quinled_center_x + i * 10, quinled_center_y + j * 12, -1])
                    cylinder(d=4, h=wall + 2);
            }
        }
    }
}

// Lid in print orientation (rails facing up for no supports)
module lid_for_print() {
    translate([0, outer_width, wall + rail_height - rail_tolerance])
        rotate([180, 0, 0])
            lid();
}

// Lid positioned for assembly view
module lid_assembled() {
    translate([0, 0, outer_height - wall])
        lid();
}

// Debug orientation labels
module orientation_labels() {
    color("red") {
        translate([0, outer_width/2, outer_height + 10])
            rotate([90, 0, 90])
                linear_extrude(1)
                    text("FRONT (X=0)", size=8, halign="center");
        translate([outer_length, outer_width/2, outer_height + 10])
            rotate([90, 0, -90])
                linear_extrude(1)
                    text("BACK (X=max)", size=8, halign="center");
    }
    color("green") {
        translate([outer_length/2, 0, outer_height + 10])
            rotate([90, 0, 0])
                linear_extrude(1)
                    text("LEFT/PSU (Y=0)", size=8, halign="center");
        translate([outer_length/2, outer_width, outer_height + 10])
            rotate([90, 0, 180])
                linear_extrude(1)
                    text("RIGHT/QUINLED (Y=max)", size=8, halign="center");
    }
    color("blue") {
        translate([outer_length + 20, outer_width/2, 0]) {
            cylinder(d=3, h=30);
            translate([0, 0, 30]) cylinder(d1=6, d2=0, h=10);
            translate([0, 0, 45]) rotate([90, 0, 90]) linear_extrude(1) text("+X", size=8, halign="center");
        }
        translate([outer_length/2, outer_width + 20, 0]) {
            cylinder(d=3, h=30);
            translate([0, 0, 30]) cylinder(d1=6, d2=0, h=10);
            translate([0, 0, 45]) rotate([90, 0, 0]) linear_extrude(1) text("+Y", size=8, halign="center");
        }
    }
}

// Render based on part selection
if (part == "body" || part == "all") {
    enclosure_body();
}

if (part == "lid" || part == "all") {
    translate([0, outer_width * 2 + 20, 0])
        lid_for_print();
}

if (part == "assembled") {
    enclosure_body();
    lid_assembled();
    orientation_labels();
}

if (part == "labeled") {
    enclosure_body();
    orientation_labels();
}

// Info output
echo("Enclosure outer dimensions:", outer_length, "x", outer_width, "x", outer_height + wall);
echo("Total height with lid:", outer_height + wall);
echo("Lid slides in from RIGHT side (Y=max)");

// Combined PSU + QuinLED Enclosure
// Single box with PSU and QuinLED side by side

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
clearance = 4;
terminal_clearance = 15;  // Extra space at back for PSU terminal wiring
wall = 3;
lid_tolerance = 0.3;
chamfer_size = 3;  // Corner chamfer size

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

/* [Lid Screws] */
lid_screw_dia = 3;  // M3 screws
lid_screw_head_dia = 6;

/* [Hidden] */
$fn = 60;
snap_height = 4;
snap_depth = 1.5;

// Calculated dimensions
quinled_section_width = quinled_width + clearance * 2;
inner_length = psu_length + clearance * 2 + terminal_clearance;  // Extra space at back for terminals
inner_width = psu_width + clearance * 2 + gap_between + quinled_section_width;
inner_height = psu_height + clearance;
outer_length = inner_length + wall * 2;
outer_width = inner_width + wall * 2;
outer_height = inner_height + wall;

// Area positions
psu_area_start_y = wall + clearance;
psu_area_end_y = wall + clearance + psu_width;
quinled_area_start_y = psu_area_end_y + gap_between;
quinled_area_center_y = quinled_area_start_y + quinled_section_width / 2;

// QuinLED board position (20mm from back wall/antenna)
quinled_board_x = outer_length - wall - 20 - quinled_length;
quinled_board_y = quinled_area_start_y + clearance;

// Corner boss size for lid screws
corner_boss_size = 12;

// Lid screw positions (PSU-side screws are offset to outer corner of L-boss)
psu_boss_leg_calc = clearance + 2;  // Must match psu_boss_leg in enclosure_body
lid_screw_positions = [
    [wall + psu_boss_leg_calc/2, wall + psu_boss_leg_calc/2],  // Front-left (L-shaped)
    [outer_length - wall - psu_boss_leg_calc/2, wall + psu_boss_leg_calc/2],  // Back-left (L-shaped)
    [wall + corner_boss_size/2, outer_width - wall - corner_boss_size/2],  // Front-right (square)
    [outer_length - wall - corner_boss_size/2, outer_width - wall - corner_boss_size/2]  // Back-right (square)
];

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

// Corner screw boss (square with fillets, connects to walls)
module corner_screw_boss(size, screw_d, height, corner, fillet_r=2) {
    // corner: 0=front-left, 1=front-right, 2=back-left, 3=back-right
    // Fillets on exposed edges (not touching walls) and base
    difference() {
        union() {
            cube([size, size, height]);
            // Base fillet on exposed edges based on corner position
            if (corner == 0) {
                // Front-left: exposed edges at +X and +Y
                translate([size, 0, 0]) rotate([0, 0, 90]) internal_fillet(size, fillet_r);
                translate([0, size, 0]) internal_fillet(size, fillet_r);
            } else if (corner == 1) {
                // Front-right: exposed edges at +X and -Y (which is at Y=0 in local coords)
                translate([size, 0, 0]) rotate([0, 0, 90]) internal_fillet(size, fillet_r);
                translate([size, 0, 0]) rotate([0, 0, 180]) internal_fillet(size, fillet_r);
            } else if (corner == 2) {
                // Back-left: exposed edges at -X and +Y
                translate([0, size, 0]) internal_fillet(size, fillet_r);
                rotate([0, 0, -90]) internal_fillet(size, fillet_r);
            } else {
                // Back-right: exposed edges at -X and -Y
                translate([size, 0, 0]) rotate([0, 0, 180]) internal_fillet(size, fillet_r);
                rotate([0, 0, -90]) internal_fillet(size, fillet_r);
            }
        }
        // Screw hole in center of boss
        translate([size/2, size/2, -0.5])
            cylinder(d=screw_d, h=height + 1);
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

// Rounded cable hole with strain relief collar
module cable_hole_with_relief(dia, wall_thickness, collar_height=3, collar_width=2) {
    union() {
        // Main hole
        cylinder(d=dia, h=wall_thickness + 2);
        // External collar for zip-tie
        translate([0, 0, wall_thickness])
            difference() {
                cylinder(d=dia + collar_width*2, h=collar_height);
                translate([0, 0, -0.1])
                    cylinder(d=dia, h=collar_height + 0.2);
                // Zip-tie slot
                translate([0, 0, collar_height/2])
                    rotate_extrude()
                        translate([dia/2 + collar_width/2, 0, 0])
                            circle(d=collar_width * 0.7);
            }
    }
}

// Main enclosure body
module enclosure_body() {
    // PSU mount positions (centered on PSU with specified center-to-center spacing)
    psu_center_x = wall + clearance + psu_length / 2;
    psu_center_y = psu_area_start_y + psu_width / 2;
    psu_mounts = [
        [psu_center_x - psu_hole_spacing_length / 2, psu_center_y - psu_hole_spacing_width / 2],
        [psu_center_x - psu_hole_spacing_length / 2, psu_center_y + psu_hole_spacing_width / 2],
        [psu_center_x + psu_hole_spacing_length / 2, psu_center_y - psu_hole_spacing_width / 2],
        [psu_center_x + psu_hole_spacing_length / 2, psu_center_y + psu_hole_spacing_width / 2]
    ];

    difference() {
        // Outer shell
        cube([outer_length, outer_width, outer_height]);

        // Inner cavity
        translate([wall, wall, wall])
            cube([inner_length, inner_width, inner_height + 1]);

        // Corner chamfers
        // Front-left (X=0, Y=0)
        translate([0, 0, -0.1])
            rotate([0, 0, 0])
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

        // RIGHT SIDE (Y=max): QuinLED LED cable slit (rounded corners to reduce stress)
        slit_corner_r = 3;
        translate([0, outer_width - wall - 1, 0])
            hull() {
                translate([outer_length/2 - led_slit_width/2 + slit_corner_r, 0, wall + quinled_standoff_height + 5 + slit_corner_r])
                    rotate([-90, 0, 0])
                        cylinder(r=slit_corner_r, h=wall + 2);
                translate([outer_length/2 + led_slit_width/2 - slit_corner_r, 0, wall + quinled_standoff_height + 5 + slit_corner_r])
                    rotate([-90, 0, 0])
                        cylinder(r=slit_corner_r, h=wall + 2);
                translate([outer_length/2 - led_slit_width/2 + slit_corner_r, 0, wall + quinled_standoff_height + 5 + led_slit_height - slit_corner_r])
                    rotate([-90, 0, 0])
                        cylinder(r=slit_corner_r, h=wall + 2);
                translate([outer_length/2 + led_slit_width/2 - slit_corner_r, 0, wall + quinled_standoff_height + 5 + led_slit_height - slit_corner_r])
                    rotate([-90, 0, 0])
                        cylinder(r=slit_corner_r, h=wall + 2);
            }

        // BACK WALL (X=max): Antenna hole
        translate([outer_length - wall - 1, quinled_area_center_y, wall + quinled_standoff_height + 15])
            rotate([0, 90, 0])
                cylinder(d=antenna_dia, h=wall + 2);

        // Rubber feet recesses (for adhesive bumper feet)
        feet_dia = 12;      // Diameter of rubber foot
        feet_depth = 1.5;   // Recess depth
        feet_inset = 20;    // Distance from edges
        feet_positions = [
            [feet_inset, feet_inset],
            [outer_length - feet_inset, feet_inset],
            [feet_inset, outer_width - feet_inset],
            [outer_length - feet_inset, outer_width - feet_inset]
        ];
        for (pos = feet_positions) {
            translate([pos[0], pos[1], -0.1])
                cylinder(d=feet_dia, h=feet_depth + 0.1);
        }
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

    // Strain relief collars for cable holes
    strain_collar_height = 4;
    strain_collar_width = 3;
    zip_groove_depth = 1.5;

    // PSU power cable strain relief (front wall, external)
    translate([0, psu_area_start_y + psu_width/2, wall + 15])
        rotate([0, -90, 0])
            difference() {
                cylinder(d=psu_power_hole_dia + strain_collar_width*2, h=strain_collar_height);
                translate([0, 0, -0.1])
                    cylinder(d=psu_power_hole_dia, h=strain_collar_height + 0.2);
                // Zip-tie groove
                translate([0, 0, strain_collar_height/2])
                    rotate_extrude()
                        translate([psu_power_hole_dia/2 + strain_collar_width - zip_groove_depth, 0, 0])
                            circle(d=zip_groove_depth * 1.5);
            }

    // Antenna cable strain relief (back wall, external)
    translate([outer_length, quinled_area_center_y, wall + quinled_standoff_height + 15])
        rotate([0, 90, 0])
            difference() {
                cylinder(d=antenna_dia + strain_collar_width*2, h=strain_collar_height);
                translate([0, 0, -0.1])
                    cylinder(d=antenna_dia, h=strain_collar_height + 0.2);
                // Zip-tie groove
                translate([0, 0, strain_collar_height/2])
                    rotate_extrude()
                        translate([antenna_dia/2 + strain_collar_width - zip_groove_depth, 0, 0])
                            circle(d=zip_groove_depth * 1.5);
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

    // Snap-fit ledge for lid
    translate([wall - 1, wall - 1, outer_height - 2])
        difference() {
            cube([inner_length + 2, inner_width + 2, 2]);
            translate([2, 2, -0.5])
                cube([inner_length - 2, inner_width - 2, 3]);
        }

    // Square corner screw bosses for lid
    // PSU-side bosses are L-shaped to avoid PSU while keeping screw hole
    psu_boss_leg = clearance + 2;  // Width of L-legs (enough for wall connection)

    // Front-left corner (L-shaped for PSU clearance)
    translate([wall, wall, wall])
        difference() {
            union() {
                // Leg along front wall (X direction)
                cube([corner_boss_size, psu_boss_leg, inner_height]);
                // Leg along left wall (Y direction)
                cube([psu_boss_leg, corner_boss_size, inner_height]);
            }
            // Screw hole in the outer corner (away from PSU)
            translate([psu_boss_leg/2, psu_boss_leg/2, -0.5])
                cylinder(d=lid_screw_dia, h=inner_height + 1);
        }

    // Front-right corner (QuinLED side - full square boss)
    translate([wall, outer_width - wall - corner_boss_size, wall])
        corner_screw_boss(corner_boss_size, lid_screw_dia, inner_height, 1);

    // Back-left corner (L-shaped for PSU clearance)
    translate([outer_length - wall - corner_boss_size, wall, wall])
        difference() {
            union() {
                // Leg along back wall (X direction)
                translate([corner_boss_size - psu_boss_leg, 0, 0])
                    cube([psu_boss_leg, corner_boss_size, inner_height]);
                // Leg along left wall (Y direction)
                cube([corner_boss_size, psu_boss_leg, inner_height]);
            }
            // Screw hole in the outer corner (away from PSU)
            translate([corner_boss_size - psu_boss_leg/2, psu_boss_leg/2, -0.5])
                cylinder(d=lid_screw_dia, h=inner_height + 1);
        }

    // Back-right corner (QuinLED side - full square boss)
    translate([outer_length - wall - corner_boss_size, outer_width - wall - corner_boss_size, wall])
        corner_screw_boss(corner_boss_size, lid_screw_dia, inner_height, 3);

    // Internal fillets where walls meet floor (strengthens corners)
    floor_fillet = 2;
    // Front wall (X=0 side, along Y)
    translate([wall, wall, wall])
        rotate([0, 0, 0])
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
}

// Lid module
module lid() {
    lid_inner_length = inner_length - lid_tolerance * 2;
    lid_inner_width = inner_width - lid_tolerance * 2;
    fan_x = wall + clearance + fan_from_front;
    fan_y = psu_area_start_y + fan_from_left;
    quinled_center_x = quinled_board_x + quinled_length/2;
    quinled_center_y = quinled_board_y + quinled_width/2;

    difference() {
        union() {
            // Main lid plate
            cube([outer_length, outer_width, wall]);

            // Inner lip for snap fit (with corner cutouts for screw bosses)
            translate([wall + lid_tolerance, wall + lid_tolerance, wall])
                difference() {
                    cube([lid_inner_length, lid_inner_width, snap_height]);
                    // Inner cutout
                    translate([2, 2, -0.5])
                        cube([lid_inner_length - 4, lid_inner_width - 4, snap_height + 1]);
                    // Corner cutouts for screw bosses
                    boss_clearance = corner_boss_size + lid_tolerance * 2;
                    translate([-lid_tolerance - 0.1, -lid_tolerance - 0.1, -0.5])
                        cube([boss_clearance, boss_clearance, snap_height + 1]);
                    translate([lid_inner_length - boss_clearance + lid_tolerance + 0.1, -lid_tolerance - 0.1, -0.5])
                        cube([boss_clearance, boss_clearance, snap_height + 1]);
                    translate([-lid_tolerance - 0.1, lid_inner_width - boss_clearance + lid_tolerance + 0.1, -0.5])
                        cube([boss_clearance, boss_clearance, snap_height + 1]);
                    translate([lid_inner_length - boss_clearance + lid_tolerance + 0.1, lid_inner_width - boss_clearance + lid_tolerance + 0.1, -0.5])
                        cube([boss_clearance, boss_clearance, snap_height + 1]);
                }

            // Screw hole reinforcement
            for (pos = lid_screw_positions) {
                translate([pos[0], pos[1], 0])
                    cylinder(d=lid_screw_head_dia + 2, h=wall);
            }
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

        // Screw holes with tapered countersink
        for (pos = lid_screw_positions) {
            // Tapered hole - wide at bottom (Z=0), narrow at top
            translate([pos[0], pos[1], -0.1])
                cylinder(d1=lid_screw_head_dia + 1, d2=lid_screw_dia + 0.5, h=wall + 0.2);
        }
    }
}

// Lid in print orientation (flipped so lip faces UP for no supports)
module lid_for_print() {
    translate([0, outer_width, wall + snap_height])
        rotate([180, 0, 0])
            lid();
}

// Lid positioned for assembly view
module lid_assembled() {
    translate([0, -outer_width, outer_height - wall * 2])
        translate([0, outer_width, wall])
            mirror([0, 1, 0])
                rotate([180, 0, 0])
                    translate([0, 0, -wall])
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

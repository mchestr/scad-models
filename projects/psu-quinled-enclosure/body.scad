// Enclosure Body
// Main box with PSU and QuinLED sections

include <config.scad>

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
        translate([wall - rail_depth, wall, rail_z])
            cube([rail_depth + 0.1, inner_width + wall + 1, rail_height + 1]);

        // Lid sliding grooves on back wall (X=max, inner face)
        translate([outer_length - wall - 0.1, wall, rail_z])
            cube([rail_depth + 0.1, inner_width + wall + 1, rail_height + 1]);

        // Corner chamfers
        translate([0, 0, -0.1])
            corner_chamfer(chamfer_size, outer_height + 0.2);
        translate([0, outer_width, -0.1])
            rotate([0, 0, -90])
                corner_chamfer(chamfer_size, outer_height + 0.2);
        translate([outer_length, 0, -0.1])
            rotate([0, 0, 90])
                corner_chamfer(chamfer_size, outer_height + 0.2);
        translate([outer_length, outer_width, -0.1])
            rotate([0, 0, 180])
                corner_chamfer(chamfer_size, outer_height + 0.2);

        // PSU mounting holes through floor with tapered countersink
        for (pos = psu_mounts) {
            translate([pos[0], pos[1], -0.1])
                cylinder(d=psu_screw_dia + 0.5, h=wall + 0.2);
            translate([pos[0], pos[1], -0.1])
                cylinder(d1=psu_screw_head_dia + 1, d2=psu_screw_dia + 0.5, h=2.5);
        }

        // FRONT WALL (X=0): PSU power cable hole
        translate([-1, psu_area_start_y + psu_width/2, wall + 15])
            rotate([0, 90, 0])
                cylinder(d=psu_power_hole_dia, h=wall + 2);

        // LEFT SIDE (Y=0): PSU ventilation slots with center bridge
        slot_bridge = 2;
        slot_half = (slot_length - slot_bridge) / 2;
        for (i = [0:7]) {
            translate([outer_length/2 - 3.5 * slot_spacing + i * slot_spacing, -0.5, wall + psu_height/2 + slot_bridge/2 + slot_half/2])
                cube([slot_width, wall + 1, slot_half], center=true);
            translate([outer_length/2 - 3.5 * slot_spacing + i * slot_spacing, -0.5, wall + psu_height/2 - slot_bridge/2 - slot_half/2])
                cube([slot_width, wall + 1, slot_half], center=true);
        }

        // BACK WALL (X=max): PSU ventilation slots with center bridge
        for (i = [0:5]) {
            translate([outer_length + 0.5, psu_area_start_y + psu_width/2 - 2.5 * slot_spacing + i * slot_spacing, wall + psu_height/2 + slot_bridge/2 + slot_half/2])
                cube([wall + 1, slot_width, slot_half], center=true);
            translate([outer_length + 0.5, psu_area_start_y + psu_width/2 - 2.5 * slot_spacing + i * slot_spacing, wall + psu_height/2 - slot_bridge/2 - slot_half/2])
                cube([wall + 1, slot_width, slot_half], center=true);
        }

        // RIGHT SIDE (Y=max): QuinLED LED cable slit (aligned with board, rounded corners)
        slit_corner_r = 3;
        led_slit_x = quinled_board_x + quinled_length/2 - led_slit_width/2;
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


    // End stop for sliding lid (left side, Y=0)
    translate([wall - rail_depth, wall - 1.5, outer_height - rail_height])
        cube([rail_depth, 1.5, rail_height]);
    translate([outer_length - wall, wall - 1.5, outer_height - rail_height])
        cube([rail_depth, 1.5, rail_height]);
}

// Render
enclosure_body();

// Info
echo("Body dimensions:", outer_length, "x", outer_width, "x", outer_height);

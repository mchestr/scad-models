// Enclosure Body - Optimized & Cleaned
// Fits original Lid design perfectly
include <config.scad>

// --- Settings ---
show_mockups = false; // Set to false to hide the PSU/QuinLED ghosts

// Push PSU back, but ensure we leave room for the terminals at the back
// We position it so the back of the PSU body leaves exactly 'terminal_clearance' space
psu_x_pos = wall + inner_length - psu_length - terminal_clearance;

module enclosure_body() {
    // PSU center adjusted for 180deg rotation (pushed back by terminal_clearance)
    psu_cx = psu_x_pos + terminal_clearance + psu_length / 2;
    psu_cy = psu_area_start_y + psu_width / 2;
    rail_z = outer_height - rail_height;
    
    union() {
        difference() {
            // Main Shell & Cavity
            cube([outer_length, outer_width, outer_height]);
            translate([wall, wall, wall]) 
                cube([inner_length, inner_width, inner_height + 1]);

            // Lid Rail Grooves (Left & Right walls)
            // Grooves run along Y-axis for front-loading sliding lid
            for (x_pos = [wall - rail_depth, outer_length - wall]) {
                translate([x_pos, wall, rail_z])
                    cube([rail_depth + 0.1, inner_width + wall + 0.1, rail_height + 0.1]);
            }

            // External Corner Chamfers
            cham_h = outer_height + 0.2;
            translate([0, 0, -0.1]) corner_chamfer(chamfer_size, cham_h);
            translate([0, outer_width, -0.1]) rotate([0, 0, -90]) corner_chamfer(chamfer_size, cham_h);
            translate([outer_length, 0, -0.1]) rotate([0, 0, 90]) corner_chamfer(chamfer_size, cham_h);
            translate([outer_length, outer_width, -0.1]) rotate([0, 0, 180]) corner_chamfer(chamfer_size, cham_h);

            // PSU Mounting Holes (Countersunk)
            psu_holes = [
                [psu_cx - psu_hole_spacing_length/2, psu_cy - psu_hole_spacing_width/2],
                [psu_cx - psu_hole_spacing_length/2, psu_cy + psu_hole_spacing_width/2],
                [psu_cx + psu_hole_spacing_length/2, psu_cy - psu_hole_spacing_width/2],
                [psu_cx + psu_hole_spacing_length/2, psu_cy + psu_hole_spacing_width/2]
            ];
            for (p = psu_holes) {
                translate([p[0], p[1], -0.1]) cylinder(d=psu_screw_dia + 0.5, h=wall + 0.2);
                translate([p[0], p[1], -0.1]) cylinder(d1=psu_screw_head_dia + 1, d2=psu_screw_dia + 0.5, h=2.5);
            }

            // Front: Power Cable Hole (Teardrop)
            translate([-1, psu_area_start_y + psu_width/2, wall + psu_power_hole_z])
                teardrop_h(psu_power_hole_dia, wall + 2);

            // Left Side (Front Wall): Ventilation
            translate([outer_length/2 - 3.5 * slot_spacing, wall/2, wall + psu_height/2])
                vent_slot_pattern(8, slot_spacing, slot_width, slot_length, slot_bridge, wall);

            // Back Wall: Ventilation (rotated 90°)
            translate([outer_length - wall/2, psu_area_start_y + psu_width/2 - 2.5 * slot_spacing, wall + psu_height/2])
                rotate([0, 0, 90])
                    vent_slot_pattern(6, slot_spacing, slot_width, slot_length, slot_bridge, wall);

            // Right Side: JST-SM connector holes
            jst_total_width = (jst_count - 1) * jst_spacing + jst_width;
            jst_start_x = quinled_board_x + quinled_length/2 - jst_total_width/2;
            jst_z = wall + quinled_standoff_height + 8;

            for (i = [0 : jst_count - 1]) {
                translate([jst_start_x + i * jst_spacing, outer_width - wall - 1, jst_z])
                    rounded_rect_cutout(jst_width, jst_height, jst_corner_radius, wall + 2);
            }

            // Right Side: Extra wire hole
            extra_hole_x = jst_start_x + jst_total_width + jst_spacing;
            translate([extra_hole_x, outer_width - wall - 1, jst_z + jst_height/2])
                rotate([-90, 0, 0]) cylinder(d=extra_wire_hole_dia, h=wall + 2);

            // Right Side: Antenna (Teardrop)
            translate([outer_length - wall - antenna_offset_from_back, outer_width - wall - 1, outer_height - antenna_offset_from_top])
                rotate([0, 0, 90]) teardrop_h(antenna_dia, wall + 2);
        }

        // --- Additive Parts ---

        // Internal floor-wall fillets for strength and print quality
        // Front wall fillet
        translate([wall, wall, wall])
            internal_fillet(inner_length, internal_fillet_r);
        // Back wall fillet
        translate([wall + inner_length, wall + inner_width, wall])
            rotate([0, 0, 180]) internal_fillet(inner_length, internal_fillet_r);
        // Left wall fillet
        translate([wall, wall + inner_width, wall])
            rotate([0, 0, -90]) internal_fillet(inner_width, internal_fillet_r);
        // Right wall fillet
        translate([wall + inner_length, wall, wall])
            rotate([0, 0, 90]) internal_fillet(inner_width, internal_fillet_r);

        // QuinLED Standoffs (Reinforced) - on right side
        q_x = quinled_board_x;
        q_y = quinled_board_y;
        q_mounts = [
            [q_x + quinled_hole_edge, q_y + quinled_hole_edge],
            [q_x + quinled_length - quinled_hole_edge, q_y + quinled_hole_edge],
            [q_x + quinled_hole_edge, q_y + quinled_width - quinled_hole_edge],
            [q_x + quinled_length - quinled_hole_edge, q_y + quinled_width - quinled_hole_offset_back_right]
        ];
        for (p = q_mounts) translate([p[0], p[1], wall]) {
            standoff(quinled_standoff_dia, quinled_hole_dia, quinled_standoff_height);
            cylinder(d1=quinled_standoff_dia + 4, d2=quinled_standoff_dia, h=2.5); // Reinforced base
        }

        // Lid Stops
        for (x_pos = [wall - rail_depth, outer_length - wall])
            translate([x_pos, wall - 1.5, rail_z]) cube([rail_depth, 1.5, rail_height]);
    }
}

module mockups() {
    if (show_mockups) {
        // PSU - rotated 180 degrees, pushed back to account for terminals at front
        translate([psu_x_pos + terminal_clearance, psu_area_start_y, wall])
        translate([psu_length/2, psu_width/2, 0])
        rotate([0, 0, 180])
        translate([-psu_length/2, -psu_width/2, 0])
        color("Silver", 0.5) {
            cube([psu_length, psu_width, psu_height]);
            // Terminals - Measured dimensions:
            // - Extend 25mm up from bottom
            // - 18mm from front edge, 8mm from back edge
            translate([psu_length, 18, 0]) cube([terminal_clearance, psu_width - 18 - 8, 25]);
            // Bottom platform under terminals - 8mm high, full width
            translate([psu_length, 0, 0]) cube([terminal_clearance, psu_width, 8]);
            // Fan vent on top face
            // - 60mm diameter, center 38mm from left edge, 48mm from front edge
            translate([48, 38, psu_height]) cylinder(d=60, h=2);
            // Mounting holes on bottom (4 holes centered on PSU)
            psu_cx = psu_length / 2;
            psu_cy = psu_width / 2;
            for (pos = [
                [psu_cx - psu_hole_spacing_length/2, psu_cy - psu_hole_spacing_width/2],
                [psu_cx - psu_hole_spacing_length/2, psu_cy + psu_hole_spacing_width/2],
                [psu_cx + psu_hole_spacing_length/2, psu_cy - psu_hole_spacing_width/2],
                [psu_cx + psu_hole_spacing_length/2, psu_cy + psu_hole_spacing_width/2]
            ]) {
                translate([pos[0], pos[1], -1]) cylinder(d=psu_screw_dia, h=2);
            }
            // Side fins - 1mm thick, full height, extend past terminals
            // With 3 vertical grills - start 5mm from right edge, then every 3mm
            fin_end = psu_length + terminal_clearance;
            for (y_pos = [0, psu_width - 1]) {
                difference() {
                    translate([0, y_pos, 0])
                        cube([fin_end, 1, psu_height]);
                    // 3 vertical grills: 5mm from right, 3mm wide, 3mm spacing
                    for (i = [0:2]) {
                        translate([fin_end - 8 - i * 6, y_pos - 0.5, 5])
                            cube([3, 2, psu_height - 10]);
                    }
                }
            }
            translate([psu_length/2, psu_width/2, psu_height+1]) text("PSU", halign="center", valign="center", size=10);
        }
        // QuinLED - rotated 180 degrees, on right side
        translate([quinled_board_x, quinled_board_y, wall + quinled_standoff_height])
        translate([quinled_length/2, quinled_width/2, 0])
        rotate([0, 0, 180])
        translate([-quinled_length/2, -quinled_width/2, 0])
        color("DodgerBlue", 0.5) {
            cube([quinled_length, quinled_width, 2]);
            // Antenna connector - 45mm from front, 36mm from right edge
            translate([45, quinled_width - 36, 2]) cylinder(d=antenna_dia, h=10);
            translate([quinled_length/2, quinled_width/2, 3]) text("QuinLED", halign="center", valign="center", size=5);
        }
        // Power Cable Path
        color("Red") translate([-10, psu_area_start_y + psu_width/2, wall + psu_power_hole_z])
            rotate([0, 90, 0]) cylinder(d=psu_power_hole_dia-1, h=psu_x_pos + 10);
    }
}

enclosure_body();
mockups();

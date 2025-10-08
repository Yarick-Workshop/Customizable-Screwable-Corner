/* [Generic] */
$fn=360;
rendering_mode = "Production"; // [Production, Preview]

/* [Corner body] */
width = 45;
height = 110;
thickness = 7; 
chamfer_size = 3;
inner_chamfer = true;
foot = true;
foot_inner_chamfers = true;


/* [Screw holes] */
screw_diameter = 3.5;
screw_head_diameter = 7;
screw_head_depth = 3;
screw_holes_number = 3;
screw_edge_distance_top = 12;
screw_edge_distance_bottom = 12;
screw_hole_offset_percent = 65; // [0:0.1:100]
screw_offset_chess_order = true;

/* [Hidden] */
epsilon = 0.02;

module countersunk_hole()
{
    // Main screw hole
    cylinder(h=thickness + epsilon, d=screw_diameter, center=false);
    
    // Countersunk head
    translate([0, 0, -epsilon * 0.5])
        cylinder(h=screw_head_depth + epsilon * 0.5, d1=screw_head_diameter, d2=screw_diameter, center=false);
}

module corner()
{
    module chamfered_rectangle_2D(width, height, chamfer_size)
    {
        assert(chamfer_size <= min(width, height), "Chamfer size must not exceed the smaller dimension");
        
        points = 
        [
            [0, 0],                    // bottom-left
            [width, 0],                // bottom-right
            [width, height - chamfer_size], // top-right (chamfered bottom)
            [width - chamfer_size, height], // top-right (chamfered top)
            [0, height]                // top-left
        ];
        
        // Create the polygon
        polygon(points = points);
    }

    module half_corner(width, height, thickness, chamfer_size, center = false)
    {
        module chamfered_rectangle_3D(width, height, thickness, chamfer_size, center)
        {
            linear_extrude(height = height, center = center)
            {
                chamfered_rectangle_2D(width = width, height = thickness, chamfer_size = chamfer_size);
            }
        }

        difference()
        {
            chamfered_rectangle_3D(width=width, height=height, thickness=thickness, chamfer_size=chamfer_size);
            
            // Screw holes
            for(i = [0 : screw_holes_number - 1])
            {
                foot_height = foot ? thickness : 0;
                z = screw_edge_distance_bottom + foot_height + (i * (height - screw_edge_distance_top - screw_edge_distance_bottom - foot_height) / (screw_holes_number - 1));

                local_offset_percent = screw_offset_chess_order ? 
                    ((i % 2 == 0 ? screw_hole_offset_percent : (100 - screw_hole_offset_percent))) : 
                    screw_hole_offset_percent; 
                
                x_offset = thickness + (local_offset_percent / 100) * (width - chamfer_size - thickness);
                translate([x_offset, thickness, z])
                    rotate([90, 0, 0])
                        countersunk_hole();
            }
        }
    }

    module in_corner_chamfer(chamfer_height, spike = true)
    {
        points = [[0, 0], [chamfer_size, 0], [0, chamfer_size]];
        
        difference()
        {
            linear_extrude(height = chamfer_height)
            {
                polygon(points = points);
            }
            if (spike)
            {
                // Create 45-degree chamfer at the top
                translate([0, 0, chamfer_height])
                {
                    rotate([0, 45, 45])
                        translate([0, 0, chamfer_size * 2])
                            cube([chamfer_size * 2, chamfer_size * 4, chamfer_size * 4], center=true);
                }
            }
        }
    }

    module foot()
    {
        offset_x_y = thickness - chamfer_size;
        local_width = width - thickness + chamfer_size;

        internal_chamfer_size = local_width - sqrt(chamfer_size * chamfer_size + (local_width - chamfer_size) * (local_width - chamfer_size));

        translate([offset_x_y, offset_x_y])
        {
            difference()
            {     
                rotate_extrude(angle = 90)
                {
                    chamfered_rectangle_2D(width = local_width, height = thickness, chamfer_size = internal_chamfer_size);
                }
                // TODO, generalize offset calculation and fix it 
                x_offset = thickness - chamfer_size + (screw_hole_offset_percent / 100) * (width - chamfer_size - thickness);
                rotate([0, 0, 45])
                    translate([x_offset, 0, thickness])
                        rotate([180, 0, 0])
                            countersunk_hole();
            }           
        }

        // chamfers above the foot
        if (foot_inner_chamfers)
        {
            inner_foot_radius = local_width - internal_chamfer_size;
            translate([thickness, thickness, thickness])
                intersection()
                {
                    union()
                    {
                        // First chamfer
                        rotate([-90, 0])
                            rotate([0, 0, -90])
                                in_corner_chamfer(inner_foot_radius * 2);
                        
                        // Second chamfer
                        rotate([0, 90, 0])
                                rotate([0, 0, 90])
                                    in_corner_chamfer(inner_foot_radius * 2);
                    }
                    union()
                    {
                        translate([- chamfer_size, -chamfer_size, 0])
                            cylinder(h = inner_foot_radius, r1 = inner_foot_radius, r2 = 0, center = false);
                        
                        linear_extrude(height = height)
                            polygon(points = [[0, 0], [width - chamfer_size - thickness, 0], [0, width - chamfer_size - thickness]]);
                    }
                }
        }
    }

    // First half corner
    half_corner(width, height, thickness, chamfer_size);
    
    // Second half corner mirrored by x and rotated -90 degrees
    rotate([0, 0, -90])
        mirror([1, 0, 0])
            half_corner(width, height, thickness, chamfer_size);

    // Inner chamfer    
    if (inner_chamfer)
    {
        translate([thickness, thickness])
            in_corner_chamfer(height, spike = false);
    }

    // Foot
    if (foot)
    {
        foot();
    }
}

if (rendering_mode == "Production")
{
    corner();
    
    // Test block
    translate([width + 20, 0, 0])
    {
        difference()
        {
            translate([0, 0, thickness / 2]) 
                cube([20, 20, thickness], center=true);
            
            translate([0, 0, thickness]) 
            mirror([0, 0, 1])
                countersunk_hole();
        }
    }
}
else if (rendering_mode == "Preview")
{
    corner();
}
else
{
    assert(false, str("Invalid rendering_mode: ", rendering_mode, ". Use 'Production' or 'Preview'"));
}

// Customization variables
$fn=360;
width = 45;
height = 110;
thickness = 10; 
chamfer_size = 5;
screw_diameter = 3.5;
head_diameter = 7;
head_depth = 3;
screw_holes_number = 3;
screw_edge_distance = 12;
screw_hole_offset_percent = 65; // [0:0.1:100]
screw_offset_chess_order = true;
rendering_mode = "Production"; // [Production, Preview]

//TODO, build all the modules inside of the main one

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

module chamfered_rectangle_3D(width, height, thickness, chamfer_size)
{
    linear_extrude(height = height)
    {
        chamfered_rectangle_2D(width = width, height = thickness, chamfer_size = chamfer_size);
    }
}

module countersunk_hole()
{
    // Main screw hole
    cylinder(h=thickness + 0.02, d=screw_diameter, center=false);
    
    // Countersunk head
    translate([0, 0, -0.01])
        cylinder(h=head_depth + 0.01, d1=head_diameter, d2=screw_diameter, center=false);
}

module corner()
{
    module half_corner()
    {
        difference()
        {
            chamfered_rectangle_3D(width=width, height=height, thickness=thickness, chamfer_size=chamfer_size);
            
            // Screw holes
            for(i = [0 : screw_holes_number - 1])
            {
                z = screw_edge_distance + (i * (height - 2 * screw_edge_distance) / (screw_holes_number - 1));

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

    // First half corner
    half_corner();
    
    // Second half corner mirrored by x and rotated -90 degrees
    rotate([0, 0, -90])
        mirror([1, 0, 0])
            half_corner();
}

// Examples

// Rendering logic
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

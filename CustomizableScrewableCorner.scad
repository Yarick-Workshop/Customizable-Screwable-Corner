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

module countersunk_hole(screw_diameter, head_diameter, head_depth, hole_depth)
{
    // Main screw hole
    cylinder(h=hole_depth, d=screw_diameter, center=false);
    
    // Countersunk head
    translate([0, 0, -0.01])
        cylinder(h=head_depth + 0.01, d1=head_diameter, d2=screw_diameter, center=false);
}

module add_screw_holes_to_rectangle(width, thickness, screw_diameter, head_diameter, head_depth, 
                                   screw_hole_spacing, screw_edge_distance)
{
    for(i = [screw_edge_distance : screw_hole_spacing : width - screw_edge_distance])
    {
        translate([i, thickness, -0.01])
            rotate([90, 0, 0])
                countersunk_hole(screw_diameter=screw_diameter, head_diameter=head_diameter, 
                               head_depth=head_depth, hole_depth=thickness + 0.02);
    }
}

module half_corner(width, height, thickness, chamfer_size, 
                   screw_diameter, head_diameter, head_depth, 
                   screw_hole_spacing, screw_edge_distance)
{
    difference()
    {
        chamfered_rectangle_3D(width=width, height=height, thickness=thickness, chamfer_size=chamfer_size);
        add_screw_holes_to_rectangle(width=width, thickness=thickness, 
                                   screw_diameter=screw_diameter, head_diameter=head_diameter, 
                                   head_depth=head_depth, screw_hole_spacing=screw_hole_spacing, 
                                   screw_edge_distance=screw_edge_distance);
    }
}

module corner(width, height, thickness, chamfer_size, 
              screw_diameter, head_diameter, head_depth,
              screw_hole_spacing, screw_edge_distance)
{
    // First half corner
    half_corner(width=width, height=height, thickness=thickness, chamfer_size=chamfer_size,
                screw_diameter=screw_diameter, head_diameter=head_diameter, head_depth=head_depth,
                screw_hole_spacing=screw_hole_spacing, screw_edge_distance=screw_edge_distance);
    
    // Second half corner mirrored by x and rotated -90 degrees
    rotate([0, 0, -90])
        mirror([1, 0, 0])
            half_corner(width=width, height=height, thickness=thickness, chamfer_size=chamfer_size,
                        screw_diameter=screw_diameter, head_diameter=head_diameter, head_depth=head_depth,
                        screw_hole_spacing=screw_hole_spacing, screw_edge_distance=screw_edge_distance);
}

// Examples

// Example of individual chamfered rectangle
// chamfered_rectangle_3D(width=45, height=110, thickness=10, chamfer_size=5);

// Example of corner module with screw holes
corner(width=45, height=110, thickness=10, chamfer_size=5,
       screw_diameter=3.5, head_diameter=7, head_depth=3,
       screw_hole_spacing=15, screw_edge_distance=10);

module chamfered_rectangle_2D(width=20, height=20, chamfer_size=5)
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

module chamfered_rectangle_3D(width=20, height=20, thickness=10, chamfer_size=5)
{
    linear_extrude(height = height)
    {
        chamfered_rectangle_2D(width = width, height = thickness, chamfer_size = chamfer_size);
    }
}

module corner(width=20, height=20, thickness=10, chamfer_size=5)
{
    // First chamfered rectangle
    chamfered_rectangle_3D(width=width, height=height, thickness=thickness, chamfer_size=chamfer_size);
    
    // Second chamfered rectangle mirrored by x and rotated -90 degrees
    rotate([0, 0, -90])
    {
        mirror([1, 0, 0])
        {
            chamfered_rectangle_3D(width=width, height=height, thickness=thickness, chamfer_size=chamfer_size);
        }
    }
}

// Examples
// TODO, fix parameters values
// TODO, add customizing parameters

// Example of individual chamfered rectangle
// chamfered_rectangle_3D(width=45, height=110, thickness=10, chamfer_size=5);

// Example of corner module
corner(width=45, height=110, thickness=10, chamfer_size=5);

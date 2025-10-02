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

// Examples
// TODO, fix parameters values
// TODO, add customizing parameters
chamfered_rectangle_3D(width=45, height=110, thickness=10, chamfer_size=5);

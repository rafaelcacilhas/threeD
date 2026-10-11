package threeD
import "core:math"

Framebuffer:: struct{
    pixels: []u32,
    width: i32,
    height: i32,
}

clear_framebuffer:: proc(framebuffer: ^Framebuffer, color:u32){
    for &pixel in framebuffer.pixels{
        pixel = color
    }
}

draw_pixel :: proc(framebuffer: ^Framebuffer, point: Point2D, color:u32){
    if point.x < 0 || point.x >= framebuffer.width ||point.y < 0 || point.y >= framebuffer.height{
        return
    }
    
    framebuffer.pixels[int(point.y*framebuffer.width + point.x)] = color
}

draw_pixel_unchecked :: proc(framebuffer: ^Framebuffer, point: Point2D, color:u32){
    framebuffer.pixels[int(point.y*framebuffer.width + point.x)] = color
}

get_pixel :: proc(framebuffer: ^Framebuffer, point : Point2D) -> u32{
    return framebuffer.pixels[int(point.y*framebuffer.width + point.x)]
}

draw_line:: proc(framebuffer: ^Framebuffer, p0, p1 : Point2D, color: u32){
    delta_x := math.abs(p1.x - p0.x)
    delta_y := math.abs(p1.y - p0.y)

    if p0.y == p1.y {
        draw_hline(framebuffer, p0, p1, color);
    }
    else if p0.x == p1.x{
        draw_vline(framebuffer, p0, p1, color)
    }
    else if delta_x > delta_y{
        draw_shallow_line(framebuffer, p0, p1, color)
    } else {
        draw_steep_line(framebuffer, p0, p1, color)
    }
}

draw_hline:: proc(framebuffer: ^Framebuffer, p0, p1 : Point2D, color: u32){
    assert(p0.y == p1.y, "draw_hline requires both points to share the same y")

    first_point, second_point : i32 = p0.x, p1.x

    if(first_point > second_point){
        first_point, second_point = second_point, first_point
    }

    for x:= first_point; x <= second_point; x+=1{
        draw_pixel(framebuffer, {x, p0.y}, color)
    }
}

draw_vline:: proc(framebuffer: ^Framebuffer,  p0, p1 : Point2D, color: u32){
    assert(p0.x == p1.x, "draw_vline requires both points to share the same x")

    first_point, second_point : i32 = p0.y, p1.y
    if (first_point > second_point){
        first_point, second_point = second_point, first_point
    } 

    for y:= first_point; y <= second_point; y+=1{
        draw_pixel(framebuffer, {p0.x, y}, color)
    }
}

draw_shallow_line:: proc(framebuffer: ^Framebuffer, p0, p1 : Point2D, color: u32){
    left_x, right_x : i32 = p0.x, p1.x
    left_y, right_y : i32 = p0.y, p1.y
    if (left_x > right_x){
        left_x, right_x = right_x, left_x
        left_y, right_y = right_y, left_y
    }

    delta_x := right_x - left_x 
    delta_y := math.abs(right_y - left_y)

    y_direction : i32 = 1
    if(left_y > right_y) {
        y_direction *= -1
    }

    y_error : i32 = 0
    y := left_y
    for x:= left_x; x <= right_x; x+=1{
        draw_pixel(framebuffer, {x, y}, color)

        y_error += delta_y
        if y_error >= delta_x {
            y += y_direction
            y_error -= delta_x 
        }
    }
}

draw_steep_line:: proc(framebuffer: ^Framebuffer, p0, p1 : Point2D, color: u32){
    top_x, bottom_x : i32 = p0.x, p1.x
    top_y, bottom_y : i32 = p0.y, p1.y
    if top_y > bottom_y {
        top_x, bottom_x = bottom_x, top_x
        top_y, bottom_y = bottom_y, top_y
    }

    delta_x := math.abs(top_x - bottom_x )
    delta_y := bottom_y - top_y

    x_direction : i32 = 1
    if(bottom_x < top_x ) {
        x_direction = -1
    }
    
    x_error : i32 = 0
    x := top_x
    for y:= top_y; y <= bottom_y; y+=1{
        draw_pixel(framebuffer, {x, y}, color)

        x_error += delta_x
        if x_error >= delta_y {
            x += x_direction
            x_error -= delta_y 
        }
    }
}

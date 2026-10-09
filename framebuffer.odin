package threeD

import "vendor:x11/xlib"
Framebuffer:: struct{
    pixels: []u32,
    width: i32,
    height: i32,
}

draw_pixel :: proc(framebuffer: ^Framebuffer, x, y:i32, color:u32){
    if x < 0 || x >= framebuffer.width ||y < 0 || y >= framebuffer.height{
        return
    }
    
    framebuffer.pixels[int(y*framebuffer.width + x)] = color
}

draw_pixel_unchecked :: proc(framebuffer: ^Framebuffer, x, y:i32, color:u32){
    framebuffer.pixels[int(y*framebuffer.width + x)] = color
}

get_pixel :: proc(framebuffer: ^Framebuffer, x, y:i32) -> u32{
    return framebuffer.pixels[int(y*framebuffer.width + x)]
}

draw_hline:: proc(framebuffer: ^Framebuffer, x0, x1, y : i32, color: u32){
    first_point, second_point : i32
    if (x0 < x1){
        first_point = x0
        second_point = x1
    } else{
        first_point = x1
        second_point = x0
    }

    for x:= first_point; x <= second_point; x+=1{
        draw_pixel(framebuffer, x, y, color)
    }
}

draw_vline:: proc(framebuffer: ^Framebuffer, x, y0, y1 : i32, color: u32){
    first_point, second_point : i32
    if (y0 < y1){
        first_point = y0
        second_point = y1
    } else{
        first_point = y1
        second_point = y0
    }

    for y:= first_point; y <= second_point; y+=1{
        draw_pixel(framebuffer, x, y, color)
    }
}
clear_framebuffer:: proc(framebuffer: ^Framebuffer, color:u32){
    for &pixel in framebuffer.pixels{
        pixel = color
    }
}
package threeD

import "core:testing"

@(test)
test_draw_pixel_inside_bounds :: proc(t: ^testing.T) {
    pixels := make([]u32, 4 * 4)
    defer delete(pixels)

    framebuffer := Framebuffer{
        pixels = pixels,
        width  = 4,
        height = 4,
    }

    draw_pixel(&framebuffer, 2, 3, 0xFFFF0000)

    expected_index := int(3 * 4 + 2)
    testing.expect_value(t, framebuffer.pixels[expected_index], u32(0xFFFF0000))
}

@(test)
test_draw_pixel_outside_bounds :: proc(t: ^testing.T) {
    pixels := make([]u32, 4 * 4)
    defer delete(pixels)

    framebuffer := Framebuffer{
        pixels = pixels,
        width  = 4,
        height = 4,
    }

    draw_pixel(&framebuffer, -1, 0, 0xFFFF0000)
    draw_pixel(&framebuffer, 4, 0, 0xFFFF0000)
    draw_pixel(&framebuffer, 0, -1, 0xFFFF0000)
    draw_pixel(&framebuffer, 0, 4, 0xFFFF0000)

    for pixel in framebuffer.pixels {
        testing.expect_value(t, pixel, u32(0))
    }
}

@(test)
test_clear_framebuffer :: proc(t: ^testing.T) {
    pixels := make([]u32, 4 * 4)
    defer delete(pixels)

    framebuffer := Framebuffer{
        pixels = pixels,
        width  = 4,
        height = 4,
    }

    // Pre-fill with a color to ensure clearing
    for &pixel in framebuffer.pixels {
        pixel = 0xFF00FF00
    }

    clear_framebuffer(&framebuffer, 0xFFFF0000)

    for pixel in framebuffer.pixels {
        testing.expect_value(t, pixel, u32(0xFFFF0000))
    }
}
@(test)
test_draw_pixel_unchecked_lands_at_correct_index :: proc(t: ^testing.T) {
    pixels := make([]u32, 4 * 4)
    defer delete(pixels)

    framebuffer := Framebuffer{
        pixels = pixels,
        width  = 4,
        height = 4,
    }

    draw_pixel_unchecked(&framebuffer, 2, 3, 0xFFFF0000)

    // Row 3, column 2. Index = y * width + x = 3 * 4 + 2 = 14.
    testing.expect_value(t, framebuffer.pixels[14], u32(0xFFFF0000))
}

@(test)
test_draw_pixel_unchecked_distinct_coordinates :: proc(t: ^testing.T) {
    pixels := make([]u32, 4 * 4)
    defer delete(pixels)

    framebuffer := Framebuffer{
        pixels = pixels,
        width  = 4,
        height = 4,
    }

    draw_pixel_unchecked(&framebuffer, 0, 0, 0xFF0000FF)
    draw_pixel_unchecked(&framebuffer, 3, 3, 0xFF00FF00)

    testing.expect_value(t, framebuffer.pixels[0],  u32(0xFF0000FF))
    testing.expect_value(t, framebuffer.pixels[15], u32(0xFF00FF00))
}

@(test)
test_draw_pixel_unchecked_draws_exactly_one_pixel :: proc(t: ^testing.T) {
    pixels := make([]u32, 4 * 4)
    defer delete(pixels)

    framebuffer := Framebuffer{
        pixels = pixels,
        width  = 4,
        height = 4,
    }

    // Fill the whole buffer with a known value.
    for &pixel in framebuffer.pixels {
        pixel = 0xFF000000
    }

    draw_pixel_unchecked(&framebuffer, 1, 2, 0xFFFF0000)

    // Exactly one pixel should have changed.
    changed_count := 0
    for pixel in framebuffer.pixels {
        if pixel != 0xFF000000 {
            changed_count += 1
        }
    }
    testing.expect_value(t, changed_count, 1)

    // And it should be the pixel we wrote.
    // Row 2, column 1. Index = 2 * 4 + 1 = 9.
    testing.expect_value(t, framebuffer.pixels[9], u32(0xFFFF0000))
}

@(test)
test_draw_hline_simple :: proc(t: ^testing.T) {
    pixels := make([]u32, 5 * 5)
    defer delete(pixels)

    framebuffer := Framebuffer{
        pixels = pixels,
        width  = 5,
        height = 5,
    }

    clear_framebuffer(&framebuffer, 0xFF000000)
    draw_hline(&framebuffer, 2, 4, 3, 0xFFFFFF00)

    for x: i32 = 0; x <= 4; x += 1 {
        if x >= 2 && x <= 4 {
            testing.expect_value(t, get_pixel(&framebuffer, x, 3), u32(0xFFFFFF00))
        } else {
            testing.expect_value(t, get_pixel(&framebuffer, x, 3), u32(0xFF000000))
        }
    }
}

@(test)
test_draw_hline_reversed :: proc(t: ^testing.T) {
    pixels := make([]u32, 5 * 5)
    defer delete(pixels)

    framebuffer := Framebuffer{
        pixels = pixels,
        width  = 5,
        height = 5,
    }

    clear_framebuffer(&framebuffer, 0xFF000000)
    draw_hline(&framebuffer, 4, 2, 3, 0xFFFFFF00)

    for x: i32 = 2; x <= 4; x += 1 {
        testing.expect_value(t, get_pixel(&framebuffer, x, 3), u32(0xFFFFFF00))
    }
}

@(test)
test_draw_hline_out_of_bounds :: proc(t: ^testing.T) {
    pixels := make([]u32, 5 * 5)
    defer delete(pixels)

    framebuffer := Framebuffer{
        pixels = pixels,
        width  = 5,
        height = 5,
    }

    clear_framebuffer(&framebuffer, 0xFF000000)
    draw_hline(&framebuffer, -2, 8, 4, 0xFF55FF00)

    for x: i32 = 0; x <= 4; x += 1 {
        testing.expect_value(t, get_pixel(&framebuffer, x, 4), u32(0xFF55FF00))
    }

    for y: i32 = 0; y <= 3; y += 1 {
        for x: i32 = 0; x <= 4; x += 1 {
            testing.expect_value(t, get_pixel(&framebuffer, x, y), u32(0xFF000000))
        }
    }
}

@(test)
test_draw_vline_simple :: proc(t: ^testing.T) {
    pixels := make([]u32, 5 * 5)
    defer delete(pixels)

    framebuffer := Framebuffer{
        pixels = pixels,
        width  = 5,
        height = 5,
    }

    clear_framebuffer(&framebuffer, 0xFF003300)
    draw_vline(&framebuffer, 2, 2, 4, 0xFF22FF00)

    for y: i32 = 0; y <= 4; y += 1 {
        if y >= 2 && y <= 4 {
            testing.expect_value(t, get_pixel(&framebuffer, 2, y), u32(0xFF22FF00))
        } else {
            testing.expect_value(t, get_pixel(&framebuffer, 2, y), u32(0xFF003300))
        }
    }
}

@(test)
test_draw_vline_reversed :: proc(t: ^testing.T) {
    pixels := make([]u32, 5 * 5)
    defer delete(pixels)

    framebuffer := Framebuffer{
        pixels = pixels,
        width  = 5,
        height = 5,
    }

    clear_framebuffer(&framebuffer, 0xFF000000)
    draw_vline(&framebuffer, 4, 2, 3, 0xFFFFFF00)

    for y: i32 = 2; y <= 3; y += 1 {
        testing.expect_value(t, get_pixel(&framebuffer, 4, y), u32(0xFFFFFF00))
    }
}

@(test)
test_draw_vline_out_of_bounds :: proc(t: ^testing.T) {
    pixels := make([]u32, 5 * 5)
    defer delete(pixels)

    framebuffer := Framebuffer{
        pixels = pixels,
        width  = 5,
        height = 5,
    }

    clear_framebuffer(&framebuffer, 0xFF000000)
    draw_vline(&framebuffer, 4, -2, 4, 0xFF55FF00)

    for y: i32 = 0; y <= 4; y += 1 {
        testing.expect_value(t, get_pixel(&framebuffer, 4, y), u32(0xFF55FF00))
    }

    for x: i32 = 0; x <= 3; x += 1 {
        for y: i32 = 0; y <= 4; y += 1 {
            testing.expect_value(t, get_pixel(&framebuffer, x, y), u32(0xFF000000))
        }
    }
}

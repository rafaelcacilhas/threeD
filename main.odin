package threeD
import "core:sys/windows"
import "core:fmt"

white : u32 = 0xFFFFFF
red : u32 = 0xFF0000
blue : u32 = 0x00FF00
green : u32 = 0x0000FF

main :: proc() {
    title: cstring16 = "threeD"
    state := init_window(640, 480, title)

    running := true
    message: windows.MSG

    for running {
        for windows.PeekMessageW(&message, nil, 0, 0, windows.PM_REMOVE){
            if message.message == windows.WM_QUIT{
                running = false
                break;
            }

            windows.TranslateMessage(&message)
            windows.DispatchMessageW(&message)
        }
        if !running { 
            break
        }

        clear_framebuffer(state.framebuffer, 0x000007) 
        draw_pixel(state.framebuffer, 50,50,0xFFFFFF)
        draw_pixel(state.framebuffer, 50,51,0xFFFFFF)
        draw_pixel_unchecked(state.framebuffer, 51,50,0xFFFFFF)
        draw_pixel_unchecked(state.framebuffer, 51,51,0xFFFFFF)
        
        draw_hline(state.framebuffer, 5, 70, 70, white)
        draw_hline(state.framebuffer, 5, 70, 80, red)
        draw_hline(state.framebuffer, 5, 70, 90, green)
        draw_hline(state.framebuffer, 5, 70, 90, blue)

        draw_vline(state.framebuffer, 250, 20, 90, blue)
        
        present(state)
    }

    destroy_window(title, state)
}
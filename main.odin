package threeD
import "core:sys/windows"
import "core:fmt"

white : u32 = 0xFFFFFF
red : u32 = 0xFF0000
green : u32 = 0x00FF00
blue : u32 = 0x0000FF

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

        draw_line(state.framebuffer, {25, 300},{258, 300}, green)
        draw_line(state.framebuffer, {25, 230},{25, 280}, white)

        draw_line(state.framebuffer, {25, 300},{250, 290}, red)
        draw_line(state.framebuffer, {220, 120}, {245, 389}, blue)

        present(state)
    }

    destroy_window(title, state)
}
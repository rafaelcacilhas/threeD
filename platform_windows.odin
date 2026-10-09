package threeD
import "core:fmt"
import "core:sys/windows"
import "base:runtime"
import "core:slice"

// device-independent bitmap (DIB) section -  pixel buffer that both you and Windows can access

State :: struct{
    hwnd: windows.HWND, // Handle to a Window
    hdc: windows.HDC, // Handle to a Device Context - Memory DC for the DIB
    hbitmap: windows.HBITMAP, // Handle to a  bitmap
    old_bitmap: windows.HGDIOBJ,
    framebuffer: ^Framebuffer
}

WindowProc :: proc "stdcall"(
    hwnd: windows.HWND, 
    uMsg: windows.UINT, 
    wParam: windows.WPARAM, 
    lParam: windows.LPARAM
) -> windows.LRESULT{
    context = runtime.default_context()

    state :=  cast(^State)cast(uintptr)windows.GetWindowLongPtrW(
        hwnd,
        windows.GWLP_USERDATA,
    )
    if state == nil {
        return windows.DefWindowProcW(hwnd, uMsg, wParam, lParam)
    }
    
    switch uMsg{
        case windows.WM_CREATE:
            fmt.println("WM_CREATE\n")
        case windows.WM_PAINT:
            fmt.println("WM_PAINT\n")
            paint: windows.PAINTSTRUCT
            windows.BeginPaint(hwnd, &paint)
            windows.EndPaint(hwnd, &paint)
            return 0

        case windows.WM_CLOSE:
            fmt.println("WM_CLOSE\n")
            windows.DestroyWindow(state.hwnd)

        case windows.WM_DESTROY:
            fmt.println("WM_DESTROY\n")
            windows.PostQuitMessage(0)
            return 0
    }
    
    return windows.DefWindowProcW(hwnd, uMsg, wParam, lParam)
}

init_window:: proc(width:i32, height:i32, title:cstring16) -> ^State {
    state := new(State)
    state.framebuffer = new(Framebuffer)

    state.framebuffer.width = width
    state.framebuffer.height = height

    window_class:= windows.WNDCLASSW{
        lpfnWndProc = WindowProc,
        hInstance = cast(windows.HANDLE)windows.GetModuleHandleW(nil),
        lpszClassName = title,
    }

    if windows.RegisterClassW(&window_class) == 0{
        fmt.println("RegisterClassW failed")
        return nil
    }

    state.hwnd = windows.CreateWindowExW(
        0, // dwExStyle
        title,
        title,
        windows.WS_OVERLAPPEDWINDOW,
        windows.CW_USEDEFAULT, windows.CW_USEDEFAULT,
        state.framebuffer.width, state.framebuffer.height,
        nil, nil,
        cast(windows.HANDLE)windows.GetModuleHandleW(nil),
        &state,
    )

    if state.hwnd == nil {
        fmt.println("CreateWindowExW failed")
        return nil
    }

    windows.SetWindowLongPtrW(
        state.hwnd, 
        windows.GWLP_USERDATA,
        cast(windows.LONG_PTR)cast(uintptr)&state
    )

    bitmap_info := windows.BITMAPINFO{}
    bitmap_info.bmiHeader.biSize = size_of(windows.BITMAPINFOHEADER)
    bitmap_info.bmiHeader.biWidth = state.framebuffer.width
    bitmap_info.bmiHeader.biHeight = -state.framebuffer.height // Negative for top down rows
    bitmap_info.bmiHeader.biPlanes = 1
    bitmap_info.bmiHeader.biBitCount = 32
    bitmap_info.bmiHeader.biCompression = windows.BI_RGB

    pixel_bits: rawptr
    hbitmap := windows.CreateDIBSection(
        nil,
        &bitmap_info,
        windows.DIB_RGB_COLORS,
        &pixel_bits,
        nil,
        0
    )

    if hbitmap == nil || pixel_bits == nil {
        fmt.println("CreateDIBSection failed")
        windows.DestroyWindow(state.hwnd)
        return nil
    }

    pixels := slice.from_ptr(
        cast([^]u32)pixel_bits, 
        cast(int)(state.framebuffer.width*state.framebuffer.height)
    )

    state.hbitmap = hbitmap
    state.framebuffer.pixels = pixels

    state.hdc = windows.CreateCompatibleDC(nil)
    if state.hdc == nil {
        fmt.println("CreateCompatibleDC failed")
        windows.DeleteObject(cast(windows.HGDIOBJ)state.hbitmap)
        windows.DestroyWindow(state.hwnd)
        return nil
    }

    state.old_bitmap = windows.SelectObject(
        state.hdc, 
        cast(windows.HGDIOBJ)state.hbitmap
    )

    windows.ShowWindow(state.hwnd, windows.SW_SHOW)
    fmt.println("entering message loop\n")
    return state
}

get_framebuffer:: proc(window:any)  {

}

destroy_window:: proc(title:cstring16, state:^State) {
    fmt.println("message loop exited, destroying window\n")

    windows.SelectObject(state.hdc, state.old_bitmap)
    windows.DeleteObject(cast(windows.HGDIOBJ)state.hbitmap)
    windows.DeleteDC(state.hdc)
    windows.DestroyWindow(state.hwnd)
    windows.UnregisterClassW(title, cast(windows.HANDLE)windows.GetModuleHandleW(nil)) 
    fmt.println("cleanup done\n")
}

present:: proc(state: ^State){
    window_device_context := windows.GetDC(state.hwnd)
    windows.BitBlt(
        window_device_context,
        0, 0,
        state.framebuffer.width, state.framebuffer.height,
        state.hdc,
        0, 0,
        windows.SRCCOPY
    )
    windows.ReleaseDC(state.hwnd, window_device_context)
}
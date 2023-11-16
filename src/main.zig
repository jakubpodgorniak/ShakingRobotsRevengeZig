const c = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_image.h");
});
const std = @import("std");
const assert = @import("std").debug.assert;
const entities = @import("entities.zig");
const Vector2 = @import("core.zig").Vector2;
const InputFrame = @import("input.zig").InputFrame;
const InputSnapshot = @import("input.zig").InputSnapshot;
const Scancode = @import("input.zig").Scancode;

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const screen = c.SDL_CreateWindow("My Game Window", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 1280, 720, c.SDL_WINDOW_OPENGL) orelse
        {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(screen);

    const renderer = c.SDL_CreateRenderer(screen, -1, 0) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    //const zig_bmp = @embedFile("zig.bmp");
    //const rw = c.SDL_RWFromConstMem(zig_bmp, zig_bmp.len) orelse {
    //  c.SDL_Log("Unable to get RWFromConstMem: %s", c.SDL_GetError());
    //return error.SDLInitializationFailed;
    //};
    //defer assert(c.SDL_RWclose(rw) == 0);
    //

    //    const floorTexture = c.SDL_RWFromFile("./resources/map-floor.png", "r") orelse {
    //      c.SDL_Log("Unable to get RWFromFile: %s", c.SDL_GetError());
    //        return error.SDLInitializationFailed;
    //};
    //  defer assert(c.SDL_RWclose(rw) == 0);

    //    const zig_surface = c.SDL_LoadBMP_RW(rw, 0) orelse {
    //      c.SDL_Log("Unable to load bmp: %s", c.SDL_GetError());
    //    return error.SDLInitializationFailed;
    //    };
    //  defer c.SDL_FreeSurface(zig_surface);

    //const zig_texture = c.SDL_CreateTextureFromSurface(renderer, zig_surface) orelse {
    //  c.SDL_Log("Unable to create texture from surface: %s", c.SDL_GetError());
    //return error.SDLInitializationFailed;
    //    };
    //  defer c.SDL_DestroyTexture(zig_texture);

    _ = c.IMG_Init(c.IMG_INIT_PNG);
    const floorTexture: *c.SDL_Texture = c.IMG_LoadTexture(renderer, "./resources/map-floor.png") orelse {
        c.SDL_Log("Unable to load png: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyTexture(floorTexture);

    const jasonTexture: *c.SDL_Texture = c.IMG_LoadTexture(renderer, "./resources/jason.png") orelse {
        c.SDL_Log("Unable to load png: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyTexture(jasonTexture);
    defer c.IMG_Quit();

    var player = entities.Player{
        .position = Vector2.new(5.0, 2.8125),
        .immortal = false,
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpaAllocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) unreachable;
    }

    var _inputFrame = InputFrame.init(gpaAllocator);
    var inputFrame: *InputFrame = &_inputFrame;
    defer inputFrame.deinit();

    const dt: f32 = 17.0 / 1000.0;

    var quit = false;
    while (!quit) {
        try inputFrame.beginNext();

        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                c.SDL_KEYDOWN => {
                    // @TODO: can use SDL repeats in future (research required)
                    if (event.key.repeat == 0) {
                        try inputFrame.registerKeyDown(@enumFromInt(event.key.keysym.scancode));
                    }
                },
                c.SDL_KEYUP => {
                    try inputFrame.registerKeyUp(@enumFromInt(event.key.keysym.scancode));
                },
                else => {},
            }
        }

        try inputFrame.takeSnapshot();

        const is: *const InputSnapshot = &inputFrame.snapshot;

        if (is.isKeyDown(.d)) {
            player.position = player.position.add(Vector2.UNIT_X.scale(20));
        }

        if (is.isKeyUp(.f)) {
            player.position = player.position.add(Vector2.UNIT_X.scale(-20));
        }

        if (is.isKeyPressed(.w)) {
            player.position = player.position.add(Vector2.UNIT_Y);
        }

        player.update(dt, is);

        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_RenderCopy(renderer, floorTexture, null, null);

        const jasonDest: *const c.SDL_Rect = &.{
            .x = @as(c_int, @intFromFloat(player.position.getX())),
            .y = @as(c_int, @intFromFloat(player.position.getY())),
            .w = 1280,
            .h = 720,
        };
        _ = c.SDL_RenderCopy(renderer, jasonTexture, null, jasonDest);
        c.SDL_RenderPresent(renderer);

        c.SDL_Delay(17);
    }
}

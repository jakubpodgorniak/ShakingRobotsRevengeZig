const c = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_image.h");
});
const std = @import("std");
const assert = @import("std").debug.assert;
const entities = @import("entities.zig");
const core = @import("core.zig");
const Vector2 = core.Vector2;
const PointI32 = core.PointI32;
const InputFrame = @import("input.zig").InputFrame;
const InputSnapshot = @import("input.zig").InputSnapshot;
const Scancode = @import("input.zig").Scancode;
const world = @import("world.zig");
const Instant = std.time.Instant;

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const screen = c.SDL_CreateWindow("Shaking Robots Revenge", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 1280, 720, c.SDL_WINDOW_OPENGL) orelse
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

    var player = entities.Player.init(Vector2.new(5.0, 2.8125));

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpaAllocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) unreachable;
    }

    var enemiesManager = entities.EnemiesManager.init(gpaAllocator);
    defer enemiesManager.deinit();

    var _mouseX: i32 = 0;
    var _mouseY: i32 = 0;
    const mouseX: *i32 = &_mouseX;
    const mouseY: *i32 = &_mouseY;
    _ = c.SDL_GetMouseState(mouseX, mouseY);

    var _inputFrame = InputFrame.init(gpaAllocator, PointI32.new(_mouseX, _mouseY));
    var inputFrame: *InputFrame = &_inputFrame;
    defer inputFrame.deinit();

    var totalTime: f32 = 0.0; // total time for simulation (works together with dt);
    const dt: f32 = 1.0 / 60.0;
    var frameTimeAcc: f32 = 0.0;

    var prevInstant = try Instant.now();

    try inputFrame.beginNext();

    enemiesManager.reset(); // @NOTE: temporary

    var quit = false;
    while (!quit) {
        var instant = try Instant.now();
        const elapsedS: f32 = @as(f32, @floatFromInt(instant.since(prevInstant))) * 0.000000001;
        // @NOTE: some limiting of elapsedMs maybe required in case of lag
        prevInstant = instant;

        frameTimeAcc += elapsedS;

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
                c.SDL_MOUSEMOTION => {
                    inputFrame.registerMousePos(PointI32.new(event.motion.x, event.motion.y));
                },
                else => {},
            }
        }

        while (frameTimeAcc >= dt) {
            try inputFrame.takeSnapshot();

            const is: *const InputSnapshot = &inputFrame.snapshot;

            player.update(dt, is, .laser);

            totalTime += dt;
            frameTimeAcc -= dt;

            try inputFrame.beginNext();
        }

        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_RenderCopy(renderer, floorTexture, null, null);

        const jasonSrc: *const c.SDL_Rect = &.{
            .x = 256,
            .y = 0,
            .w = 128,
            .h = 128,
        };

        var alpha: f32 = frameTimeAcc / dt;

        const jasonTransform: entities.Transform = entities.Transform.lerp(player.prevTransform, player.transform, alpha);
        const jasonRenderPos: PointI32 = world.getScreenPosition(jasonTransform.pos);
        const jasonDest: *const c.SDL_Rect = &.{
            .x = @as(c_int, jasonRenderPos.x),
            .y = @as(c_int, jasonRenderPos.y),
            .w = 128,
            .h = 128,
        };
        const jasonCenter: *const c.SDL_Point = &.{
            .x = 64,
            .y = 64,
        };
        _ = c.SDL_RenderCopyEx(
            renderer,
            jasonTexture,
            jasonSrc,
            jasonDest,
            jasonTransform.facing.angle() * core.RAD_2_DEG,
            jasonCenter,
            c.SDL_FLIP_NONE,
        );
        c.SDL_RenderPresent(renderer);
    }
}

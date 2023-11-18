const core = @import("core.zig");
const Vector2 = core.Vector2;
const PointI32 = core.PointI32;
const std = @import("std");
const math = std.math;

pub const PIXELS_PER_UNIT: i32 = 128;
pub const PIXELS_PER_UNIT_F32: f32 = @as(f32, PIXELS_PER_UNIT);
pub const MIN_X: f32 = 0.75;
pub const MAX_X: f32 = 8.75;
pub const MIN_Y: f32 = 0.5;
pub const MAX_Y: f32 = 5.15;

pub fn getScreenPosition(pos: Vector2) PointI32 {
    const x: f32 = math.floor(pos.getX() * PIXELS_PER_UNIT);
    const y: f32 = math.floor(pos.getY() * PIXELS_PER_UNIT);

    return .{
        .x = @intFromFloat(x),
        .y = @intFromFloat(y),
    };
}

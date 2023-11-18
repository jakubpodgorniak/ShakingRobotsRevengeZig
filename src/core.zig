const std = @import("std");
const math = std.math;

pub const Vector2 = struct {
    pub const ZERO = Vector2{ .simd = .{ 0.0, 0.0 } };
    pub const UNIT_X = Vector2{ .simd = .{ 1.0, 0.0 } };
    pub const UNIT_Y = Vector2{ .simd = .{ 0.0, 1.0 } };

    simd: @Vector(2, f32),

    pub fn new(x: f32, y: f32) Vector2 {
        return Vector2{ .simd = .{ x, y } };
    }

    pub fn add(self: Vector2, other: Vector2) Vector2 {
        return Vector2{ .simd = self.simd + other.simd };
    }

    pub fn scale(self: Vector2, scalar: f32) Vector2 {
        return Vector2{ .simd = self.simd * @as(@TypeOf(self.simd), @splat(scalar)) };
    }

    pub fn normalize(self: Vector2) Vector2 {
        const ratio: f32 = 1.0 / math.sqrt((self.simd[0] * self.simd[0]) + (self.simd[1] * self.simd[1]));

        return Vector2{ .simd = .{ self.simd[0] * ratio, self.simd[1] * ratio } };
    }

    pub fn getX(self: Vector2) f32 {
        return self.simd[0];
    }

    pub fn getY(self: Vector2) f32 {
        return self.simd[1];
    }
};

pub const PointI32 = struct {
    pub const ZERO = PointI32{ .x = 0, .y = 0 };

    x: i32,
    y: i32,

    pub fn new(x: i32, y: i32) PointI32 {
        return PointI32{ .x = x, .y = y };
    }
};

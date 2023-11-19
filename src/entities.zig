const std = @import("std");
const Vector2 = @import("core.zig").Vector2;
const InputSnapshot = @import("input.zig").InputSnapshot;
const world = @import("world.zig");
const math = @import("std").math;

pub const WeaponType = enum(u8) {
    shotgun = 0,
    scythe = 1,
    laser = 2,
};

pub const Transform = struct {
    pos: Vector2,
    facing: Vector2,

    pub fn init(pos: Vector2, facing: Vector2) Transform {
        return Transform{
            .pos = pos,
            .facing = facing,
        };
    }

    pub fn updateWith(self: *Transform, other: Transform) void {
        self.pos = other.pos;
        self.facing = other.facing;
    }

    pub fn lerp(tA: Transform, tB: Transform, t: f32) Transform {
        return Transform{
            .pos = Vector2.lerp(tA.pos, tB.pos, t),
            .facing = Vector2.lerp(tA.facing, tB.facing, t),
        };
    }
};

pub const Player = struct {
    prevTransform: Transform,
    transform: Transform,
    immortal: bool,

    pub fn init(pos: Vector2) Player {
        return Player{
            .prevTransform = Transform.init(pos, Vector2.UNIT_X),
            .transform = Transform.init(pos, Vector2.UNIT_X),
            .immortal = false,
        };
    }

    pub fn update(self: *Player, dt: f32, is: *const InputSnapshot) void {
        self.prevTransform.updateWith(self.transform);

        // movement
        var move: Vector2 = Vector2.ZERO;

        var moved = false;

        const moveUp: bool = is.isKeyPressed(.w);
        const moveLeft: bool = is.isKeyPressed(.a);
        const moveRight: bool = is.isKeyPressed(.d);
        const moveDown: bool = is.isKeyPressed(.s);

        if (moveLeft and !moveRight) {
            move = move.add(Vector2.UNIT_X.scale(-1));
            moved = true;
        }

        if (moveRight and !moveLeft) {
            move = move.add(Vector2.UNIT_X);
            moved = true;
        }

        if (moveUp and !moveDown) {
            move = move.add(Vector2.UNIT_Y.scale(-1));
            moved = true;
        }

        if (moveDown and !moveUp) {
            move = move.add(Vector2.UNIT_Y);
            moved = true;
        }

        if (moved) {
            move = move.normalize();

            self.transform.pos = self.transform.pos.add(move.scale(dt * 2.0)); // 2,0 = movement speed
        }

        // rotation
        const mouseWorldPos: Vector2 = world.screen2World(is.mouse.pos);
        const newFacing: Vector2 = mouseWorldPos.sub(self.transform.pos).normalize();

        self.transform.facing = Vector2.lerp(self.transform.facing, newFacing, 10 * dt); // 10 is rotation speed
    }
};

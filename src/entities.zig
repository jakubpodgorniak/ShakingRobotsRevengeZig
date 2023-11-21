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
    const MOVEMENT_SPEED: f32 = 2.0;
    const ROTATION_SPEED: f32 = 10.0;
    const MOVEMENT_SPEED_WITH_LASER: f32 = 0.5;
    const ROTATION_SPEED_WITH_LASER: f32 = 20.0;

    const SHOUTGUN_SHOOT_POINT_RELATIVE = Vector2.new(0.4, 0.165);
    const LASER_SHOOT_POINT_RELATIVE = Vector2.new(0.33, 0.18);
    const SCYTHE_PIVOT_RELATIVE = Vector2.new(0.1, 0.1);

    prevTransform: Transform,
    transform: Transform,
    immortal: bool,
    shotgunShootPointWorld: Vector2,
    laserShootPointWorld: Vector2,
    scythePivotWorld: Vector2,
    isDead: bool,

    pub fn init(pos: Vector2) Player {
        return Player{
            .prevTransform = Transform.init(pos, Vector2.UNIT_X),
            .transform = Transform.init(pos, Vector2.UNIT_X),
            .immortal = false,
            .shotgunShootPointWorld = Vector2.ZERO,
            .laserShootPointWorld = Vector2.ZERO,
            .scythePivotWorld = Vector2.ZERO,
            .isDead = false,
        };
    }

    pub fn update(self: *Player, dt: f32, is: *const InputSnapshot, currentWeapon: WeaponType) void {
        self.prevTransform.updateWith(self.transform);

        const isUsingLaser: bool = currentWeapon == .laser and laser.isTurnOn;

        const speeds: struct { rotationSpeed: f32, movementSpeed: f32 } = if (isUsingLaser) .{
            .rotationSpeed = Player.ROTATION_SPEED_WITH_LASER,
            .movementSpeed = Player.MOVEMENT_SPEED_WITH_LASER,
        } else .{
            .rotationSpeed = Player.ROTATION_SPEED,
            .movementSpeed = Player.MOVEMENT_SPEED,
        };

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

            self.transform.pos = self.transform.pos.add(move.scale(dt * speeds.movementSpeed));
        }

        // rotation
        const mouseWorldPos: Vector2 = world.screen2World(is.mouse.pos);
        const newFacing: Vector2 = mouseWorldPos.sub(self.transform.pos).normalize();

        // @NOTE: This can fail if dt * speeds.rotationSpeed not in range <0, 1>
        self.transform.facing = Vector2.lerp(self.transform.facing, newFacing, dt * speeds.rotationSpeed);
    }
};

const Laser = struct {
    const LASER_POWER: f32 = 10.0;
    const LASER_LENGT: f32 = 25.0;

    // enemiesHit: ArrayList(Enemy),
    isTurnOn: bool,
    lastShootOrigin: Vector2,
    lastShootEnd: Vector2,

    pub fn init() Laser {
        return Laser{
            .isTurnOn = false,
            .lastShootOrigin = Vector2.ZERO,
            .lastShootEnd = Vector2.ZERO,
        };
    }
};

var laser = Laser.init();

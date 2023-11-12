const Vector2 = @import("core.zig").Vector2;

pub const WeaponType = enum(u8) {
    shotgun = 0,
    scythe = 1,
    laser = 2,
};

pub const Player = struct {
    position: Vector2,
    facing: Vector2 = Vector2.UNIT_X,
    immortal: bool,

    pub fn update(self: *Player, dt: f32) void {
        _ = dt;
        _ = self;
        // movement
        const move: Vector2 = Vector2.ZERO;
        _ = move;

        var moved = false;
        _ = moved;

        var moveUp = false;
        _ = moveUp; // get input info
        var moveLeft = false; // get input info
        var moveRight = false; // get input info
        var moveDown = false;
        _ = moveDown; // get input info

        if (moveLeft and !moveRight) {}
    }
};

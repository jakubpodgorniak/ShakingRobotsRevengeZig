const Vector2 = @import("core.zig").Vector2;
const InputSnapshot = @import("input.zig").InputSnapshot;

pub const WeaponType = enum(u8) {
    shotgun = 0,
    scythe = 1,
    laser = 2,
};

pub const Player = struct {
    position: Vector2,
    facing: Vector2 = Vector2.UNIT_X,
    immortal: bool,

    pub fn update(self: *Player, dt: f32, inputSnapshot: *const InputSnapshot) void {
        _ = dt;
        _ = self;
        // movement
        const move: Vector2 = Vector2.ZERO;
        _ = move;

        var moved = false;
        _ = moved;

        var moveUp: bool = inputSnapshot.isKeyPressed(.up);
        _ = moveUp; // get input info
        var moveLeft: bool = inputSnapshot.isKeyPressed(.left);
        var moveRight: bool = inputSnapshot.isKeyPressed(.right);
        var moveDown: bool = inputSnapshot.isKeyPressed(.down);
        _ = moveDown; // get input info

        if (moveLeft and !moveRight) {}
    }
};

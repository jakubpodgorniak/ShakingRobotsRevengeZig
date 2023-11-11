const Vector2 = @Vector(2, f32);
const Vector2_UnitX: Vector2 = .{ 1.0, 0.0 };
const Vector2_UnitY: Vector2 = .{ 0.0, 1.0 };

const WeaponType = enum(u8) {
    shotgun = 0,
    scythe = 1,
    laser = 2,
};

pub const Player = struct {
    position: Vector2,
    facing: Vector2 = .{ 1.0, 0.0 },
    immortal: bool,

    pub fn update(self: Player, dt: f32) void {
        _ = dt;
        _ = self;
        // movement
        const move: Vector2 = .{ 0.0, 0.0 };
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

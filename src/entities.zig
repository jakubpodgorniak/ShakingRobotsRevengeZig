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

    pub fn update(self: *Player, dt: f32, is: *const InputSnapshot) void {
        // movement
        var move: Vector2 = Vector2.ZERO;

        var moved = false;

        const moveUp: bool = is.isKeyPressed(.up);
        const moveLeft: bool = is.isKeyPressed(.left);
        const moveRight: bool = is.isKeyPressed(.right);
        const moveDown: bool = is.isKeyPressed(.down);

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

            self.position = self.position.add(move.scale(dt * 2.0)); // 2,0 = movement speed
        }
    }
};

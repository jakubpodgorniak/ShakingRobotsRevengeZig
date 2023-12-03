const std = @import("std");
const Vector2 = @import("core.zig").Vector2;
const InputSnapshot = @import("input.zig").InputSnapshot;
const world = @import("world.zig");
const math = @import("std").math;
const Allocator = std.mem.Allocator;
const Rand = std.rand.DefaultPrng;

pub const WeaponType = enum(u8) {
    shotgun = 0,
    scythe = 1,
    laser = 2,
};

pub const Transform = struct {
    const ZERO = Transform.init(Vector2.ZERO, Vector2.ZERO);

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

    pub fn kill(self: *Player) void {
        if (self.immortal) {
            return;
        }

        self.isDead = true;
    }

    pub fn revive(self: *Player) void {
        self.isDead = false;
    }
};

pub const Tile = struct {
    heat: f32,
    guideDirection: Vector2,
};

const CircleCollider = struct {
    radius: f32,
    position: Vector2,
};

const PointCollider = struct {
    position: Vector2,
};

const EnemyState = enum(u8) {
    none,
    inactive,
    goesIn,
    fightsJason,
};

const Enemy = struct {
    index: usize,
    state: EnemyState,
    movementSpeed: f32,
    rotationSpeed: f32,
    prevTransform: Transform,
    transform: Transform,
    collider: CircleCollider,
    health: f32,
};

const EnemySpawner = struct {
    pos: Vector2,
    direction: Vector2,
};

pub const EnemiesManager = struct {
    const MAX_ENEMIES_COUNT: i32 = 300;
    const RIGHT_UP_UNIT_VECTOR_2: Vector2 = Vector2.new(1.0, -1.0).normalize();
    const RIGHT_DOWN_UNIT_VECTOR_2: Vector2 = Vector2.new(1.0, 1.0).normalize();
    const LEFT_UP_UNIT_VECTOR_2: Vector2 = Vector2.new(-1.0, -1.0).normalize();
    const LEFT_DOWN_UNIT_VECTOR_2: Vector2 = Vector2.new(-1.0, 1.0).normalize();

    const IndexesQueue = std.TailQueue(usize);

    const TILE_MAP_WIDTH: i32 = 44;
    const TILE_MAP_HEIGHT: i32 = 36;
    const TILE_MAP_TILE_SIZE: f32 = 0.25;

    enemies: [MAX_ENEMIES_COUNT]Enemy,
    inactiveEnemiesIndexesQueueNodes: [MAX_ENEMIES_COUNT]IndexesQueue.Node,
    inactiveEnemiesIndexes: IndexesQueue,
    enemiesGoingIn: std.ArrayList(*Enemy),
    fightingEnemies: std.ArrayList(*Enemy),
    rand: *Rand,
    tileMap: [TILE_MAP_WIDTH][TILE_MAP_HEIGHT]Tile,

    const spawners = [_]EnemySpawner{
        EnemySpawner{ .pos = Vector2.new(2.3, 0.1), .direction = Vector2.new(0.0, 1.0) }, // up 1
        EnemySpawner{ .pos = Vector2.new(7.2, 0.1), .direction = Vector2.new(0.0, 1.0) }, // up 2
        EnemySpawner{ .pos = Vector2.new(9.5, 1.5), .direction = Vector2.new(-1.0, 0.0) }, // right 1
        EnemySpawner{ .pos = Vector2.new(9.5, 4.0), .direction = Vector2.new(-1.0, 0.0) }, // right 2
        EnemySpawner{ .pos = Vector2.new(7.2, 5.5), .direction = Vector2.new(0.0, -1.0) }, // down 1
        EnemySpawner{ .pos = Vector2.new(4.9, 5.5), .direction = Vector2.new(0.0, -1.0) }, // down 2
        EnemySpawner{ .pos = Vector2.new(2.3, 5.5), .direction = Vector2.new(0.0, -1.0) }, // down 3
        EnemySpawner{ .pos = Vector2.new(0.1, 4.0), .direction = Vector2.new(1.0, 0.0) }, // left 1
        EnemySpawner{ .pos = Vector2.new(0.1, 1.5), .direction = Vector2.new(1.0, 0.0) }, // left 2
    };

    pub fn init(allocator: Allocator, rand: *Rand) EnemiesManager {
        return EnemiesManager{
            .enemies = initEnemies: {
                var initialEnemies: [EnemiesManager.MAX_ENEMIES_COUNT]Enemy = undefined;
                for (&initialEnemies, 0..) |*enemy, i| {
                    enemy.* = Enemy{
                        .index = i,
                        .state = .none,
                        .movementSpeed = 0,
                        .rotationSpeed = 0,
                        .prevTransform = Transform.ZERO,
                        .transform = Transform.ZERO,
                        .collider = CircleCollider{ .radius = 0.25, .position = Vector2.ZERO },
                        .health = 1.0,
                    };
                }
                break :initEnemies initialEnemies;
            },
            .inactiveEnemiesIndexesQueueNodes = initInactiveEnemiesIndexesQueueNodes: {
                var nodes: [EnemiesManager.MAX_ENEMIES_COUNT]IndexesQueue.Node = undefined;
                for (&nodes, 0..) |*node, i| {
                    node.* = IndexesQueue.Node{ .data = i };
                }
                break :initInactiveEnemiesIndexesQueueNodes nodes;
            },
            .inactiveEnemiesIndexes = IndexesQueue{},
            .enemiesGoingIn = std.ArrayList(*Enemy).init(allocator),
            .fightingEnemies = std.ArrayList(*Enemy).init(allocator),
            .rand = rand,
            .tileMap = initTileMap: {
                var initialTileMap: [TILE_MAP_WIDTH][TILE_MAP_HEIGHT]Tile = undefined;
                for (initialTileMap, 0..) |_, i| {
                    for (initialTileMap[i], 0..) |_, j| {
                        initialTileMap[i][j] = Tile{ .heat = 0.0, .guideDirection = Vector2.ZERO };
                    }
                }

                break :initTileMap initialTileMap;
            },
        };
    }

    pub fn deinit(self: *EnemiesManager) void {
        self.enemiesGoingIn.deinit();
        self.fightingEnemies.deinit();
    }

    pub fn getEnemiesLeftToSpawnNumber(self: *EnemiesManager) usize {
        return self.inactiveEnemiesIndexes.len;
    }

    pub fn reset(self: *EnemiesManager) void {
        for (self.enemies) |enemy| {
            _ = enemy;
        }
    }

    fn inactivateEnemy(self: *EnemiesManager, enemy: *Enemy) void {
        if (enemy.state == .inactive) {
            return;
        }

        enemy.state = .inactive;
        self.inactiveEnemiesIndexes.append(&IndexesQueue.Node{ .data = enemy.index });
    }

    pub fn spawnRandomEnemy(self: *EnemiesManager) void {
        if (self.inactiveEnemiesIndexes.len == 0) {
            return;
        }

        var spawner: EnemySpawner = self.spawners[@as(usize, self.rand.random().next() % self.spawners.len)];
        var enemyIndex: usize = self.inactiveEnemiesIndexes.pop().data;
        var enemy: Enemy = self.enemies[enemyIndex];

        const LEVEL_RATIO: f32 = 0.05;
        const MAX_LEVEL_RATIO: f32 = 0.5;

        // @TODO: GAME TEN SECONDS LEVEL
        const GAME_TEN_SECONDS_LEVEL: i32 = 2;
        var additionalSpeedByLevel: f32 = math.floatMin(GAME_TEN_SECONDS_LEVEL * LEVEL_RATIO, MAX_LEVEL_RATIO);

        enemy.position = spawner.pos;
        enemy.facing = spawner.direction;
        enemy.movementSpeed = 0.3 + (0.8 * self.rand.random().float(f32)) + additionalSpeedByLevel;
        enemy.rotationSpeed = 3.0;
        enemy.state = .goesIn;
        enemy.collider = CircleCollider{
            .position = enemy.position,
            .radius = 0.25,
        };
    }

    fn getTilePosition(position: Vector2) struct { tileX: i32, tileY: i32 } {
        _ = position;
        //tileMap = @as(i32, math.floor(position.x / TILE_MAP_TILE_SIZE));
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

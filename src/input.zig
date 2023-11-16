const std = @import("std");
const assert = std.debug.assert;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const testing = std.testing;

pub const Scancode = enum(u16) {
    unknown = 0,
    a = 4,
    b = 5,
    c = 6,
    d = 7,
    e = 8,
    f = 9,
    g = 10,
    h = 11,
    i = 12,
    j = 13,
    k = 14,
    l = 15,
    m = 16,
    n = 17,
    o = 18,
    p = 19,
    q = 20,
    r = 21,
    s = 22,
    t = 23,
    u = 24,
    v = 25,
    w = 26,
    x = 27,
    y = 28,
    z = 29,
    d1 = 30,
    d2 = 31,
    d3 = 32,
    d4 = 33,
    d5 = 34,
    d6 = 35,
    d7 = 36,
    d8 = 37,
    d9 = 38,
    d0 = 39,
    enter = 40,
    escape = 41,
    backspace = 42,
    tab = 43,
    space = 44,
    minus = 45,
    equals = 46,
    leftBracket = 47,
    rightBracket = 48,
    backSlash = 49,
    nonUsHash = 50,
    semicolon = 51,
    apostrophe = 52,
    grave = 53,
    comma = 54,
    period = 55,
    slash = 56,
    capslock = 57,
    f1 = 58,
    f2 = 59,
    f3 = 60,
    f4 = 61,
    f5 = 62,
    f6 = 63,
    f7 = 64,
    f8 = 65,
    f9 = 66,
    f10 = 67,
    f11 = 68,
    f12 = 69,
    printScreen = 70,
    scrollLock = 71,
    pause = 72,
    insert = 73,
    home = 74,
    pageUp = 75,
    delete = 76,
    end = 77,
    pageDown = 78,
    right = 79,
    left = 80,
    down = 81,
    up = 82,
    numLockClear = 83,
    kpDivide = 84,
    kpMultiply = 85,
    kpMinus = 86,
    kpPlus = 87,
    kpEnter = 88,
    kp1 = 89,
    kp2 = 90,
    kp3 = 91,
    kp4 = 92,
    kp5 = 93,
    kp6 = 94,
    kp7 = 95,
    kp8 = 96,
    kp9 = 97,
    kp0 = 98,
    kpPeriod = 99,
    nonUsBackSlash = 100,
    application = 101,
    power = 102,
    kpEquals = 103,
    f13 = 104,
    f14 = 105,
    f15 = 106,
    _f16 = 107,
    f17 = 108,
    f18 = 109,
    f19 = 110,
    f20 = 111,
    f21 = 112,
    f22 = 113,
    f23 = 114,
    f24 = 115,
    execute = 116,
    help = 117,
    menu = 118,
    select = 119,
    stop = 120,
    again = 121,
    undo = 122,
    cut = 123,
    copy = 124,
    paste = 125,
    find = 126,
    mute = 127,
    volumeUp = 128,
    volumeDown = 129,
    kpComma = 133,
    kpEqualsSas400 = 134,
    international1 = 135,
    international2 = 136,
    international3 = 137,
    international4 = 138,
    international5 = 139,
    international6 = 140,
    international7 = 141,
    international8 = 142,
    international9 = 143,
    lang1 = 144,
    lang2 = 145,
    lang3 = 146,
    lang4 = 147,
    lang5 = 148,
    lang6 = 149,
    lang7 = 150,
    lang8 = 151,
    lang9 = 152,
    altErase = 153,
    sysReq = 154,
    cancel = 155,
    clear = 156,
    prior = 157,
    return2 = 158,
    separator = 159,
    out = 160,
    oper = 161,
    clearAgain = 162,
    crsel = 163,
    exsel = 164,
    kp00 = 176,
    kp000 = 177,
    thousandSeparator = 178,
    decimalSeparator = 179,
    currencyUnit = 180,
    currencySubUnit = 181,
    kpLeftParen = 182,
    kpRightParen = 183,
    kpLeftBrace = 184,
    kpRightBrache = 185,
    kpTab = 186,
    kpBackspace = 187,
    kpA = 188,
    kpB = 189,
    kpC = 190,
    kpD = 191,
    kpE = 192,
    kpF = 193,
    kpXor = 194,
    kpPower = 195,
    kpPercent = 196,
    kpLess = 197,
    kpGreater = 198,
    kpAmpersand = 199,
    kpDblAmpersand = 200,
    kpVerticalBar = 201,
    kpDblVerticalBar = 202,
    kpColor = 203,
    kpHash = 204,
    kpSpace = 205,
    kpAt = 206,
    kpExclam = 207,
    kpMemStore = 208,
    kpMemRecall = 209,
    kpMemClear = 210,
    kpMemAdd = 211,
    kpMemSubtract = 212,
    kpMemMultiply = 213,
    kpMemDivide = 214,
    kpPlusMinus = 215,
    kpClear = 216,
    kpClearEntry = 217,
    kpBinary = 218,
    kpOctal = 219,
    kpDecimal = 220,
    kpHexadecimal = 221,
    lctrl = 224,
    lshift = 225,
    lalt = 226,
    lgui = 227,
    rctrl = 228,
    rshift = 229,
    ralt = 230,
    rgui = 231,
    mode = 257,
    audionext = 258,
    audioprev = 259,
    audiostop = 260,
    audioplay = 261,
    audiomute = 262,
    mediaselect = 263,
    www = 264,
    mail = 265,
    calculator = 266,
    computer = 267,
    acSearch = 268,
    acHome = 269,
    acBack = 270,
    acForward = 271,
    acStop = 272,
    acRefresh = 273,
    acBookmarks = 274,
    brightnessdown = 275,
    brightnessup = 276,
    displayswitch = 277,
    kbdillumtoggle = 278,
    kbdillumdown = 279,
    kbdillumup = 280,
    eject = 281,
    sleep = 282,
    app1 = 283,
    app2 = 284,
};

pub const InputSnapshot = struct {
    downKeys: ArrayList(Scancode),
    upKeys: ArrayList(Scancode),
    pressedKeys: ArrayList(Scancode),

    pub fn init(allocator: Allocator) InputSnapshot {
        return InputSnapshot{
            .downKeys = ArrayList(Scancode).init(allocator),
            .upKeys = ArrayList(Scancode).init(allocator),
            .pressedKeys = ArrayList(Scancode).init(allocator),
        };
    }

    pub fn deinit(self: *InputSnapshot) void {
        self.downKeys.deinit();
        self.upKeys.deinit();
        self.pressedKeys.deinit();
    }

    pub fn reset(self: *InputSnapshot) void {
        self.downKeys.clearAndFree();
        self.upKeys.clearAndFree();
        self.pressedKeys.clearAndFree();
    }

    pub fn isKeyDown(self: *const InputSnapshot, code: Scancode) bool {
        for (self.downKeys.items) |downKeyCode| {
            if (downKeyCode == code) {
                return true;
            }
        }

        return false;
    }

    pub fn isKeyUp(self: *const InputSnapshot, code: Scancode) bool {
        for (self.upKeys.items) |upKeyCode| {
            if (upKeyCode == code) {
                return true;
            }
        }

        return false;
    }

    pub fn isKeyPressed(self: *const InputSnapshot, code: Scancode) bool {
        for (self.pressedKeys.items) |pressedKeyCode| {
            if (pressedKeyCode == code) {
                return true;
            }
        }

        return false;
    }
};

test "input.InputSnapshot.init" {
    var snapshot = InputSnapshot.init(testing.allocator);
    defer snapshot.deinit();

    try testing.expect(snapshot.downKeys.allocator.ptr == testing.allocator.ptr);
    try testing.expect(snapshot.upKeys.allocator.ptr == testing.allocator.ptr);
    try testing.expect(snapshot.pressedKeys.allocator.ptr == testing.allocator.ptr);
}

test "input.InputSnapshot.deinit" {
    var snapshot = InputSnapshot.init(testing.allocator);
    try snapshot.downKeys.append(.d1);
    try snapshot.upKeys.append(.d2);
    try snapshot.pressedKeys.append(.d3);

    snapshot.deinit();
}

test "input.InputSnapshot.reset" {
    var snapshot = InputSnapshot.init(testing.allocator);
    defer snapshot.deinit();
    try snapshot.downKeys.append(.d1);
    try snapshot.upKeys.append(.d2);
    try snapshot.pressedKeys.append(.d3);

    snapshot.reset();

    try testing.expect(snapshot.downKeys.items.len == 0);
    try testing.expect(snapshot.upKeys.items.len == 0);
    try testing.expect(snapshot.pressedKeys.items.len == 0);
}

test "input.InputSnapshot.isKeyDown" {
    var snapshot = InputSnapshot.init(testing.allocator);
    defer snapshot.deinit();

    try testing.expect(snapshot.isKeyDown(.d1) == false);

    try snapshot.downKeys.append(.d1);

    try testing.expect(snapshot.isKeyDown(.d1) == true);
}

test "input.InputSnapshot.isKeyUp" {
    var snapshot = InputSnapshot.init(testing.allocator);
    defer snapshot.deinit();

    try testing.expect(snapshot.isKeyUp(.d1) == false);

    try snapshot.upKeys.append(.d1);

    try testing.expect(snapshot.isKeyUp(.d1) == true);
}

test "input.InputSnapshot.isKeyPressed" {
    var snapshot = InputSnapshot.init(testing.allocator);
    defer snapshot.deinit();

    try testing.expect(snapshot.isKeyPressed(.d1) == false);

    try snapshot.pressedKeys.append(.d1);

    try testing.expect(snapshot.isKeyPressed(.d1) == true);
}

const InputFrameState = enum(u8) {
    new,
    registration,
    registrationFinished,
};

const InputFrameError = error{
    RegistrationStartedTwice,
    NotInRegistration,
};

pub const InputFrame = struct {
    prevPressedKeys: ArrayList(Scancode),
    pressedKeys: ArrayList(Scancode),
    snapshot: InputSnapshot,
    state: InputFrameState,

    pub fn init(allocator: Allocator) InputFrame {
        return InputFrame{
            .prevPressedKeys = ArrayList(Scancode).init(allocator),
            .pressedKeys = ArrayList(Scancode).init(allocator),
            .snapshot = InputSnapshot.init(allocator),
            .state = .new,
        };
    }

    pub fn deinit(self: *InputFrame) void {
        self.prevPressedKeys.deinit();
        self.pressedKeys.deinit();
        self.snapshot.deinit();
    }

    pub fn beginNext(self: *InputFrame) !void {
        if (self.state == .registration) return InputFrameError.RegistrationStartedTwice;

        self.prevPressedKeys.clearAndFree();

        try self.prevPressedKeys.appendSlice(self.pressedKeys.items);

        self.state = .registration;
    }

    pub fn registerKeyDown(self: *InputFrame, code: Scancode) !void {
        if (self.state != .registration) return InputFrameError.NotInRegistration;

        try self.pressedKeys.append(code);
    }

    pub fn registerKeyUp(self: *InputFrame, code: Scancode) InputFrameError!void {
        if (self.state != .registration) return InputFrameError.NotInRegistration;

        const index: ?usize = for (self.pressedKeys.items, 0..) |pressedKey, i| {
            if (pressedKey == code) {
                break i;
            }
        } else null;

        assert(index != null);

        _ = self.pressedKeys.swapRemove(index.?);
    }

    pub fn takeSnapshot(self: *InputFrame) !void {
        if (self.state != .registration) return InputFrameError.NotInRegistration;

        self.snapshot.reset();

        for (self.pressedKeys.items) |pressedKey| {
            try self.snapshot.pressedKeys.append(pressedKey);

            var wasPressedBefore = false;
            for (self.prevPressedKeys.items) |prevPressedKey| {
                if (prevPressedKey == pressedKey) {
                    wasPressedBefore = true;
                    break;
                }
            }

            if (!wasPressedBefore) {
                try self.snapshot.downKeys.append(pressedKey);
            }
        }

        for (self.prevPressedKeys.items) |prevPressedKey| {
            var isStillPressed = false;

            for (self.pressedKeys.items) |pressedKey| {
                if (prevPressedKey == pressedKey) {
                    isStillPressed = true;
                    break;
                }
            }

            if (!isStillPressed) {
                try self.snapshot.upKeys.append(prevPressedKey);
            }
        }

        self.state = .registrationFinished;
    }
};

test "input.InputFrame.init" {
    var frame = InputFrame.init(testing.allocator);
    defer frame.deinit();

    try testing.expect(frame.prevPressedKeys.allocator.ptr == testing.allocator.ptr);
    try testing.expect(frame.pressedKeys.allocator.ptr == testing.allocator.ptr);
    try testing.expect(frame.snapshot.downKeys.allocator.ptr == testing.allocator.ptr); // only one, it's enough, other checked in own test
    try testing.expect(frame.state == .new);
}

test "input.InputFrame.deinit" {
    var frame = InputFrame.init(testing.allocator);
    try frame.prevPressedKeys.append(.d1);
    try frame.pressedKeys.append(.d2);
    try frame.snapshot.downKeys.append(.d3);

    frame.deinit();
}

test "input.InputFrame.beginNext twice" {
    var frame = InputFrame.init(testing.allocator);
    defer frame.deinit();

    try frame.beginNext();
    try testing.expectError(InputFrameError.RegistrationStartedTwice, frame.beginNext());
}

test "input.InputFrame.registerKeyDown without beginNext" {
    var frame = InputFrame.init(testing.allocator);
    defer frame.deinit();

    try testing.expectError(InputFrameError.NotInRegistration, frame.registerKeyDown(.d1));
}

test "input.InputFrame.registerKeyUp without beginNext" {
    var frame = InputFrame.init(testing.allocator);
    defer frame.deinit();

    try testing.expectError(InputFrameError.NotInRegistration, frame.registerKeyUp(.d1));
}

test "input.InputFrame.takeSnapshot without beginNext" {
    var frame = InputFrame.init(testing.allocator);
    defer frame.deinit();

    try testing.expectError(InputFrameError.NotInRegistration, frame.takeSnapshot());
}

test "input.InputFrame" {
    var frame = InputFrame.init(testing.allocator);
    defer frame.deinit();

    try frame.beginNext();
    try frame.registerKeyDown(.d1);
    try frame.takeSnapshot();

    try testing.expect(frame.snapshot.isKeyDown(.d1) == true);
    try testing.expect(frame.snapshot.isKeyPressed(.d1) == true);
    try testing.expect(frame.snapshot.isKeyUp(.d1) == false);

    try frame.beginNext();
    try frame.takeSnapshot();

    try testing.expect(frame.snapshot.isKeyDown(.d1) == false);
    try testing.expect(frame.snapshot.isKeyPressed(.d1) == true);
    try testing.expect(frame.snapshot.isKeyUp(.d1) == false);

    try frame.beginNext();
    try frame.registerKeyUp(.d1);
    try frame.takeSnapshot();

    try testing.expect(frame.snapshot.isKeyDown(.d1) == false);
    try testing.expect(frame.snapshot.isKeyPressed(.d1) == false);
    try testing.expect(frame.snapshot.isKeyUp(.d1) == true);

    try frame.beginNext();
    try frame.registerKeyDown(.d1);
    try frame.registerKeyDown(.d2);
    try frame.takeSnapshot();

    try testing.expect(frame.snapshot.isKeyDown(.d1) == true);
    try testing.expect(frame.snapshot.isKeyPressed(.d1) == true);
    try testing.expect(frame.snapshot.isKeyUp(.d1) == false);
    try testing.expect(frame.snapshot.isKeyDown(.d2) == true);
    try testing.expect(frame.snapshot.isKeyPressed(.d2) == true);
    try testing.expect(frame.snapshot.isKeyUp(.d2) == false);

    try frame.beginNext();
    try frame.registerKeyUp(.d1);
    try frame.takeSnapshot();

    try testing.expect(frame.snapshot.isKeyDown(.d1) == false);
    try testing.expect(frame.snapshot.isKeyPressed(.d1) == false);
    try testing.expect(frame.snapshot.isKeyUp(.d1) == true);
    try testing.expect(frame.snapshot.isKeyDown(.d2) == false);
    try testing.expect(frame.snapshot.isKeyPressed(.d2) == true);
    try testing.expect(frame.snapshot.isKeyUp(.d2) == false);

    try frame.beginNext();
    try frame.registerKeyUp(.d2);
    try frame.takeSnapshot();

    try testing.expect(frame.snapshot.isKeyDown(.d1) == false);
    try testing.expect(frame.snapshot.isKeyPressed(.d1) == false);
    try testing.expect(frame.snapshot.isKeyUp(.d1) == false);
    try testing.expect(frame.snapshot.isKeyDown(.d2) == false);
    try testing.expect(frame.snapshot.isKeyPressed(.d2) == false);
    try testing.expect(frame.snapshot.isKeyUp(.d2) == true);
}

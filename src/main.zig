const ble = @import("ble/ble.zig");
const ble_dev = @import("ble/ble_dev.zig");

const config = @import("config.zig");
const kscan = @import("kscan.zig");
const engine = @import("core/engine.zig");
const output_hid = @import("core/output_hid.zig");

const pmu = @import("hal/pmu.zig");
const clocks = @import("hal/clocks.zig");
const gpio = @import("hal/gpio.zig");

const led_1 = config.sys.led_1;

pub inline fn main() noreturn {
    pmu.useDcDc(true);

    clocks.use(config.sys.clock);
    clocks.useXt32k(false);

    led_1.config(.output);
    led_1.write(true);

    ble.init() catch unreachable;
    ble.initPeripheralRole() catch unreachable;

    ble_dev.init();
    kscan.init();

    while (true) {
        while (output_hid.popReport()) |*report| {
            ble_dev.notifyHidReport(@constCast(report));
        }

        kscan.process();
        engine.process();
        ble.process();
    }
}

export fn _zigstart() noreturn {
    main();
}

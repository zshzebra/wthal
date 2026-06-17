const kernel = @import("kernel");

// TODO: Some real payload
export fn _start() noreturn {
    kernel.kernel_main();

    while (true) {
        asm volatile ("wfi");
    }
}

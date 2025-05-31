# tinyxml2 Zig Build Integration

Zig build system integration for [tinyxml2](https://github.com/leethomason/tinyxml2) 

## Quick Start

1. Add to your project:
```bash
zig fetch --save git+https://github.com/neelsani/tinyxml2
```
2. Add to your build.zig

```zig
const tinyxml2_dep = b.dependency("tinyxml2", .{
    .target = target,
    .optimize = optimize,
});
const lib = tinyxml2_dep.artifact("tinyxml2");

//then link it to your exe

exe.linkLibrary(lib);
```
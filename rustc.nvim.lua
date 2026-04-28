require('lspsettings').extend {
  ['rust-analyzer'] = {
    linkedProjects = {
      "Cargo.toml",
      "compiler/rustc_codegen_cranelift/Cargo.toml",
      "compiler/rustc_codegen_gcc/Cargo.toml",
      "library/Cargo.toml",
      "src/bootstrap/Cargo.toml",
      "src/tools/rust-analyzer/Cargo.toml"
    },
    check = {
      invocationStrategy = "once",
      overrideCommand = {
        "python3",
        "x.py",
        "check",
        "--json-output",
        "--build-dir",
        "build-rust-analyzer"
      },
    },
    rustfmt = {
      overrideCommand = {
        "build/host/rustfmt/bin/rustfmt",
        "--edition=2024"
      }
    },
    procMacro = {
      server = "build/host/stage0/libexec/rust-analyzer-proc-macro-srv",
      enable = true
    },
    rustc = {
      source = "./Cargo.toml"
    },
    cargo = {
      sysrootSrc = "./library",
      extraEnv = { RUSTC_BOOTSTRAP = "1" },
      buildScripts = {
        enable = true,
        invocationStrategy = "once",
        overrideCommand = {
          "python3",
          "x.py",
          "check",
          "--json-output",
          "--compile-time-deps",
          "--build-dir",
          "build-rust-analyzer"
        }
      }
    },
    server = {
      extraEnv = {
        RUSTC = "build/host/stage0/bin/rustc",
        CARGO = "build/host/stage0/bin/cargo"
      }
    }
  }
}

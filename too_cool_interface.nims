when defined(emscripten):
  --define:GraphicsApiOpenGlEs2
  # --define:NaylibWebResources
  --os:linux
  --cpu:wasm32
  --cc:clang
  when defined(windows):
    --clang.exe:emcc.bat
    --clang.linkerexe:emcc.bat
    --clang.cpp.exe:emcc.bat
    --clang.cpp.linkerexe:emcc.bat
  else:
    --clang.exe:emcc
    --clang.linkerexe:emcc
    --clang.cpp.exe:emcc
    --clang.cpp.linkerexe:emcc
  --mm:orc
  --threads:off
  --panics:on
  --define:noSignalHandler
  --passL:"-o tci.html"
  # --passC:"-IC:/Users/Nicholas/.nimble/pkgs2/naylib-4.6.1-b8dba6d8ec2d85d03665077430f315612b508f4c/raylib/src"
  # Use raylib/src/shell.html or raylib/src/minshell.html
  --passL:"--shell-file minshell.html"

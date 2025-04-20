{pkgs}: {
  channel = "stable-24.05";
  packages = [
    pkgs.jdk17
    pkgs.unzip
    pkgs.android-tools
    pkgs.apt
    pkgs.sudo
    pkgs.cmake
    pkgs.android-tools
    pkgs.android-studio-tools
  ];
  idx.extensions = [
    
  
 "Dart-Code.dart-code"
 "Dart-Code.flutter"
 "esbenp.prettier-vscode"
 "HanWang.android-adb-wlan"
 "usernamehw.errorlens"];
  idx.previews = {
    previews = {
      web = {
        command = [
          "flutter"
          "run"
          "--machine"
          "-d"
          "web-server"
          "--web-hostname"
          "0.0.0.0"
          "--web-port"
          "$PORT"
        ];
        manager = "flutter";
      };
      android = {
        command = [
          "flutter"
          "run"
          "--machine"
          "-d"
          "android"
          "-d"
          "localhost:5555"
        ];
        manager = "flutter";
      };
    };
  };
}
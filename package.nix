{
  lib,
  rustPlatform,
  src,
  pkg-config,
  wrapGAppsHook4,
  glib,
  gettext,
  cairo,
  gdk-pixbuf,
  graphene,
  gtk4,
  libadwaita,
  openssl,
  pango,
  poppler_gi,
  vte-gtk4,
  ffmpeg,
  icoutils,
  imagemagick,
  p7zip,
}:
rustPlatform.buildRustPackage {
  pname = "flux-filemanager";
  version = "0.8.0-unstable-${src.shortRev or (builtins.substring 0 7 src.rev)}";
  inherit src;

  cargoHash = "sha256-9Ecyl40xN8PiwGM6k10OEEljMXnq6u6ntPLDDgSDxlQ=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    glib
    gettext
  ];

  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    graphene
    gtk4
    libadwaita
    openssl
    pango
    poppler_gi
    vte-gtk4
  ];

  # 上流の保護パステストは /usr/../etc/ の正規化も試すが、Nix sandbox には
  # /usr が無いため、その環境でのみ当該テストを除外する。/etc 自体の
  # 保護テストを含む残りのテストはすべて実行する。
  preCheck = ''
    if [[ ! -d /usr ]]; then
      checkFlags+=(--skip protected_paths_are_reported_in_their_resolved_form)
    fi
  '';

  # make install は DESTDIR が無いと $HOME/.config にもメニューを書くため、
  # 書き込み先をビルド用の一時領域へ向ける。テーマのネットワーク取得は
  # UPDATE_THEMES を設定しない限り実行されない。
  installPhase = ''
    runHook preInstall
    HOME="$TMPDIR/home" make install PREFIX="$out"
    runHook postInstall
  '';

  # 動画・画像・アーカイブのプレビューが使う外部コマンドを提供する。
  # $out/share も XDG_DATA_DIRS に足し、同梱テーマを発見できるようにする。
  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ffmpeg icoutils imagemagick p7zip]}
      --prefix XDG_DATA_DIRS : "$out/share"
    )
  '';

  meta = {
    description = "Keyboard-first GTK4/Libadwaita file manager";
    homepage = "https://github.com/killown/flux";
    license = lib.licenses.gpl3Only;
    mainProgram = "flux-fm";
    platforms = lib.platforms.linux;
  };
}

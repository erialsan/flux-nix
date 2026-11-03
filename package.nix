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
  shared-mime-info,
  xorg,
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

  # widgets::components::test_lock_icon_binding など一部のテストは GTK の
  # 初期化（ディスプレイ接続）を必要とする。Nix sandbox / CI にはディスプレイが
  # 無いため、仮想ディスプレイ Xvfb を立ててからテストを実行する。
  nativeCheckInputs = [
    xorg.xvfb
    shared-mime-info
  ];

  preCheck = ''
    Xvfb :99 -screen 0 1024x768x24 &
    for i in $(seq 1 50); do
      [[ -S /tmp/.X11-unix/X99 ]] && break
      sleep 0.1
    done
    export DISPLAY=:99

    # gio の content_type_guess が MIME データベースを見つけられるようにする。
    export XDG_DATA_DIRS=''${shared-mime-info}/share:''${XDG_DATA_DIRS:-}

    # 上流の保護パステストは /usr/../etc/ の正規化も試すが、Nix sandbox には
    # /usr が無いため、その環境でのみ当該テストを除外する。/etc 自体の
    # 保護テストを含む残りのテストはすべて実行する。
    if [[ ! -d /usr ]]; then
      checkFlags+=(--skip protected_paths_are_reported_in_their_resolved_form)
    fi

    # test_get_system_mounts_structure は /media や /run/media 配下のマウントを
    # 前提とするが、Nix sandbox にはマウントポイントが無いため常に失敗する。
    checkFlags+=(--skip test_get_system_mounts_structure)

    # test_hwga_bind_icon_lookup_count_matches_disk_entries は hwga の hit! プローブ
    # のカウントを検証するが、hit! は debug_assertions 時のみ有効で、Nix の
    # buildRustPackage は --release でテストを実行するため、カウントは常に 0 に
    # なり失敗する。環境とは無関係に成立しないため、常に除外する。
    checkFlags+=(--skip test_hwga_bind_icon_lookup_count_matches_disk_entries)
  '';

  # make install は DESTDIR が無いと $HOME/.config にもメニューを書くため、
  # 書き込み先をビルド用の一時領域へ向ける。テーマのネットワーク取得は
  # UPDATE_THEMES を設定しない限り実行されない。
  # BIN_PATH を明示するのは、cargoBuildHook が --target を付けるとバイナリが
  # target/<triple>/release/ に出力され、Makefile のガードが
  # target/release/ しか探さず失敗するため。
  installPhase = ''
    runHook preInstall
    bin=$(find target -maxdepth 3 -type f -name flux-fm | head -n1)
    HOME="$TMPDIR/home" make install PREFIX="$out" BIN_PATH="$bin"
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

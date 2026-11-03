# flux-filemanager-flake

[killown/flux](https://github.com/killown/flux)（GTK4/Libadwaita 製ファイルマネージャ）の独立した Nix flake です。上流の flake や nixpkgs のパッケージが見つからなかったため作成しました。

## 実行・ビルド

```console
nix run .
nix build .#flux-filemanager
```

バイナリ名は `flux-fm` です。

## 他の flake / NUR からの利用

公開リポジトリへ移した後は、次の出力を利用できます。

- `packages.<system>.default`
- `packages.<system>.flux-filemanager`
- `overlays.default`（`pkgs.flux-filemanager` を追加）
- `package.nix`（`src` を渡せる通常の `callPackage` 用パッケージ）
- `default.nix`（NUR が要求する非 flake 用のパッケージセット）

対象システムは `x86_64-linux` と `aarch64-linux` です。`flake.lock` で上流ソースと nixpkgs を固定しています。非 flake 用の `default.nix` も同じ lock からソースの revision とハッシュを読むため、更新先が二重にはなりません。

NUR 用の評価は次で確認できます。

```console
nix-build --arg pkgs 'import <nixpkgs> {}' -A flux-filemanager
```
# flux-nix

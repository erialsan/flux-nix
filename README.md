# flux-filemanager-flake

[killown/flux](https://github.com/killown/flux)（GTK4/Libadwaita 製ファイルマネージャ）の独立した Nix flake です。上流の flake や nixpkgs のパッケージが見つからなかったため作成しました。

## 実行・ビルド

```console
nix run .
nix build .#flux-filemanager
```

バイナリ名は `flux-fm` です。

## バイナリキャッシュ

[erialsan.cachix.org](https://app.cachix.org/cache/erialsan) にビルド済みバイナリを公開しています。`flake.nix` の `nixConfig` に substituter と公開鍵が宣言されているため、flake の信頼設定を有効にしていれば `nix build` / `nix run` 時に自動でキャッシュから取得され、ソースビルドは不要です。

明示的に拒否してソースビルドしたい場合は:

```console
nix build --no-use-substituters .
```

信頼していない flake からの `nixConfig` はデフォルトでは無視されるため、キャッシュを使わない挙動は設定次第です（`accept-flake-config = true` 相当、または該当ユーザーを trusted にしている場合に有効になります）。

## 他の flake / NUR からの利用

公開リポジトリへ移した後は、次の出力を利用できます。

- `packages.<system>.default`
- `packages.<system>.flux-filemanager`
- `overlays.default`（`pkgs.flux-filemanager` を追加）
- `package.nix`（`src` を渡せる通常の `callPackage` 用パッケージ）
- `default.nix`（NUR が要求する非 flake 用のパッケージセット）

対象システムは `x86_64-linux`です。`flake.lock` で上流ソースと nixpkgs を固定しています。非 flake 用の `default.nix` も同じ lock からソースの revision とハッシュを読むため、更新先が二重にはなりません。

NUR 用の評価は次で確認できます。

```console
nix-build --arg pkgs 'import <nixpkgs> {}' -A flux-filemanager
```
# flux-nix

# SuperDirt インストールガイド

SuperDirtはTidalCyclesの音を出力するためのSuperCollider拡張です。

## 前提条件
- SuperColliderがインストールされていること
- macOSの場合：[SuperCollider.app](https://supercollider.github.io/download)をダウンロード

## インストール方法

### 方法1: SuperCollider内でインストール（推奨）

1. SuperColliderを起動
2. 以下のコードを実行（Cmd+Enterで実行）:

```supercollider
// Quarksをインストール（パッケージマネージャー）
Quarks.checkForUpdates({Quarks.install("SuperDirt", "v1.7.3"); thisProcess.recompile()})
```

3. SuperColliderが再起動したら、インストール完了

### 方法2: 手動インストール

1. SuperColliderで以下を実行:
```supercollider
// Quarks GUIを開く
Quarks.gui
```

2. リストから"SuperDirt"を探して、インストールボタンをクリック

### 方法3: Gitから直接インストール

```supercollider
Quarks.install("https://github.com/musikinformatik/SuperDirt.git");
```

## インストール確認

SuperColliderで以下を実行：

```supercollider
// SuperDirtを起動
SuperDirt.start
```

成功すると以下のようなメッセージが表示されます：
```
SuperDirt: listening on port 57120
```

## トラブルシューティング

### エラー: "Class not found: SuperDirt"
- SuperColliderを再起動
- `Language > Recompile Class Library`を実行

### エラー: "Could not bind to requested port"
- 別のプロセスがポート57120を使用している
- SuperColliderを再起動するか、別のポートを指定：
```supercollider
~dirt = SuperDirt(2, s);
~dirt.start(57121); // 別のポート
```

### サンプルが見つからない
デフォルトサンプルをダウンロード：
```bash
cd ~/Library/Application\ Support/SuperCollider/downloaded-quarks/Dirt-Samples/
git clone https://github.com/musikinformatik/Dirt-Samples.git .
```

## 使い方

1. SuperColliderでSuperDirtを起動：
```supercollider
SuperDirt.start
```

2. TidalCyclesを起動（別ウィンドウ）
3. 音が鳴るはずです！

## 便利な設定

SuperColliderの起動時に自動でSuperDirtを開始：

1. `File > Open startup file`を選択
2. 以下を追加：

```supercollider
s.waitForBoot {
    ~dirt = SuperDirt(2, s);
    ~dirt.start(57120);
}
```
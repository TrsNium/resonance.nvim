# トラブルシューティング

## SuperDirtサンプルエラー

### エラーメッセージ
```
WARNING: SuperDirt: event falls out of existing orbits, index (1)
no synth or sample named 'hh' could be found.
module 'sound': instrument not found: hh
```

### 原因
SuperDirtのデフォルトサンプルがインストールされていない、または正しくロードされていません。

### 解決方法

#### 方法1: Dirt-Samplesをインストール

1. SuperColliderで以下を実行：
```supercollider
Quarks.install("https://github.com/musikinformatik/Dirt-Samples.git");
```

2. SuperColliderを再起動

3. SuperDirtを再起動：
```supercollider
// 一度停止
~dirt.stop;

// 再起動
~dirt = SuperDirt(2, s);
~dirt.loadSoundFiles;
~dirt.start(57120, 0 ! 12);  // 12個のorbitを作成
```

#### 方法2: 手動でサンプルをダウンロード

1. ターミナルで実行：
```bash
cd ~/Library/Application\ Support/SuperCollider/downloaded-quarks/
git clone https://github.com/musikinformatik/Dirt-Samples.git
```

2. SuperColliderで：
```supercollider
// サンプルのパスを指定して読み込み
~dirt.loadSoundFiles("~/Library/Application Support/SuperCollider/downloaded-quarks/Dirt-Samples/*");
```

#### 方法3: カスタムサンプルディレクトリを追加

```supercollider
// 起動時の設定
s.waitForBoot {
    ~dirt = SuperDirt(2, s);
    
    // デフォルトサンプルを読み込み
    ~dirt.loadSoundFiles;
    
    // カスタムサンプルも追加
    ~dirt.loadSoundFiles("/path/to/your/samples/*");
    
    // 12個のorbitで起動（デフォルトは2個）
    ~dirt.start(57120, 0 ! 12);
    
    // 読み込まれたサンプルを確認
    ~dirt.postSampleInfo;
};
```

### orbit数の問題

エラー「event falls out of existing orbits」は、使用しようとしているorbit番号が存在しないことを示します。

```supercollider
// 12個のorbitで起動（d1〜d12まで使用可能）
~dirt.start(57120, 0 ! 12);

// または16個
~dirt.start(57120, 0 ! 16);
```

### サンプルの確認

読み込まれているサンプルを確認：
```supercollider
// すべてのサンプルをリスト
~dirt.postSampleInfo;

// 特定のサンプルを検索
~dirt.buffers.keys.select({|x| x.asString.contains("bd")}).postln;
```

### よく使われるサンプル名

| サンプル | 説明 |
|---------|------|
| bd | バスドラム |
| sn | スネア |
| hh | ハイハット |
| cp | クラップ |
| arpy | アルペジオ |
| bass | ベース |
| feel | フィール |
| future | フューチャー |

これらが使えない場合は、Dirt-Samplesのインストールが必要です。
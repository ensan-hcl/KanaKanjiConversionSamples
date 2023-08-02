# KanaKanjiConversionSamples

Viterbiアルゴリズムによるかな漢字変換のシンプルな実装です。

```swift
var converter = KanaKanjiConversionSimpleImplementation()
XCTAssertEqual(converter.convertToKanji(kana: Array("かんじ")), "感じ")
XCTAssertEqual(converter.convertToKanji(kana: Array("へんかんけっか")), "変換結果")
XCTAssertEqual(converter.convertToKanji(kana: Array("これはあいふぉんです")), "これはiPhoneです")
XCTAssertEqual(converter.convertToKanji(kana: Array("あずーきーはかなかんじへんかんえんじんです")), "azooKeyはかな漢字変換エンジンです")
```

## 実用化のヒント

* 現在の実装はたった1つの最適解しか計算できませんが、実際の変換エンジンは複数候補を提案します。上位n個の最適解（N-best解）を計算できるようにアルゴリズムを改造してみましょう
* 現在の実装はtsvの辞書データを読み込んでfilterをかけていますが、この方法による辞書検索は重すぎます。LOUDSという形式を用いたTrieを作って検索を高速化してみましょう
* 実際の変換の際には「1文字ずつ」入力が増えていきます。そこで差分を利用して効率的に変換候補を計算できるようにアルゴリズムを改造してみましょう
* 現在の実装では品詞を単語に対して1つ定めましたが、複合語などを扱う際は「左右で異なる品詞」を扱えると便利です。そのように改造してみましょう
* 実際の変換では「予測変換」や「文節のみ変換」などの機能があると便利です。実装してみましょう

## 関連レポジトリ

上記実用化のための実装を実施済みのSwift Packageがあります。[AzooKeyKanaKanjiConverter](https://github.com/ensan-hcl/AzooKeyKanaKanjiConverter)をお試しください。

## ライセンス
azooKey Version 2.1.1の辞書データを利用しています。辞書データのライセンスはApache 2.0です。

ソースコードはMIT Licenseです。

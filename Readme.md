# これはなにか

Markdownから、PDFやEPUBを生成するためのフレームワークのプロトタイプです。

Vagrantなどのように、Ruby DSLによって1ファイルで生成のためのルールを設定できるようにし、
PDFやEPUBの生成を自動化します。

このプロトタイプの目的は

* 多様化する出力フォーマットを１ソースで生成できるようにする場合のシンプルで、柔軟な定義方法の検証

です。

# インストール

※動作確認はMacでしています。それ以外の環境については把握していません。

このツールを使うために必要なもの

## Ruby 2.1.x

RVMなどでインストールしてください。

https://rvm.io/

## Tex Live

acTex.pkgをダウンロードしてインストール

http://tug.org/mactex/

参考) http://tandoori.hatenablog.com/entry/20130802/1375451791

Tex Live Utility.appを起動して、アップデート

```
Yosemiteを使う場合は、まずTex Live Utilityを更新すること、メニューの「Tex Liveユーティリティ > 更新があるか確認」で更新すること。
そうしないとうまくTexをアップデートできない
```

または

```
$ sudo tlmgr update --self --all
```

でもよいかも。

インストールディレクトリは

* 基本インストール
/usr/local/texlive/2014
* TEXMFLOCAL
/usr/local/texlive/texmf-local
* TEXMFHOME
~/Library/texmf

になるらしい。

```
$ kpsewhich -var-value TEXMF
```
で検索の優先順位がわかるらしい。

## pandoc 1.13.2

brew等でインストールしてください。

```
$ brew install pandoc
```

## このツールの取得

```
$ git clone git@github.com:Amakata/ebc.git
```

## コマンドのパスを通す

クローンしたbin/ebcにパスを通すか、直接パスを指定してebcを実行してください。

# 使い方

## 初期化

```
$ mkdir project
$ cd project
$ ebc init
```

上記コマンドを実行することで、Ebcファイル、サンプルデータ、デフォルトテーマや各種からディレクトリをスケルトンを元に作成します。

## ビルド

```
$ ebc build
```

カレントディレクトリのEbc設定ファイルを元にビルドします。

```
$ ebc book --book=sample
```

Ebc設定ファイルのbook sampleのみビルドします。

```
$ ebc book -v
```

コマンドラインの実行結果を結果にかかわらず詳細に出力します。

```
$ ebc book --pandoc-json-output 
```

pandocのjsonオブジェクトをtmpフォルダに生成します。デバック用です。


## クリア

```
$ ebc clean
```

カレントディレクトリのtmpディレクトリ、outputディレクトリをクリアします。



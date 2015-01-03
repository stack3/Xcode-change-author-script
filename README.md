Xcode-change-author-script
==========================

* XcodeはデフォルトでソースファイルのAuthorをアカウントにひもづいた名前を入れます。
* 場合によっては変更したい場合があると思います。
* このスクリプトはAuthorを任意のものに変更します。

使い方
---

設定ファイルを用意します。

change-author.config
```
{
   "src_author" : "Taro Yamada",
   "dst_author" : "Yama1965"
}
```

ディレクトリを指定してスクリプトを実行します

```change-author.rb %ディレクトリ%```

指定したディレクトリから再帰的に

```// Created by {src_author} on```

で始まる行を

```// Created by {dst_author} on```

に置換します。

指定したディレクトリに

* change-author.timestamp

というファイルができます。次回のスクリプト実行時にソースファイルの更新日時が新しいもののみをAuthor変更対象とするためのものです。Gitで管理している場合は.gitignoreに追加しておいてください。

Xcodeでコンパイル前に自動実行するようにする
---

* Build PhasesにRun Scriptを追加し、Shellを以下のようにする
   * ~/scriptsにchange-author.rbを配置した場合
   
```
#!/bin/sh
if [ -e ~/scripts/change-author.rb ]; then
/bin/ruby ~/scripts/change-author.rb "${SOURCE_ROOT}"
fi
```



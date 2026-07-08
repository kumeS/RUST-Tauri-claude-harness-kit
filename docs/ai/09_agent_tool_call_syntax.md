# 09. エージェントのツール呼び出し書式（再発防止メモ）

> Scope note: this file is *agent self-notes* — incident-derived reminders
> for AI sessions working in this repository. Optional for adopting
> projects: copy it if your sessions hit the same failure shapes, replace
> its incident log with your own, or skip it. It documents session
> mechanics, not product architecture.

このファイルは、AIエージェント（Claude）がこのプロジェクトで作業する際に
実際にやらかしたツール呼び出しの書式ミスを記録し、再発を防ぐためのもの。
プロジェクトのアーキテクチャではなく、エージェント自身への注意書き。

## 何が起きたか（2026-07-05）

`AskUserQuestion` / `Edit` / `Write` の呼び出しで、正しい関数呼び出しブロックを
使わず、壊れた書式を繰り返し出力してツールが "malformed and could not be
parsed" で失敗した。具体的な誤り：

- 呼び出しタグの直前に不要な文字列（例：`court`）を付けてしまった。
- 名前空間 `antml:` を落として、裸の `<invoke>` / `<parameter>` を書いた。

いずれも「ただのテキスト出力」として扱われ、ツールは一切実行されない。同じ
セッション内で正しく実行できていたのに、油断すると再発した。

## 正しい書式（唯一これ）

ツール呼び出しは必ず、名前空間付きタグの function-calls ブロックで行う。
- 各呼び出しは名前空間付きの invoke タグ（`name` 属性にツール名）。
- 各引数は名前空間付きの parameter タグ（`name` 属性に引数名）。
- ブロックの前後に "court" 等の余計な文字列を絶対に付けない。
- 名前空間の接頭辞を絶対に落とさない。

## チェックリスト（ツールを呼ぶ直前に自問）

1. 呼び出しは正しい function-calls ブロックの中にあるか？
2. invoke と parameter に名前空間の接頭辞が付いているか？
3. ブロックの直前に本文テキスト（"court" 等）が混ざっていないか？
4. JSON 引数（AskUserQuestion の questions 等）は、そのパラメータ値として
   正しく 1 つの JSON になっているか？

## 参考：Workflow 台本で踏んだ別種の落とし穴

Workflow の JS 台本でも同系統の「書式で失敗」を過去に起こした。台本を書いたら
node --check 相当で構文検証してから起動すること：
- テンプレートリテラル内で、説明のつもりのインライン・バッククォート囲みを
  使うと、テンプレートリテラルの区切りと衝突して構文エラーになる。囲まず平文で書く。
- 文字列中のアポストロフィを二重エスケープすると、バックスラッシュがリテラル化して
  引用符が文字列を閉じてしまう。アポストロフィを避けるか、正しく 1 回だけ処理する。

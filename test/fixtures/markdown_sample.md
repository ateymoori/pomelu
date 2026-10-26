# Rendering sample

Every construct the chat renderer special-cases, in one reply. Used by
`test/features/chat/markdown_render_test.dart`; also handy for eyeballing the
transcript against a live gateway.

Regular prose with **bold**, *italic*, `inline code` and an
[inline link](https://example.com/inline) that must stay inline, not become a
card.

## Task list

- [x] Ship syntax highlighting
- [ ] Ship dark-mode screenshots
- [X] Uppercase X also counts
* [ ] Asterisk bullets too
1. [x] And ordered items

## Fenced code

```dart
// Keywords, strings, numbers and comments each get their own token colour.
void main() {
  const greeting = 'سلام';
  print('$greeting ${1 + 41}');
}
```

```
No info string: this block stays plain mono text.
```

```notalanguage
- [ ] a task inside a fence is source, not a checkbox
```

## Disclosure

<details>
<summary>Why the gateway is LAN-only</summary>

Body Markdown still renders: **bold**, a list,

- one
- two

and even a nested fence:

```json
{"ok": true}
```

</details>

<details open>
<summary>Already expanded</summary>

Starts open because the author wrote `<details open>`.

</details>

## Links on their own line

https://www.youtube.com/watch?v=dQw4w9WgXcQ

https://youtu.be/dQw4w9WgXcQ

[Flutter docs](https://docs.flutter.dev/perf/rendering-performance)

https://nousresearch.com/

## Images

![A remote picture](https://example.com/pictures/fold.png)

## Table, quote, rule

| Construct | Handled by |
| --- | --- |
| Code | `CodeHighlight` |
| Tasks | `MarkdownSegments.normalizeTaskLists` |

> A block quote, for good measure.

---

## RTL

این یک پاراگراف فارسی است که باید راست‌چین رندر شود، اما بلوک کد زیر همچنان
چپ‌چین می‌ماند:

```bash
echo "left to right, always"
```

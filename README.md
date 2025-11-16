# ez_grid_view

A defensive, self-aware version of `GridView.builder` that won't crash when placed in an unbounded-height parent.

## Problem

Flutter's `GridView` is a powerful and efficient way to display scrollable lists of data. However, it has a major weakness: it requires its parent to provide bounded (finite) height. If you place a `GridView` inside a `Column` or `Row`, you'll get a layout crash with a cryptic error message.

This is a common frustration for Flutter developers, especially newcomers. The fix is to wrap the `GridView` in a widget that provides bounded height, such as `Expanded` or `SizedBox`.

## Solution

`EzGridView` is a drop-in replacement for `GridView.builder` that automatically handles this problem. It detects when it's in an unbounded-height environment and applies a fix to prevent the crash.

In debug mode, it also provides a detailed error message in the console and a visual indicator (a red border) to let you know that a fix was applied. This helps you identify and fix the underlying layout issue.

## Features

-   **Crash protection:** Automatically prevents layout crashes from unbounded height.
-   **Debug-friendly:** Provides detailed error messages and visual indicators in debug mode.
-   **Drop-in replacement:** Use it just like you would use `GridView.builder`.
-   **Lightweight:** No external dependencies.

## Usage

Replace `GridView.builder` with `EzGridView.builder`:

```dart
// Before
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
  ),
  itemCount: 100,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
);

// After
EzGridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
  ),
  itemCount: 100,
  itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
);
```

For a complete example, see the `example` directory.

## Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request.

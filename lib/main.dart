import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            colors: [
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.purple,
              Colors.red,
            ],
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.colors,
  });

  /// Initial icon items to put in this [Dock].
  final List<IconData> items;

  /// Colors assigned to each icon in the dock.
  final List<Color> colors;

  @override
  State<Dock> createState() => _DockState();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState extends State<Dock> with SingleTickerProviderStateMixin {
  late List<IconData> _items;
  late List<Color> _colors;

  int? draggedIndex;
  int? targetIndex;
  bool isOutsideRow = false;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
    _colors = widget.colors.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length + 1, (index) {
          // If it's the last index, it's the placeholder target for the last item.
          if (index == _items.length) {
            return DragTarget<IconData>(
              onWillAcceptWithDetails: (data) {
                setState(() {
                  targetIndex = _items.length;
                });
                return true;
              },
              onAcceptWithDetails: (data) {
                setState(() {
                  if (draggedIndex != null) {
                    final draggedItem = _items.removeAt(draggedIndex!);
                    final draggedColor = _colors.removeAt(draggedIndex!);

                    _items.add(draggedItem);
                    _colors.add(draggedColor);
                  }

                  draggedIndex = null;
                  targetIndex = null;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Container(
                    width: targetIndex == index ? 48 : 0,
                    height: targetIndex == index ? 48 : 0,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.transparent,
                    ),
                  ),
                );
              },
            );
          } else {
            return DragTarget<IconData>(
              onWillAcceptWithDetails: (data) {
                setState(() {
                  targetIndex = index;
                });
                return true;
              },
              onAcceptWithDetails: (data) {
                setState(() {
                  if (draggedIndex != null && targetIndex != null) {
                    final draggedItem = _items.removeAt(draggedIndex!);
                    final draggedColor = _colors.removeAt(draggedIndex!);

                    final adjustedIndex = targetIndex! > draggedIndex!
                        ? targetIndex! - 1
                        : targetIndex!;

                    _items.insert(adjustedIndex, draggedItem);
                    _colors.insert(adjustedIndex, draggedColor);
                  }

                  draggedIndex = null;
                  targetIndex = null;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Container(
                        width: index == targetIndex && !isOutsideRow ? 48 : 0,
                        height: index == targetIndex && !isOutsideRow ? 48 : 0,
                        margin: EdgeInsets.all(
                            index == targetIndex && !isOutsideRow ? 8 : 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                    Draggable<IconData>(
                      data: _items[index],
                      onDragStarted: () {
                        setState(() {
                          draggedIndex = index;
                        });
                      },
                      onDraggableCanceled: (_, __) {
                        setState(() {
                          draggedIndex = null;
                          targetIndex = null;
                        });
                      },
                      onDragUpdate: (details) {
                        if (170 > details.localPosition.dy ||
                            details.localPosition.dy > 270) {
                          setState(() {
                            isOutsideRow = true;
                          });
                        } else {
                          setState(() {
                            isOutsideRow = false;
                          });
                        }
                      },
                      onDragCompleted: () {
                        setState(() {
                          draggedIndex = null;
                          targetIndex = null;
                        });
                      },
                      feedback: Container(
                        constraints: const BoxConstraints(minWidth: 48),
                        height: 48,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: _colors[index],
                        ),
                        child: Center(
                            child: Icon(_items[index], color: Colors.white)),
                      ),
                      childWhenDragging: const SizedBox(),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 48),
                        height: 48,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: _colors[index],
                        ),
                        child: Center(
                            child: Icon(_items[index], color: Colors.white)),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        }),
      ),
    );
  }
}

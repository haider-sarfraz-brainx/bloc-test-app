import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomSelectableText extends StatelessWidget {
  const CustomSelectableText({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SelectionArea(
            contextMenuBuilder: (context, selectableRegionState) {
              // Build your own context menu with the system anchors
              return AdaptiveTextSelectionToolbar(
                anchors: selectableRegionState.contextMenuAnchors,
                children: [
                  TextButton(
                    onPressed: () {
                      final items =
                          selectableRegionState.contextMenuButtonItems;
                      final copyItem = items.firstWhere(
                            (item) =>
                        item.type == ContextMenuButtonType.copy &&
                            item.onPressed != null,
                        orElse: () => ContextMenuButtonItem(
                            type: ContextMenuButtonType.custom, onPressed: () {  }),
                      );
                      if (copyItem.onPressed != null) {
                        copyItem.onPressed!();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                          ),
                        );
                      }
                      ContextMenuController.removeAny();
                    },
                    child: const Text('Copy'),
                  ),
                  TextButton(
                    onPressed: () {
                      final items =
                          selectableRegionState.contextMenuButtonItems;
                      final selectAllItem = items.firstWhere(
                            (item) =>
                        item.type == ContextMenuButtonType.selectAll &&
                            item.onPressed != null,
                        orElse: () => ContextMenuButtonItem(
                            type: ContextMenuButtonType.custom, onPressed: () {  }),
                      );
                      selectAllItem.onPressed?.call();
                    },
                    child: const Text('Select All'),
                  ),
                ],
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Select text from here.'),
                  Text('Then use the menu to copy.'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

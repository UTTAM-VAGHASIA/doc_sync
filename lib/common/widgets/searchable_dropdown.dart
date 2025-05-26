import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:doc_sync/utils/constants/colors.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final String hint;
  final List<T> items;
  final T? value;
  final Function(T?) onChanged;
  final Widget? prefixIcon;
  final bool isLoading;
  final String Function(T) getLabel;
  final bool enabled;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.getLabel,
    this.prefixIcon,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dropdownSearchController =
      TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  String _searchQuery = '';
  bool _preventImmediateClose = false;
  bool _isClickHandled = false;
  // Store the current position of the dropdown overlay
  Offset _currentOverlayPosition = Offset.zero;
  Size _currentOverlaySize = Size.zero;

  // Added keyboard visibility tracking
  double _keyboardHeight = 0.0;

  // Create a GlobalKey for the overlay to ensure consistent rebuilding
  final GlobalKey _overlayKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (widget.value != null) {
      _searchController.text = widget.getLabel(widget.value as T);
    }

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.enabled) {
        _openDropdown();
      }
    });

    // Listen for search text changes to update clear button visibility
    _dropdownSearchController.addListener(_onSearchChange);
  }

  void _onSearchChange() {
    if (_overlayEntry != null) {
      // Force rebuild of overlay to show/hide clear button
      _overlayEntry!.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    _closeDropdown();
    _focusNode.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    _dropdownSearchController.removeListener(_onSearchChange);
    _dropdownSearchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update the text field when the value changes externally
    if (widget.value != oldWidget.value) {
      _searchController.text =
          widget.value != null ? widget.getLabel(widget.value as T) : '';
    }
  }

  void _openDropdown() {
    if (_overlayEntry != null || !widget.enabled) return;

    _searchQuery = '';
    _dropdownSearchController.text = '';
    _isOpen = true;
    _preventImmediateClose = true;
    _isClickHandled = false;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);

    // Add event listener to close dropdown when tapping outside
    _addGlobalTapListener();

    // Update UI to show the correct arrow icon
    setState(() {});

    // Reset the flag after a short delay to allow the dropdown to open
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _preventImmediateClose = false;
      }
    });
  }

  void _closeDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isOpen = false;
      // Remove global tap listener
      _removeGlobalTapListener();

      // Update UI to show the correct arrow icon
      setState(() {});
    }
  }

  // Global tap listener to close dropdown when tapping outside
  void _addGlobalTapListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GestureBinding.instance.pointerRouter.addGlobalRoute(_handleGlobalTap);
    });
  }

  void _removeGlobalTapListener() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_handleGlobalTap);
  }

  void _handleGlobalTap(PointerEvent event) {
    // Skip if not a tap down event or if we're preventing immediate close
    if (event is! PointerDownEvent || _preventImmediateClose) return;

    // If click is already handled by a child widget, ignore
    if (_isClickHandled) {
      _isClickHandled = false;
      return;
    }

    // Get dropdown field position
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final fieldSize = renderBox.size;
    final fieldPosition = renderBox.localToGlobal(Offset.zero);

    // Check if tap is inside the field
    final tapPosition = event.position;
    bool isInField =
        tapPosition.dx >= fieldPosition.dx &&
        tapPosition.dx <= fieldPosition.dx + fieldSize.width &&
        tapPosition.dy >= fieldPosition.dy &&
        tapPosition.dy <= fieldPosition.dy + fieldSize.height;

    // Check if tap is inside the overlay
    bool isInOverlay =
        _currentOverlayPosition != Offset.zero &&
        _currentOverlaySize != Size.zero &&
        tapPosition.dx >= _currentOverlayPosition.dx &&
        tapPosition.dx <=
            _currentOverlayPosition.dx + _currentOverlaySize.width &&
        tapPosition.dy >= _currentOverlayPosition.dy &&
        tapPosition.dy <=
            _currentOverlayPosition.dy + _currentOverlaySize.height;

    // If tap is outside both field and overlay, close the dropdown
    if (!isInField && !isInOverlay) {
      _closeDropdown();
      _focusNode.unfocus();
    }
  }

  // Calculate the appropriate height for the dropdown overlay
  double _calculateOverlayHeight(List<T> filteredItems) {
    // Base height for the search box + padding
    const double searchBoxHeight = 60.0;
    // Height for divider
    const double dividerHeight = 5.0;
    // Height per item in the list
    const double itemHeight = 45.0;
    // Maximum height the overlay can be
    const double maxHeight = 300.0;
    // No results message height
    const double noResultsHeight = 52.0;

    double contentHeight;

    if (filteredItems.isEmpty) {
      // Just enough for search box and no results message
      contentHeight = searchBoxHeight + dividerHeight + noResultsHeight;
    } else {
      // Search box + divider + items (limited by the number of items)
      contentHeight =
          searchBoxHeight +
          dividerHeight +
          (itemHeight * filteredItems.length.toDouble());
    }

    // Ensure we don't exceed the maximum height
    return contentHeight.clamp(0.0, maxHeight);
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
      _focusNode.unfocus();
    } else {
      if (!_focusNode.hasFocus) {
        _focusNode.requestFocus();
      }
    }
  }

  void _selectItem(T item) {
    // Mark that we've handled this click to prevent the global tap handler from processing it
    _isClickHandled = true;
    widget.onChanged(item);
    _searchController.text = widget.getLabel(item);

    // Use a short delay to ensure the click is fully processed first
    Future.microtask(() {
      _closeDropdown();
      _focusNode.unfocus();
    });
  }

  void _clearSearch() {
    _dropdownSearchController.clear();
    _searchQuery = '';
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
    // Keep focus on search field after clearing
    _searchFocusNode.requestFocus();
  }

  List<T> _getFilteredItems() {
    if (_searchQuery.isEmpty) return widget.items;

    return widget.items
        .where(
          (item) => widget
              .getLabel(item)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  // Calculate the vertical offset for the dropdown based on available space
  Offset _calculateVerticalOffset(
    Size size,
    Offset fieldPosition,
    double contentHeight,
    double keyboardHeight,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSpace =
        screenHeight - fieldPosition.dy - size.height - keyboardHeight;

    // Check if there's enough space at the top if we need to show above
    final topSpace = fieldPosition.dy;

    // First determine if we should show below or above based on available space
    // If keyboard is visible and taking significant space, prefer showing above
    bool showBelow =
        keyboardHeight > 100
            ? false
            : bottomSpace >= contentHeight || bottomSpace > topSpace;

    // Now check if we have enough space when showing above
    if (!showBelow) {
      // If there's not enough space above, prioritize keeping the search field visible
      if (topSpace < contentHeight) {
        // Try to keep it below if there's more space below than above
        if (bottomSpace > topSpace) {
          showBelow = true;
        }
        // Otherwise, we'll keep it above but adjust the position to ensure search field is visible
      }
    }

    return showBelow ? Offset(0, size.height) : Offset(0, -contentHeight);
  }

  // Update the overlay position when keyboard visibility changes
  void _updateDropdownPosition() {
    if (_overlayEntry == null || !mounted) return;

    // Force rebuild of the overlay to update its position
    _overlayEntry!.markNeedsBuild();
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        // Get current keyboard height
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

        // Track keyboard visibility changes to update positioning
        if (_keyboardHeight != keyboardHeight) {
          // Update stored keyboard height
          _keyboardHeight = keyboardHeight;

          // Schedule a position update after this frame completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateDropdownPosition();
          });
        }

        // Get filtered items for height calculation
        final filteredItems = _getFilteredItems();

        // Calculate actual content height based on items
        final double contentHeight = _calculateOverlayHeight(filteredItems);

        // Calculate the vertical offset based on current conditions
        final verticalOffset = _calculateVerticalOffset(
          size,
          offset,
          contentHeight,
          keyboardHeight,
        );

        // Check if dropdown would go beyond top of screen
        bool exceedsTopBoundary =
            offset.dy < contentHeight && verticalOffset.dy < 0;

        // Adjust the vertical offset if needed to prevent going beyond top boundary
        final adjustedVerticalOffset =
            exceedsTopBoundary
                ? Offset(
                  verticalOffset.dx,
                  -offset.dy,
                ) // Only go up as far as the top edge allows
                : verticalOffset;

        // Calculate the adjusted height if we can't show the full dropdown
        final adjustedHeight =
            exceedsTopBoundary
                ? offset
                    .dy // Use the available space above
                : contentHeight;

        // Store the current overlay position for hit testing
        _currentOverlayPosition = Offset(
          offset.dx,
          verticalOffset.dy >= 0
              ? offset.dy +
                  size
                      .height // Below field
              : offset.dy - contentHeight, // Above field
        );

        _currentOverlaySize = Size(
          size.width,
          exceedsTopBoundary ? adjustedHeight : contentHeight,
        );

        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: adjustedVerticalOffset,
            child: Material(
              key: _overlayKey,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    final filteredItems = _getFilteredItems();

                    // Recalculate height based on current filtered items and screen constraints
                    double actualHeight = _calculateOverlayHeight(
                      filteredItems,
                    );

                    // If we're showing above and would exceed the top boundary, limit the height
                    if (exceedsTopBoundary) {
                      actualHeight = (offset.dy - 16).clamp(
                        0.0,
                        actualHeight,
                      ); // 16px buffer for padding
                    }

                    // Update overlay size for hit testing
                    _currentOverlaySize = Size(size.width, actualHeight);

                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: actualHeight,
                        minWidth: size.width,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Always show search box at top, especially when space is limited
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 4.0,
                            ),
                            child: TextField(
                              controller: _dropdownSearchController,
                              focusNode: _searchFocusNode,
                              onTapOutside: (event) {
                                // Don't unfocus automatically when tapped outside
                              },
                              autofocus: true,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Search...',
                                prefixIcon: const Icon(Icons.search, size: 20),
                                // Add clear button when there is text
                                suffixIcon:
                                    _dropdownSearchController.text.isNotEmpty
                                        ? IconButton(
                                          icon: const Icon(
                                            Icons.clear,
                                            size: 18,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          splashRadius: 16,
                                          onPressed: _clearSearch,
                                        )
                                        : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() => _searchQuery = value);
                              },
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Divider(height: 1),
                          if (filteredItems.isNotEmpty)
                            Flexible(
                              child: ListView.builder(
                                physics: const ClampingScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];
                                  final isSelected = widget.value == item;

                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      _selectItem(item);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      color:
                                          isSelected
                                              ? AppColors.light
                                              : Colors.transparent,
                                      child: Text(
                                        widget.getLabel(item),
                                        style: TextStyle(
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          color:
                                              isSelected
                                                  ? AppColors.primary
                                                  : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'No items found',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _searchController,
        focusNode: _focusNode,
        readOnly: true,
        enabled: widget.enabled,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: const TextStyle(
            fontSize: 18, // Make label text bigger
            fontWeight: FontWeight.w500,
          ),
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon,
          suffixIcon:
              widget.isLoading
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                  : IconButton(
                    icon: Icon(
                      _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: widget.enabled ? _toggleDropdown : null,
                  ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          filled: !widget.enabled,
          fillColor: !widget.enabled ? Colors.grey[100] : null,
        ),
        onTap: widget.enabled ? _toggleDropdown : null,
        onTapOutside: (event) {
          // Don't unfocus immediately when tapping outside, let the global tap handler manage this
          if (!_preventImmediateClose) {
            _focusNode.unfocus();
          }
        },
      ),
    );
  }
}

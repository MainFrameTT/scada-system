import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1440 && largeDesktop != null) {
          return largeDesktop!;
        } else if (constraints.maxWidth >= 1024 && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= 768 && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final int largeDesktopColumns;
  final List<Widget> children;
  final double spacing;

  const ResponsiveGrid({
    super.key,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.largeDesktopColumns = 4,
    required this.children,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: _getChildAspectRatio(crossAxisCount),
          children: children,
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1440) return largeDesktopColumns;
    if (width >= 1024) return desktopColumns;
    if (width >= 768) return tabletColumns;
    return mobileColumns;
  }

  double _getChildAspectRatio(int crossAxisCount) {
    switch (crossAxisCount) {
      case 1:
        return 1.6; // Mobile - taller cards
      case 2:
        return 1.3; // Tablet
      case 3:
        return 1.2; // Desktop
      case 4:
        return 1.1; // Large desktop
      default:
        return 1.2;
    }
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double mobilePadding;
  final double tabletPadding;
  final double desktopPadding;
  final double largeDesktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding = 16.0,
    this.tabletPadding = 24.0,
    this.desktopPadding = 32.0,
    this.largeDesktopPadding = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = _getPadding(constraints.maxWidth);
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: child,
        );
      },
    );
  }

  double _getPadding(double width) {
    if (width >= 1440) return largeDesktopPadding;
    if (width >= 1024) return desktopPadding;
    if (width >= 768) return tabletPadding;
    return mobilePadding;
  }
}

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const AdaptiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTheme.titleLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppTheme.darkTheme.appBarTheme.backgroundColor,
      foregroundColor: AppTheme.darkTheme.appBarTheme.foregroundColor,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: 1,
      centerTitle: !AppTheme.isMobile(context),
      actions: actions,
    );
  }
}

class ResponsiveDataTable<T> extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool sortAscending;
  final int? sortColumnIndex;
  final Function(int, bool)? onSort;
  final double? dataRowMinHeight;
  final double? dataRowMaxHeight;
  final double? headingRowHeight;
  final double? horizontalMargin;
  final double? columnSpacing;
  final bool showCheckboxColumn;
  final bool showFirstLastButtons;

  const ResponsiveDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortAscending = true,
    this.sortColumnIndex,
    this.onSort,
    this.dataRowMinHeight,
    this.dataRowMaxHeight,
    this.headingRowHeight,
    this.horizontalMargin,
    this.columnSpacing,
    this.showCheckboxColumn = false,
    this.showFirstLastButtons = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildMobileView();
        } else {
          return _buildDesktopView();
        }
      },
    );
  }

  Widget _buildDesktopView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 600),
        child: DataTable(
          columns: columns,
          rows: rows,
          sortAscending: sortAscending,
          sortColumnIndex: sortColumnIndex,
          onSelectAll: (_) {},
          dataRowMinHeight: dataRowMinHeight ?? 48.0,
          dataRowMaxHeight: dataRowMaxHeight,
          headingRowHeight: headingRowHeight ?? 56.0,
          horizontalMargin: horizontalMargin ?? 24.0,
          columnSpacing: columnSpacing ?? 56.0,
          showCheckboxColumn: showCheckboxColumn,
          dividerThickness: 1.0,
          dataTextStyle: AppTheme.bodyMedium.copyWith(color: Colors.white),
          headingTextStyle: AppTheme.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          color: AppTheme.darkTheme.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < columns.length; i++)
                  if (i < row.cells.length) _buildMobileRowItem(columns[i], row.cells[i]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileRowItem(DataColumn column, DataCell cell) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.0,
            child: Text(
              column.label.toString(),
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: DefaultTextStyle(
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
              child: cell.child ?? const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}

class ResponsiveSplitView extends StatelessWidget {
  final Widget primary;
  final Widget secondary;
  final double breakpoint;
  final double primaryMinWidth;
  final double secondaryMinWidth;
  final bool primaryFirst;

  const ResponsiveSplitView({
    super.key,
    required this.primary,
    required this.secondary,
    this.breakpoint = 768.0,
    this.primaryMinWidth = 300.0,
    this.secondaryMinWidth = 300.0,
    this.primaryFirst = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return _buildMobileLayout();
        } else {
          return _buildDesktopLayout();
        }
      },
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: primaryFirst
          ? [Expanded(child: primary), Expanded(child: secondary)]
          : [Expanded(child: secondary), Expanded(child: primary)],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: primaryFirst
          ? [
              Flexible(
                flex: 2,
                child: primary,
              ),
              Flexible(
                flex: 1,
                child: secondary,
              ),
            ]
          : [
              Flexible(
                flex: 1,
                child: secondary,
              ),
              Flexible(
                flex: 2,
                child: primary,
              ),
            ],
    );
  }
}

class ConditionalWrap extends StatelessWidget {
  final Widget child;
  final bool condition;
  final Widget Function(Widget) wrapper;

  const ConditionalWrap({
    super.key,
    required this.child,
    required this.condition,
    required this.wrapper,
  });

  @override
  Widget build(BuildContext context) {
    return condition ? wrapper(child) : child;
  }
}
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AlarmsFilterBar extends StatelessWidget {
  final String? stateFilter;
  final String? severityFilter;
  final Function(String? state, String? severity) onFilterChanged;

  const AlarmsFilterBar({
    super.key,
    required this.stateFilter,
    required this.severityFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.darkTheme.cardColor,
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.getHorizontalPadding(context),
        vertical: 16.0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStateFilter(),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildSeverityFilter(),
              ),
              const SizedBox(width: 12.0),
              _buildClearButton(),
            ],
          ),
          const SizedBox(height: 8.0),
          _buildActiveFilters(),
        ],
      ),
    );
  }

  Widget _buildStateFilter() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Статус',
        labelStyle: AppTheme.bodyMedium.copyWith(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: stateFilter,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
          style: AppTheme.bodyMedium.copyWith(color: Colors.white),
          dropdownColor: AppTheme.darkTheme.cardColor,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Все статусы'),
            ),
            const DropdownMenuItem(
              value: 'ACTIVE',
              child: Text('Активные'),
            ),
            const DropdownMenuItem(
              value: 'ACKNOWLEDGED',
              child: Text('Квитированные'),
            ),
            const DropdownMenuItem(
              value: 'RESOLVED',
              child: Text('Сброшенные'),
            ),
          ],
          onChanged: (value) {
            onFilterChanged(value, severityFilter);
          },
        ),
      ),
    );
  }

  Widget _buildSeverityFilter() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Важность',
        labelStyle: AppTheme.bodyMedium.copyWith(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: severityFilter,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
          style: AppTheme.bodyMedium.copyWith(color: Colors.white),
          dropdownColor: AppTheme.darkTheme.cardColor,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Все уровни'),
            ),
            DropdownMenuItem(
              value: 'CRITICAL',
              child: Row(
                children: [
                  Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: AppTheme.criticalColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  const Text('Критическая'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'HIGH',
              child: Row(
                children: [
                  Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  const Text('Высокая'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'MEDIUM',
              child: Row(
                children: [
                  Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  const Text('Средняя'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'LOW',
              child: Row(
                children: [
                  Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: AppTheme.normalColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  const Text('Низкая'),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            onFilterChanged(stateFilter, value);
          },
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return IconButton(
      icon: Icon(
        Icons.clear_all,
        color: (stateFilter != null || severityFilter != null)
            ? AppTheme.infoColor
            : Colors.white30,
      ),
      onPressed: (stateFilter != null || severityFilter != null)
          ? () {
              onFilterChanged(null, null);
            }
          : null,
    );
  }

  Widget _buildActiveFilters() {
    final hasActiveFilters = stateFilter != null || severityFilter != null;
    
    if (!hasActiveFilters) return const SizedBox.shrink();

    return Row(
      children: [
        Text(
          'Активные фильтры:',
          style: AppTheme.caption.copyWith(color: Colors.white54),
        ),
        const SizedBox(width: 8.0),
        if (stateFilter != null)
          _buildFilterChip(_getStateFilterText(stateFilter!)),
        if (severityFilter != null)
          _buildFilterChip(_getSeverityFilterText(severityFilter!)),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppTheme.infoColor.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: AppTheme.caption.copyWith(
          color: AppTheme.infoColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getStateFilterText(String state) {
    switch (state) {
      case 'ACTIVE':
        return 'Статус: Активные';
      case 'ACKNOWLEDGED':
        return 'Статус: Квитированные';
      case 'RESOLVED':
        return 'Статус: Сброшенные';
      default:
        return state;
    }
  }

  String _getSeverityFilterText(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return 'Важность: Критическая';
      case 'HIGH':
        return 'Важность: Высокая';
      case 'MEDIUM':
        return 'Важность: Средняя';
      case 'LOW':
        return 'Важность: Низкая';
      default:
        return severity;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/tag.dart';
import '../../providers/tags_provider.dart';
import '../../theme/app_theme.dart';

class TagDetailsDialog extends ConsumerStatefulWidget {
  final Tag tag;

  const TagDetailsDialog({
    super.key,
    required this.tag,
  });

  @override
  ConsumerState<TagDetailsDialog> createState() => _TagDetailsDialogState();
}

class _TagDetailsDialogState extends ConsumerState<TagDetailsDialog> {
  late Tag _currentTag;
  List<TagValue> _tagHistory = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _currentTag = widget.tag;
    _loadTagHistory();
  }

  Future<void> _loadTagHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      await ref.read(tagsProvider.notifier).fetchTagHistory(_currentTag.id);
      final history = ref.read(tagHistoryProvider(_currentTag.id));
      setState(() {
        _tagHistory = history;
      });
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  Color _getStatusColor() {
    if (_currentTag.isCritical) return AppTheme.criticalColor;
    if (_currentTag.isWarning) return AppTheme.warningColor;
    return AppTheme.normalColor;
  }

  String _getStatusText() {
    if (_currentTag.isCritical) return 'КРИТИЧЕСКИЙ';
    if (_currentTag.isWarning) return 'ПРЕДУПРЕЖДЕНИЕ';
    return 'НОРМА';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Info
                    _buildBasicInfo(),
                    const SizedBox(height: 20.0),
                    
                    // Current Value Section
                    _buildCurrentValueSection(),
                    const SizedBox(height: 20.0),
                    
                    // Limits Section
                    _buildLimitsSection(),
                    const SizedBox(height: 20.0),
                    
                    // History Section
                    _buildHistorySection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        border: Border(
          bottom: BorderSide(
            color: _getStatusColor().withOpacity(0.3),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(),
              color: _getStatusColor(),
              size: 20.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentTag.name,
                  style: AppTheme.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _getStatusText(),
                  style: AppTheme.bodyMedium.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Основная информация',
          style: AppTheme.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12.0),
        _buildInfoRow('Описание', _currentTag.description),
        _buildInfoRow('Тип данных', _currentTag.dataType),
        _buildInfoRow('Объект', _currentTag.pipelineObjectName),
        _buildInfoRow('Тип объекта', _currentTag.objectTypeName),
        _buildInfoRow('Индекс', _currentTag.objectIndex),
        _buildInfoRow('Километр', '${_currentTag.kmMark} км'),
      ],
    );
  }

  Widget _buildCurrentValueSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Текущее значение',
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    _currentTag.formattedValue,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                  Text(
                    'Значение',
                    style: AppTheme.caption.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${_currentTag.currentQuality}%',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: _getQualityColor(),
                    ),
                  ),
                  Text(
                    'Качество',
                    style: AppTheme.caption.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${_currentTag.normalizedValue.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: _getNormalizedColor(),
                    ),
                  ),
                  Text(
                    'Норм. значение',
                    style: AppTheme.caption.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLimitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Пределы значений',
          style: AppTheme.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12.0),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            children: [
              _buildLimitRow('Минимальное', '${_currentTag.minValue} ${_currentTag.engineeringUnits}'),
              const SizedBox(height: 8.0),
              _buildLimitRow('Максимальное', '${_currentTag.maxValue} ${_currentTag.engineeringUnits}'),
              const SizedBox(height: 8.0),
              _buildLimitRow('Диапазон', '${(_currentTag.maxValue - _currentTag.minValue).toStringAsFixed(2)} ${_currentTag.engineeringUnits}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'История значений',
              style: AppTheme.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: _isLoadingHistory ? Colors.white30 : AppTheme.infoColor,
              ),
              onPressed: _isLoadingHistory ? null : _loadTagHistory,
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        if (_isLoadingHistory)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (_tagHistory.isEmpty)
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Text(
                'Нет данных за выбранный период',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white54,
                ),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: _tagHistory.take(10).map((value) => _buildHistoryItem(value)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.0,
            child: Text(
              '$label:',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(TagValue value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.value.toStringAsFixed(2),
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Качество: ${value.quality}%',
                  style: AppTheme.caption.copyWith(
                    color: _getQualityColorForValue(value.quality),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDateTime(value.timestamp),
            style: AppTheme.caption.copyWith(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    if (_currentTag.isCritical) return Icons.warning_amber_rounded;
    if (_currentTag.isWarning) return Icons.info_outline;
    return Icons.check_circle_outline;
  }

  Color _getQualityColor() {
    if (_currentTag.currentQuality >= 90) return AppTheme.normalColor;
    if (_currentTag.currentQuality >= 70) return AppTheme.warningColor;
    return AppTheme.criticalColor;
  }

  Color _getNormalizedColor() {
    final normalized = _currentTag.normalizedValue;
    if (normalized < 0.2 || normalized > 0.8) return AppTheme.warningColor;
    return AppTheme.normalColor;
  }

  Color _getQualityColorForValue(int quality) {
    if (quality >= 90) return AppTheme.normalColor;
    if (quality >= 70) return AppTheme.warningColor;
    return AppTheme.criticalColor;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}.${dateTime.month}.${dateTime.year}';
  }
}
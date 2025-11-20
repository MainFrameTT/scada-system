import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final EdgeInsetsGeometry? padding;

  const SettingsItem({
    super.key,
    required this.title,
    this.subtitle = '',
    this.leading,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              padding: padding ?? const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Leading widget (icon, etc.)
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 16.0),
                  ],
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4.0),
                          Text(
                            subtitle,
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white70,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Trailing widget (chevron, switch, etc.)
                  if (trailing != null) ...[
                    const SizedBox(width: 8.0),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
        
        // Divider
        if (showDivider)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            height: 1.0,
            color: Colors.white.withOpacity(0.1),
          ),
      ],
    );
  }
}

class SettingsItemWithSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? leading;

  const SettingsItemWithSwitch({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.value,
    required this.onChanged,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.infoColor,
      ),
    );
  }
}

class SettingsItemWithCheckbox extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? leading;

  const SettingsItemWithCheckbox({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.value,
    required this.onChanged,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: Checkbox(
        value: value,
        onChanged: (bool? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        fillColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return AppTheme.infoColor;
            }
            return Colors.white30;
          },
        ),
      ),
    );
  }
}

class SettingsItemWithRadio<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final Widget? leading;

  const SettingsItemWithRadio({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: (T? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        fillColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return AppTheme.infoColor;
            }
            return Colors.white30;
          },
        ),
      ),
    );
  }
}

class SettingsItemWithButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final Color? buttonColor;
  final Widget? leading;

  const SettingsItemWithButton({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.buttonText,
    required this.onButtonPressed,
    this.buttonColor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: OutlinedButton(
        onPressed: onButtonPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor ?? AppTheme.infoColor,
          side: BorderSide(color: buttonColor ?? AppTheme.infoColor),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        child: Text(buttonText),
      ),
    );
  }
}

class SettingsItemWithIndicator extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color indicatorColor;
  final String indicatorText;
  final Widget? leading;
  final VoidCallback? onTap;

  const SettingsItemWithIndicator({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.indicatorColor,
    required this.indicatorText,
    this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      title: title,
      subtitle: subtitle,
      leading: leading,
      onTap: onTap,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: indicatorColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(color: indicatorColor.withOpacity(0.5)),
        ),
        child: Text(
          indicatorText,
          style: AppTheme.caption.copyWith(
            color: indicatorColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class SettingsItemWithBadge extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final Widget? leading;
  final VoidCallback? onTap;

  const SettingsItemWithBadge({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.badgeText,
    required this.badgeColor,
    this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      title: title,
      subtitle: subtitle,
      leading: leading,
      onTap: onTap,
      trailing: Container(
        width: 20.0,
        height: 20.0,
        decoration: BoxDecoration(
          color: badgeColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            badgeText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsItemWithProgress extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final Color progressColor;
  final Widget? leading;

  const SettingsItemWithProgress({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.progress,
    required this.progressColor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: SizedBox(
        width: 60.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTheme.caption.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4.0),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              color: progressColor,
              minHeight: 4.0,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsItemExpandable extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget expandedContent;
  final Widget? leading;
  final bool initiallyExpanded;

  const SettingsItemExpandable({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.expandedContent,
    this.leading,
    this.initiallyExpanded = false,
  });

  @override
  State<SettingsItemExpandable> createState() => _SettingsItemExpandableState();
}

class _SettingsItemExpandableState extends State<SettingsItemExpandable> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsItem(
          title: widget.title,
          subtitle: widget.subtitle,
          leading: widget.leading,
          trailing: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _expanded ? 0.25 : 0.0,
            child: const Icon(Icons.chevron_right),
          ),
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          showDivider: !_expanded,
        ),
        
        if (_expanded) ...[
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
            ),
            child: widget.expandedContent,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            height: 1.0,
            color: Colors.white.withOpacity(0.1),
          ),
        ],
      ],
    );
  }
}
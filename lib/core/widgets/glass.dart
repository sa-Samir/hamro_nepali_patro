import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Page background: a vertical gradient with a soft glow near the top.
class PatroBackground extends StatelessWidget {
  const PatroBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.patro;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [p.backgroundTop, p.backgroundBottom],
          stops: const [0, 0.75],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.6, -1.1),
            radius: 1.1,
            colors: [p.glow, p.glow.withValues(alpha: 0)],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Translucent card with a hairline border.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.patro;
    return Material(
      color: p.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: p.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Circular glass icon button, as used in page headers.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, required this.tooltip, this.onPressed, this.size = 44});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.patro;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: p.card,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        fixedSize: Size.square(size),
        side: BorderSide(color: p.cardBorder),
      ),
      icon: Icon(icon, size: 20),
    );
  }
}

/// Serif section title with an optional count badge and a trailing link.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.count, this.action, this.onAction});

  final String title;
  final String? count;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.patro;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: serif(26, onSurface)),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(minWidth: 22),
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p.highlight, borderRadius: BorderRadius.circular(11)),
            child: Text(
              count!,
              style: TextStyle(color: p.onHighlight, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
        const Spacer(),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: p.muted, textStyle: const TextStyle(fontSize: 13)),
            child: Text(action!),
          ),
      ],
    );
  }
}

/// Secondary pill: glass fill, used next to a primary [FilledButton].
class GhostPillButton extends StatelessWidget {
  const GhostPillButton({super.key, required this.label, this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.patro;
    final style = OutlinedButton.styleFrom(
      backgroundColor: p.card,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      side: BorderSide(color: p.cardBorder),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    );
    return icon == null
        ? OutlinedButton(onPressed: onPressed, style: style, child: Text(label))
        : OutlinedButton.icon(onPressed: onPressed, style: style, icon: Icon(icon, size: 18), label: Text(label));
  }
}

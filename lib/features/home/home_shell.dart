import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/context_ext.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass.dart';
import '../../services/app_sync.dart';
import '../calendar/cubit/calendar_cubit.dart';
import '../calendar/view/calendar_page.dart';
import '../converter/view/converter_page.dart';
import '../notes/view/notes_page.dart';
import '../settings/view/settings_page.dart';

enum HomeTab { calendar, converter, reminders, settings }

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  /// Switches tabs from inside a page, e.g. a quick action on the calendar.
  static void show(BuildContext context, HomeTab tab) =>
      context.findAncestorStateOfType<_HomeShellState>()?._select(tab.index);

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  var _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<CalendarCubit>().refreshToday();
      context.read<AppSync>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: PatroBackground(
        child: IndexedStack(
          index: _index,
          children: const [CalendarPage(), ConverterPage(), NotesPage(), SettingsPage()],
        ),
      ),
      bottomNavigationBar: _FloatingNavBar(
        index: _index,
        onSelect: _select,
        items: [
          (Icons.calendar_month_outlined, Icons.calendar_month, l10n.navCalendar),
          (Icons.swap_horiz, Icons.swap_horiz, l10n.navConverter),
          (Icons.notifications_none, Icons.notifications, l10n.navNotes),
          (Icons.settings_outlined, Icons.settings, l10n.navSettings),
        ],
      ),
    );
  }
}

/// A floating pill of round icon buttons; the active one is filled.
class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({required this.index, required this.onSelect, required this.items});

  final int index;
  final ValueChanged<int> onSelect;
  final List<(IconData, IconData, String)> items;

  @override
  Widget build(BuildContext context) {
    final p = context.patro;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: p.nav,
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.25),
            shape: StadiumBorder(side: BorderSide(color: p.cardBorder)),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < items.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Tooltip(
                        message: items[i].$3,
                        child: Semantics(
                          selected: i == index,
                          button: true,
                          label: items[i].$3,
                          child: InkResponse(
                            onTap: () => onSelect(i),
                            radius: 28,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: i == index ? 64 : 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: i == index ? p.highlight : Colors.transparent,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Icon(
                                i == index ? items[i].$2 : items[i].$1,
                                color: i == index ? p.onHighlight : onSurface.withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

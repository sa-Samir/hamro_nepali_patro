import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/context_ext.dart';
import '../../services/app_sync.dart';
import '../calendar/cubit/calendar_cubit.dart';
import '../calendar/view/calendar_page.dart';
import '../converter/view/converter_page.dart';
import '../notes/view/notes_page.dart';
import '../settings/view/settings_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  var _index = 0;

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
      body: IndexedStack(index: _index, children: const [CalendarPage(), ConverterPage(), NotesPage(), SettingsPage()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.navCalendar,
          ),
          NavigationDestination(icon: const Icon(Icons.swap_horiz), label: l10n.navConverter),
          NavigationDestination(
            icon: const Icon(Icons.notifications_none),
            selectedIcon: const Icon(Icons.notifications),
            label: l10n.navNotes,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class _Onglet {
  final IconData icone;
  final IconData iconeActive;
  final String libelle;

  const _Onglet({
    required this.icone,
    required this.iconeActive,
    required this.libelle,
  });
}

class BarreNavigation extends StatelessWidget {
  final int indexActif;
  final ValueChanged<int> onChangement;

  const BarreNavigation({
    super.key,
    required this.indexActif,
    required this.onChangement,
  });

  static const List<_Onglet> _onglets = [
    _Onglet(
      icone: Icons.dashboard_outlined,
      iconeActive: Icons.dashboard,
      libelle: 'Accueil',
    ),
    _Onglet(
      icone: Icons.checklist_outlined,
      iconeActive: Icons.checklist,
      libelle: 'Tâches',
    ),
    _Onglet(
      icone: Icons.menu_book_outlined,
      iconeActive: Icons.menu_book,
      libelle: 'Matières',
    ),
  ];

  static int get nombreOnglets => _onglets.length;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: indexActif,
      onDestinationSelected: onChangement,
      destinations: _onglets.map((onglet) {
        return NavigationDestination(
          icon: Icon(onglet.icone),
          selectedIcon: Icon(onglet.iconeActive),
          label: onglet.libelle,
        );
      }).toList(),
    );
  }
}

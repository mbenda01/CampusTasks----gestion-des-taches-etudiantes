import 'package:flutter/material.dart';

import '../models/tache.dart';
import 'pastille.dart';

class CarteTache extends StatelessWidget {
  final Tache tache;
  final VoidCallback? onTap;
  final VoidCallback? onBasculerTerminee;
  final Widget? actions;
  final bool enCours;
  final EdgeInsetsGeometry marge;

  const CarteTache({
    super.key,
    required this.tache,
    this.onTap,
    this.onBasculerTerminee,
    this.actions,
    this.enCours = false,
    this.marge = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: marge,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enCours ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _construireCase(context),
              Expanded(child: _construireContenu(context)),
              _construireFin(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construireCase(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;

    final icone = Icon(
      tache.estTerminee ? Icons.check_circle : Icons.radio_button_unchecked,
      color: tache.estTerminee ? Colors.green.shade700 : couleurs.outline,
    );

    if (onBasculerTerminee == null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: icone,
      );
    }

    return IconButton(
      tooltip: tache.estTerminee ? 'Remettre à faire' : 'Marquer terminée',
      onPressed: enCours ? null : onBasculerTerminee,
      icon: icone,
    );
  }

  Widget _construireContenu(BuildContext context) {
    final textes = Theme.of(context).textTheme;
    final couleurs = Theme.of(context).colorScheme;
    final couleurEcheance =
        tache.enRetard ? couleurs.error : textes.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tache.titre,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: tache.estTerminee ? TextDecoration.lineThrough : null,
            ),
          ),
          if (tache.matiereNom != null) ...[
            const SizedBox(height: 2),
            Text(tache.matiereNom!, style: textes.bodySmall),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Pastille.statut(tache.statut),
              Pastille.priorite(tache.priorite),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_outlined, size: 14, color: couleurEcheance),
                  const SizedBox(width: 4),
                  Text(
                    '${tache.dateLimiteFormatee} · ${tache.echeanceRelative}',
                    style: TextStyle(
                      fontSize: 12,
                      color: couleurEcheance,
                      fontWeight: tache.enRetard ? FontWeight.w600 : null,
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

  Widget _construireFin() {
    if (enCours) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return actions ?? const SizedBox(width: 8);
  }
}

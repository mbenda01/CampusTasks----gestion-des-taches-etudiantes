import '../models/tableau_bord.dart';

abstract class TableauBordRepository {
  Future<TableauBord> consulter();
}

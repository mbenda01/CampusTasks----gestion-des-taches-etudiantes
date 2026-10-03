import '../core/client_http_interface.dart';
import '../models/tableau_bord.dart';
import 'api_repository_base.dart';
import 'tableau_bord_repository.dart';

class TableauBordRepositoryApi extends ApiRepositoryBase
    implements TableauBordRepository {
  const TableauBordRepositoryApi({required ClientHttpInterface client})
      : super(client: client);

  @override
  Future<TableauBord> consulter() {
    return executer(
      () => client.get('/api/v1/dashboard'),
      (donnees) => TableauBord.depuisJson(donnees as Map<String, dynamic>),
    );
  }
}

import 'package:floret_app/services/web_api_services.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;
import '../model/home_model.dart';

class HomeRepository {
  final WebAPIService _webAPIService;

  HomeRepository({WebAPIService? webAPIService})
      : _webAPIService = webAPIService ?? WebAPIService();

  WebAPIService get webAPIService => _webAPIService;

  Future<String> getUserName() async {
    final name = await SpHelper.getString(sp_keys.keyUserName);
    if (name != null && name.trim().isNotEmpty) {
      return name;
    }
    final raw = await SpHelper.getString('user_name');
    if (raw != null && raw.trim().isNotEmpty) {
      return raw;
    }
    return 'nicy nicy';
  }

  Future<List<PickupOptionModel>> getPickupOptions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      PickupOptionModel(
        id: 'doorstep',
        title: 'Daily Doorstep Collection',
        subtitle: 'Scheduled recurring waste collection at your doorstep',
        iconName: 'doorbell',
        estimatedWeight: '1 - 5 kg',
      ),
      PickupOptionModel(
        id: 'bulk',
        title: 'Bulk Waste Pickup',
        subtitle: 'Large quantity commercial or residential waste pickup',
        iconName: 'truck',
        estimatedWeight: '10+ kg',
      ),
      PickupOptionModel(
        id: 'recyclables',
        title: 'Recyclables Segregated',
        subtitle: 'Sorted dry plastics, papers, cans, and electronic scrap',
        iconName: 'recycling',
        estimatedWeight: '2 - 8 kg',
      ),
    ];
  }

  Future<bool> bookPickup(PickupBookingModel booking) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}

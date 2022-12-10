import 'package:nearby/config/collections.dart';
import 'package:uuid/uuid.dart';

class Services {
  addService(String name, String serviceId, double latitude, double longitude,
      String subtype, String type) async {
    var uuid = Uuid();

    await servicesRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "name": name,
      "serviceId": serviceId,
      "subType": subtype,
      "type": type,
      "latitude": latitude,
      "longitude": longitude,
      "timestamp": timestamp,
    });
  }
}

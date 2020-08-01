import 'package:nearby/config/collections.dart';
import 'package:uuid/uuid.dart';

class Services {
  addService(String name, String serviceId, String subtype, String type) async {
    var uuid = Uuid();

   await servicesRef.add({
      "id": uuid.v1().toString() + new DateTime.now().toString(),
      "name": name,
      "serviceId": serviceId,
      "subType": subtype,
      "type": type,
      "timestamp": timestamp,
    });
  }
}

import 'dart:convert';
class Schema {
  final int id;
  final String name;
  final String description;
  final double amount;
  final double maturityAmount;
  final String  roi;
  final String duration;
  final String type;
  final String startDate;

  Schema({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.maturityAmount,
    required this.roi,
    required this.duration,
    required this.type,
    required this.startDate,
  });

  factory Schema.fromJson(Map<String, dynamic> json) {
    return Schema(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      maturityAmount: double.tryParse(json['maturityAmount'].toString()) ?? 0.0,
      roi: json['roi'],
      duration: json['duration'].toString(),
      type: json['type'],
      startDate: json['start_date'],
    );
  }
}


void parseSchemaResponse(String jsonResponse) {
  final Map<String, dynamic> data = json.decode(jsonResponse);
  final List<dynamic> schemaList = data['schemas'];
  // Map the schema list to a List of Schema objects
  List<Schema> schemas = schemaList.map((json) => Schema.fromJson(json)).toList();
  // You can now use the schemas list in your app
  print(schemas);
}

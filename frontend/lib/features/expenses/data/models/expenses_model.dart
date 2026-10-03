import '../../domain/entities/expenses_entity.dart';

class ExpensesModel extends ExpensesEntity {
  const ExpensesModel({super.id});

  factory ExpensesModel.fromJson(Map<String, dynamic> json) {
    return ExpensesModel(
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

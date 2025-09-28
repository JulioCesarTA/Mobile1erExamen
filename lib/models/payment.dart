class Payment {
  final String id;
  final String concept;
  final double amount;
  final DateTime? dueDate;
  final bool paid;

  Payment({
    required this.id,
    required this.concept,
    required this.amount,
    this.dueDate,
    required this.paid,
  });
}

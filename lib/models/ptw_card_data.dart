class PtwCardData {
  final int? id;         // database ID
  final String ptwId;    // maps to ptw_code
  final String status;
  final String feeder;
  final String date;
  final String? dueTime;


  PtwCardData({
    this.id,
    required this.ptwId,
    required this.status,
    required this.feeder,
    required this.date,
    required this.dueTime,
  });

}

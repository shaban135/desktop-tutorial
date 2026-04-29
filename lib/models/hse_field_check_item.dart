class HseChecklistRow {
  final int srNo;
  final String description;
  String response; // 'Yes', 'No', 'NA', or ''
  String observations;

  HseChecklistRow({
    required this.srNo,
    required this.description,
    this.response = '',
    this.observations = '',
  });

  Map<String, dynamic> toJson() => {
    'sr_no': srNo,
    'description': description,
    'response': response,
    'observations': observations,
  };
}

class NonComplianceRow {
  String description;
  String immediateAction;
  String responsiblePerson;

  NonComplianceRow({
    this.description = '',
    this.immediateAction = '',
    this.responsiblePerson = '',
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    'immediate_action': immediateAction,
    'responsible_person': responsiblePerson,
  };
}

class Project {
  final int? id;
  final String projectName;
  final String companyName;
  final String companyAddress;
  final String projectType;
  final List<Specification> specifications;
  final List<Rfi> rfis;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Project({
    this.id,
    required this.projectName,
    required this.companyName,
    required this.companyAddress,
    required this.projectType,
    this.specifications = const [],
    this.rfis = const [],
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['project_id'] ?? json['id'],
      projectName: json['project_name'] ?? json['projectName'] ?? '',
      companyName: json['company_name'] ?? json['companyName'] ?? '',
      companyAddress: json['company_address'] ?? json['companyAddress'] ?? '',
      projectType: json['project_type'] ?? json['projectType'] ?? '',
      specifications: (json['specifications'] as List<dynamic>?)
          ?.map((spec) => Specification.fromJson(spec))
          .toList() ?? [],
      rfis: (json['rfis'] as List<dynamic>?)
          ?.map((rfi) => Rfi.fromJson(rfi))
          .toList() ?? [],
      status: json['project_status'] ?? json['status'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'project_name': projectName,
      'company_name': companyName,
      'company_address': companyAddress,
      'project_type': projectType,
      'specifications': specifications.map((spec) => spec.toJson()).toList(),
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
    
    // Only include rfis if there are any RFIs
    if (rfis.isNotEmpty) {
      json['rfis'] = rfis.map((rfi) => rfi.toJson()).toList();
    }
    
    return json;
  }

  @override
  String toString() {
    return 'Project(id: $id, projectName: $projectName, companyName: $companyName)';
  }
}

class Specification {
  final int? id;
  final int versionNo;
  final String colour;
  final String? colourAttachment;
  final String ironmongery;
  final String? ironmongeryAttachment;
  final String uValue;
  final String? uValueAttachment;
  final String gValue;
  final String? gValueAttachment;
  final String vents;
  final String? ventsAttachment;
  final String acoustics;
  final String? acousticsAttachment;
  final String sbd;
  final String? sbdAttachment;
  final String pas24;
  final String? pas24Attachment;
  final String restrictors;
  final String? restrictorsAttachment;
  final String specialComments;
  final String? attachmentUrl;
  final String? createdBy;
  final DateTime? createdAt;

  Specification({
    this.id,
    required this.versionNo,
    required this.colour,
    this.colourAttachment,
    required this.ironmongery,
    this.ironmongeryAttachment,
    required this.uValue,
    this.uValueAttachment,
    required this.gValue,
    this.gValueAttachment,
    required this.vents,
    this.ventsAttachment,
    required this.acoustics,
    this.acousticsAttachment,
    required this.sbd,
    this.sbdAttachment,
    required this.pas24,
    this.pas24Attachment,
    required this.restrictors,
    this.restrictorsAttachment,
    required this.specialComments,
    this.attachmentUrl,
    this.createdBy,
    this.createdAt,
  });

  factory Specification.fromJson(Map<String, dynamic> json) {
    return Specification(
      id: json['specification_id'] ?? json['id'],
      versionNo: json['version_no'] ?? 1,
      colour: json['colour'] ?? '',
      colourAttachment: json['colour_attachment'],
      ironmongery: json['ironmongery'] ?? '',
      ironmongeryAttachment: json['ironmongery_attachment'],
      uValue: json['u_value']?.toString() ?? '',
      uValueAttachment: json['u_value_attachment'],
      gValue: json['g_value']?.toString() ?? '',
      gValueAttachment: json['g_value_attachment'],
      vents: json['vents'] ?? '',
      ventsAttachment: json['vents_attachment'],
      acoustics: json['acoustics'] ?? '',
      acousticsAttachment: json['acoustics_attachment'],
      sbd: json['sbd']?.toString() ?? '',
      sbdAttachment: json['sbd_attachment'],
      pas24: json['pas24']?.toString() ?? '',
      pas24Attachment: json['pas24_attachment'],
      restrictors: json['restrictors']?.toString() ?? '',
      restrictorsAttachment: json['restrictors_attachment'],
      specialComments: json['special_comments'] ?? '',
      attachmentUrl: json['attachment_url'],
      createdBy: json['creator']?['full_name'] ?? json['created_by']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'version_no': versionNo,
      'colour': colour,
      'ironmongery': ironmongery,
      'u_value': uValue,
      'g_value': gValue,
      'vents': vents,
      'acoustics': acoustics,
      'sbd': sbd,
      'pas24': pas24,
      'restrictors': restrictors,
      'special_comments': specialComments,
    };

    if (id != null) json['id'] = id;
    if (colourAttachment != null) json['colour_attachment'] = colourAttachment;
    if (ironmongeryAttachment != null) json['ironmongery_attachment'] = ironmongeryAttachment;
    if (uValueAttachment != null) json['u_value_attachment'] = uValueAttachment;
    if (gValueAttachment != null) json['g_value_attachment'] = gValueAttachment;
    if (ventsAttachment != null) json['vents_attachment'] = ventsAttachment;
    if (acousticsAttachment != null) json['acoustics_attachment'] = acousticsAttachment;
    if (sbdAttachment != null) json['sbd_attachment'] = sbdAttachment;
    if (pas24Attachment != null) json['pas24_attachment'] = pas24Attachment;
    if (restrictorsAttachment != null) json['restrictors_attachment'] = restrictorsAttachment;
    if (attachmentUrl != null) json['attachment_url'] = attachmentUrl;

    return json;
  }
}

class Rfi {
  final int? id;
  final String questionText;
  final String? answer;
  final String? answerValue;
  final String? status;
  final DateTime? createdAt;
  final DateTime? answeredAt;

  Rfi({
    this.id,
    required this.questionText,
    this.answer,
    this.answerValue,
    this.status,
    this.createdAt,
    this.answeredAt,
  });

  factory Rfi.fromJson(Map<String, dynamic> json) {
    return Rfi(
      id: json['rfi_id'] ?? json['id'],
      questionText: json['question_text'] ?? '',
      answer: json['answer'],
      answerValue: json['answer_value'],
      status: json['status'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      answeredAt: json['answered_at'] != null 
          ? DateTime.parse(json['answered_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'answer': answer,
      'answer_value': answerValue,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'answered_at': answeredAt?.toIso8601String(),
    };
  }
}

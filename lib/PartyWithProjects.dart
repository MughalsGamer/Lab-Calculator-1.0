// party_with_projects.dart


import 'Model class.dart';
import 'Party Model.dart';

class PartyWithProjects {
  final PartyModel party;
  final List<CustomerModel> projects;

  PartyWithProjects(this.party, this.projects);

  double get totalAmount => projects.fold(0, (sum, project) => sum + project.totalAmount);
  double get totalAdvance => projects.fold(0, (sum, project) => sum + project.advance);
  double get totalRemaining => projects.fold(0, (sum, project) => sum + project.remainingBalance);
  double get totalSqFt => projects.fold(0, (sum, project) => sum + project.totalSqFt);
  int get projectCount => projects.length;
}
part of 'legal_actions_cubit.dart';

enum LegalActionsStatus { initial, loading, success, failure }

class LegalActionsState extends Equatable {
  const LegalActionsState({
    this.status = LegalActionsStatus.initial,
    this.actionsList = const[],
    this.userNamesMap = const {}, // 🌟 لترجمة الـ user_id إلى اسم الموظف
    this.errorMessage,
  });

  final LegalActionsStatus status;
  final List<LegalAction> actionsList;
  final Map<String, String> userNamesMap;
  final String? errorMessage;

  LegalActionsState copyWith({
    LegalActionsStatus? status,
    List<LegalAction>? actionsList,
    Map<String, String>? userNamesMap,
    String? errorMessage,
  }) {
    return LegalActionsState(
      status: status ?? this.status,
      actionsList: actionsList ?? this.actionsList,
      userNamesMap: userNamesMap ?? this.userNamesMap,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, actionsList, userNamesMap, errorMessage];
}
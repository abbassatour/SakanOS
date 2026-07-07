//lib\dashboard\cubit\dashboard_cubit.dart
import 'package:bloc/bloc.dart';

class DashboardCubit extends Cubit<int> {
  DashboardCubit() : super(0);

  // دالة لتغيير الشاشة عند الضغط على القائمة الجانبية
  void changeTab(int index) => emit(index);
}

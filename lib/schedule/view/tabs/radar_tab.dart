// lib/schedule/view/tabs/radar_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/schedule_cubit.dart';
import '../dialogs/take_action_dialog.dart';

class RadarTab extends StatefulWidget {
  final ScheduleState state;

  const RadarTab({super.key, required this.state});

  @override
  State<RadarTab> createState() => _RadarTabState();
}

class _RadarTabState extends State<RadarTab> {
  // 🌟 متغيرات الفلترة المتعددة
  String _urgencyFilter = 'all';

  // 🌟 متغير شريط السحب للسرعة (المدى الافتراضي من 0 إلى 10)
  RangeValues _speedRange = const RangeValues(0.0, 10.0);

  @override
  Widget build(BuildContext context) {
    if (widget.state.allocationAlerts.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد عقود "لاحق التخصص" حالياً لمراقبتها.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // 🌟 تطبيق الفلترة المركبة (خطورة + سرعة دقيقة)
    final filteredAlerts = widget.state.allocationAlerts.where((alert) {
      bool passUrgency = true;
      if (_urgencyFilter != 'all') {
        passUrgency = alert.urgencyLevel == _urgencyFilter;
      }

      bool passSpeed = alert.averageMetersPerMonth >= _speedRange.start;
      if (_speedRange.end < 10.0) {
        passSpeed = passSpeed && alert.averageMetersPerMonth <= _speedRange.end;
      }

      return passUrgency && passSpeed;
    }).toList();

    final bool hasActiveFilters =
        _urgencyFilter != 'all' ||
        _speedRange.start > 0.0 ||
        _speedRange.end < 10.0;

    return Scaffold(
      backgroundColor: Colors.transparent,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFilterBottomSheet,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.filter_alt),
        label: const Text(
          'فرز وتصفية',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          // 🌟 شريط الفلاتر النشطة
          if (hasActiveFilters)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                border: Border.all(color: Colors.indigo.shade200),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list_alt,
                    color: Colors.indigo,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الفلاتر النشطة حالياً:',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          '${_getUrgencyName(_urgencyFilter)}  |  السرعة: ${_speedRange.start.toStringAsFixed(1)} إلى ${_speedRange.end == 10.0 ? '10+' : _speedRange.end.toStringAsFixed(1)} م²',
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _urgencyFilter = 'all';
                        _speedRange = const RangeValues(0.0, 10.0);
                      });
                    },
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text(
                      'إلغاء الفلاتر',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: filteredAlerts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'لا يوجد نتائج تطابق الفلاتر المحددة',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: hasActiveFilters ? 0 : 12,
                    ).copyWith(bottom: 80),
                    itemCount: filteredAlerts.length,
                    itemBuilder: (context, index) {
                      final alert = filteredAlerts[index];
                      final target = context
                          .read<ScheduleCubit>()
                          .targetAllocationMeters;

                      double progress = alert.accumulatedMeters / target;
                      if (progress > 1.0) progress = 1.0;

                      Color cardColor;
                      Color progressColor;
                      IconData urgencyIcon;
                      String urgencyText;

                      if (alert.urgencyLevel == 'action_taken') {
                        cardColor = Colors.grey;
                        progressColor = Colors.grey.shade500;
                        urgencyIcon = Icons.done_all;
                        urgencyText = 'تم إجراء';
                      } else if (alert.urgencyLevel == 'high') {
                        cardColor = Colors.redAccent;
                        progressColor = Colors.redAccent;
                        urgencyIcon = Icons.local_fire_department;
                        urgencyText = alert.accumulatedMeters >= target
                            ? 'تجاوز!'
                            : 'خطر (${alert.estimatedMonthsLeft} ش)';
                      } else if (alert.urgencyLevel == 'medium') {
                        cardColor = Colors.orange;
                        progressColor = Colors.orange;
                        urgencyIcon = Icons.warning_amber_rounded;
                        urgencyText = 'متوسط (${alert.estimatedMonthsLeft} ش)';
                      } else {
                        cardColor = Colors.green;
                        progressColor = Colors.green;
                        urgencyIcon = Icons.shield;
                        urgencyText = alert.estimatedMonthsLeft == 999
                            ? 'لا دفعات'
                            : 'آمن (${alert.estimatedMonthsLeft} ش)';
                      }

                      final bool isActionTaken =
                          alert.urgencyLevel == 'action_taken';

                      return Card(
                        elevation: isActionTaken ? 0 : 2,
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isActionTaken
                            ? Colors.grey.shade50
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isActionTaken
                                ? Colors.grey.shade300
                                : cardColor.withOpacity(0.4),
                            width: 1,
                          ),
                        ),

                        // ==========================================
                        // 🌟 سحر التمرير الأفقي لكل بطاقة بشكل منفصل
                        // ==========================================
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // نحدد عرض المحتوى الداخلي: إما أن يتمدد مع الشاشة، أو يتوقف عند 950 بكسل ويبدأ التمرير
                            final double cardWidth = constraints.maxWidth > 950
                                ? constraints.maxWidth
                                : 950;

                            return Scrollbar(
                              thickness: 0.0,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: SizedBox(
                                  width:
                                      cardWidth, // 👈 تثبيت العرض لكي تعمل عناصر الـ Expanded
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // 1. قسم الاسم (عرض ثابت لا يتقلص أبداً)
                                        SizedBox(
                                          width: 250,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      alert.client.name,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isActionTaken
                                                            ? Colors
                                                                  .grey
                                                                  .shade700
                                                            : Colors.black87,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: cardColor
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                      border: Border.all(
                                                        color: cardColor
                                                            .withOpacity(0.5),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          urgencyIcon,
                                                          size: 12,
                                                          color: cardColor,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          urgencyText,
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: cardColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                alert.contract.apartmentDetails,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        // 2. قسم شريط التقدم
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Text(
                                                    'التخصص: ',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.blueGrey,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                      child:
                                                          LinearProgressIndicator(
                                                            value: progress,
                                                            minHeight: 6,
                                                            backgroundColor:
                                                                Colors
                                                                    .grey
                                                                    .shade200,
                                                            color:
                                                                progressColor,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '${alert.accumulatedMeters.toStringAsFixed(1)} / $target م²',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: progressColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (alert.lastActionNote !=
                                                  null) ...[
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.history_edu,
                                                      size: 12,
                                                      color: Colors.teal,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        'إجراء سابق (${alert.lastActionDate?.year}/${alert.lastActionDate?.month}/${alert.lastActionDate?.day}): ${alert.lastActionNote}',
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.teal,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        // 3. قسم المقاييس (تم تعديل المسافة بينها بناءً على طلبك)
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _buildDesktopMetric(
                                                Icons.speed,
                                                'السرعة',
                                                '${alert.averageMetersPerMonth.toStringAsFixed(1)} م²/ش',
                                                isActionTaken
                                                    ? Colors.grey
                                                    : Colors.blue,
                                              ),
                                              const SizedBox(width: 24),
                                              _buildDesktopMetric(
                                                Icons.timelapse,
                                                'العمر',
                                                '${DateTime.now().difference(alert.contract.contractDate).inDays ~/ 30} ش',
                                                isActionTaken
                                                    ? Colors.grey
                                                    : Colors.purple,
                                              ),
                                              const SizedBox(width: 24),
                                              _buildDesktopMetric(
                                                Icons.flag,
                                                'المتبقي',
                                                alert.estimatedMonthsLeft == 999
                                                    ? '∞'
                                                    : '${alert.estimatedMonthsLeft} ش',
                                                progressColor,
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        // 4. قسم الزر
                                        SizedBox(
                                          width: 110,
                                          height: 36,
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isActionTaken
                                                  ? Colors.grey.shade300
                                                  : Colors.teal,
                                              foregroundColor: isActionTaken
                                                  ? Colors.black87
                                                  : Colors.white,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            icon: Icon(
                                              isActionTaken
                                                  ? Icons.edit
                                                  : Icons.handshake,
                                              size: 14,
                                            ),
                                            label: Text(
                                              isActionTaken ? 'تحديث' : 'إجراء',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            onPressed: () =>
                                                showTakeActionDialog(
                                                  context,
                                                  alert.contract,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopMetric(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    String tempUrgency = _urgencyFilter;
    RangeValues tempSpeedRange = _speedRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.filter_alt, color: Colors.indigo, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'فرز وتصفية رادار التخصص',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    '1. مستوى الخطورة والاقتراب من الهدف:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChipRadio(
                        'all',
                        '🌐 الكل',
                        tempUrgency,
                        Colors.indigo,
                        (v) => setModalState(() => tempUrgency = v),
                      ),
                      _buildChipRadio(
                        'high',
                        '🔴 حالات حرجة',
                        tempUrgency,
                        Colors.red,
                        (v) => setModalState(() => tempUrgency = v),
                      ),
                      _buildChipRadio(
                        'medium',
                        '🟠 حالات متوسطة',
                        tempUrgency,
                        Colors.orange,
                        (v) => setModalState(() => tempUrgency = v),
                      ),
                      _buildChipRadio(
                        'low',
                        '🟢 حالات آمنة',
                        tempUrgency,
                        Colors.green,
                        (v) => setModalState(() => tempUrgency = v),
                      ),
                      _buildChipRadio(
                        'action_taken',
                        '⚪  تم اتخاذ إجراء مؤخراً',
                        tempUrgency,
                        Colors.grey.shade700,
                        (v) => setModalState(() => tempUrgency = v),
                      ),
                    ],
                  ),

                  const Divider(height: 32, thickness: 1.5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '2. تحديد مجال سرعة الدفع (م² / شهر):',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${tempSpeedRange.start.toStringAsFixed(1)}  إلى  ${tempSpeedRange.end == 10.0 ? "10+" : tempSpeedRange.end.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.indigo,
                      inactiveTrackColor: Colors.indigo.shade100,
                      thumbColor: Colors.indigo,
                      overlayColor: Colors.indigo.withOpacity(0.2),
                      valueIndicatorColor: Colors.indigo,
                      valueIndicatorTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: RangeSlider(
                      values: tempSpeedRange,
                      min: 0.0,
                      max: 10.0,
                      divisions: 100,
                      labels: RangeLabels(
                        tempSpeedRange.start.toStringAsFixed(1),
                        tempSpeedRange.end == 10.0
                            ? '10+'
                            : tempSpeedRange.end.toStringAsFixed(1),
                      ),
                      onChanged: (RangeValues values) {
                        setModalState(() {
                          tempSpeedRange = values;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check_circle),
                      label: const Text(
                        'تطبيق الفرز',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _urgencyFilter = tempUrgency;
                          _speedRange = tempSpeedRange;
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChipRadio(
    String value,
    String title,
    String groupValue,
    Color color,
    Function(String) onChanged,
  ) {
    final isSelected = groupValue == value;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  String _getUrgencyName(String filter) {
    switch (filter) {
      case 'high':
        return '🔴 حالات حرجة';
      case 'medium':
        return '🟠 حالات متوسطة';
      case 'low':
        return '🟢 حالات آمنة';
      case 'action_taken':
        return '⚪ تم إجراء (مؤجلة)';
      default:
        return '🌐 جميع الحالات';
    }
  }
}

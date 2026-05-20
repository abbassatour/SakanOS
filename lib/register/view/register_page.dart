//lib\register\view\register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';

import '../cubit/register_cubit.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(context.read<ErpRepository>()),
      child: const RegisterView(),
    );
  }
}

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state.status == RegisterStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'حدث خطأ'), backgroundColor: Colors.red),
            );
          } else if (state.status == RegisterStatus.success) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Row(
                  children:[
                    Icon(Icons.mark_email_unread, color: Colors.indigo, size: 30),
                    SizedBox(width: 10),
                    Text('تأكيد البريد الإلكتروني', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    const Text(
                      'تم إرسال رابط التفعيل إلى بريدك الإلكتروني بنجاح.',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'الخطوات المتبقية:',
                      style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1️⃣ قم بفتح بريدك الإلكتروني واضغط على رابط التفعيل.\n'
                      '2️⃣ إذا كنت أول شخص يسجل في هذا النظام، سيتم تفعيل حسابك كمدير عام (Admin) تلقائياً.\n'
                      '3️⃣ أما إذا كنت موظفاً جديداً، يرجى إبلاغ المدير ليقوم بتحديد صلاحياتك من لوحة التحكم.',
                      style: TextStyle(height: 1.6, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200)
                      ),
                      child: Row(
                        children:[
                          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'لن تتمكن من الدخول للنظام قبل تنفيذ هاتين الخطوتين.',
                              style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                actions:[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade900, 
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop(); // إغلاق النافذة
                      Navigator.of(context).pop(); // العودة لشاشة تسجيل الدخول
                    },
                    child: const Text('فهمت، العودة لتسجيل الدخول'),
                  )
                ],
              ),
            );
          }
        },
        child: Center(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(40.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const[BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:[
                  const Icon(Icons.person_add_alt_1, size: 70, color: Colors.blueGrey),
                  const SizedBox(height: 16),
                  const Text('حساب موظف جديد', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 8),
                  const Text('أدخل بياناتك لطلب الانضمام للنظام', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),

                  // 1. حقل الاسم
                  TextField(
                    onChanged: (val) => context.read<RegisterCubit>().fullNameChanged(val),
                    decoration: const InputDecoration(labelText: 'الاسم الكامل الثلاثي', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),

                  // 2. حقل الإيميل
                  TextField(
                    onChanged: (val) => context.read<RegisterCubit>().emailChanged(val),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),

                  // 3. حقل الباسورد
                  TextField(
                    onChanged: (val) => context.read<RegisterCubit>().passwordChanged(val),
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'كلمة المرور (6 أحرف على الأقل)', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),

                  // 🌟 4. حقل تأكيد الباسورد الجديد
                  TextField(
                    onChanged: (val) => context.read<RegisterCubit>().confirmPasswordChanged(val),
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'تأكيد كلمة المرور', 
                      prefixIcon: Icon(Icons.lock_reset), // أيقونة مختلفة قليلاً للتمييز
                      border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 5. زر إنشاء الحساب
                  BlocBuilder<RegisterCubit, RegisterState>(
                    builder: (context, state) {
                      return state.status == RegisterStatus.loading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => context.read<RegisterCubit>().submit(),
                                child: const Text('تسجيل الحساب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // 6. زر الرجوع
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.blueGrey),
                    label: const Text('إلغاء والعودة', style: TextStyle(color: Colors.blueGrey)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
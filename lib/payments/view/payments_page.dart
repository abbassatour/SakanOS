// lib/payments/view/payments_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/core/constants/app_permissions.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import 'package:our_home_erp_app/payments/cubit/payments_cubit.dart';
import 'package:our_home_erp_app/payments/widgets/widgets.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PaymentsView();
  }
}

class PaymentsView extends StatelessWidget {
  const PaymentsView({super.key});

  String _resolvePaymentErrorMessage(BuildContext context, String? errorKey) {
    final l10n = context.l10n;
    if (errorKey == null) return l10n.homeUnexpectedError;

    final cleanKey = errorKey.replaceAll('Exception:', '').trim();

    if (cleanKey == 'paymentErrorContractNotFound') {
      return l10n.paymentErrorContractNotFound;
    }
    if (cleanKey == 'paymentErrorMissingMaterialPrices') {
      return l10n.paymentErrorMissingMaterialPrices;
    }
    if (cleanKey == 'paymentErrorOldCancellationBlocked') {
      return l10n.paymentErrorOldCancellationBlocked;
    }
    if (cleanKey.startsWith('paymentErrorUpdateFailed:')) {
      final err = cleanKey.replaceFirst('paymentErrorUpdateFailed:', '');
      return l10n.paymentErrorUpdateFailed(err);
    }
    if (cleanKey.startsWith('paymentErrorWhatsAppStatusFailed:')) {
      final err = cleanKey.replaceFirst(
        'paymentErrorWhatsAppStatusFailed:',
        '',
      );
      return l10n.paymentErrorWhatsAppStatusFailed(err);
    }

    return cleanKey;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canAdd = context.select<AuthCubit, bool>(
      (c) => c.state.hasPermission(AppPermissions.addPayments),
    );
    final canEdit = context.select<AuthCubit, bool>(
      (c) => c.state.hasPermission(AppPermissions.editPayments),
    );
    final canDelete = context.select<AuthCubit, bool>(
      (c) => c.state.hasPermission(AppPermissions.deletePayments),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: BlocListener<PaymentsCubit, PaymentsState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == PaymentsStatus.failure) {
              final resolvedMsg = _resolvePaymentErrorMessage(
                context,
                state.errorMessage,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    resolvedMsg,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: BlocBuilder<PaymentsCubit, PaymentsState>(
            builder: (context, state) {
              if (state.status == PaymentsStatus.loading &&
                  state.contracts.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.deepOrange),
                );
              }

              if (state.clients.isEmpty || state.contracts.isEmpty) {
                return Center(
                  child: Text(
                    l10n.paymentEmptyNoContracts,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return Column(
                children: [
                  PaymentsTopBar(state: state, canAdd: canAdd),
                  PaymentSummaryCard(state: state),

                  Expanded(
                    child: state.selectedContractId == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 80,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.paymentEmptyNoSelected,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : state.ledgerEntries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.money_off,
                                  size: 60,
                                  color: Colors.orange.shade200,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.paymentEmptyNoPayments,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : PaymentsDataTable(
                            state: state,
                            canEdit: canEdit,
                            canDelete: canDelete,
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// lib/core/constants/app_permissions.dart

class AppPermissions {
  // العملاء
  static const String viewClients = 'clients.view';
  static const String createClients = 'clients.create';
  static const String editClients = 'clients.edit';
  static const String deleteClients = 'clients.delete';

  // العقود
  static const String viewContracts = 'contracts.view';
  static const String createContracts = 'contracts.create';
  static const String restructureContracts = 'contracts.restructure'; 
  
  // المدفوعات
  static const String viewPayments = 'payments.view';
  static const String addPayments = 'payments.add';
  static const String editPayments = 'payments.edit'; 
  static const String deletePayments = 'payments.delete'; 
  
  // أسعار المواد والمحاضر
  static const String viewPrices = 'prices.view';
  static const String updatePrices = 'prices.update';
  static const String manageBuildings = 'buildings.manage';

  // سلة المحذوفات
  static const String viewRecycleBin = 'recycle_bin.view';
  static const String restoreItems = 'recycle_bin.restore';
  static const String hardDeleteItems = 'recycle_bin.hard_delete'; 
  

  // 🌟 الصلاحية الجديدة الخاصة بصفحة المحامي والأرشيف
  static const String manageLegalAffairs = 'manage_legal_affairs';
  
  static const List<String> all =[
    viewClients, createClients, editClients, deleteClients,
    viewContracts, createContracts, restructureContracts,
    viewPayments, addPayments, editPayments, deletePayments,
    viewPrices, updatePrices, manageBuildings,
    viewRecycleBin, restoreItems, hardDeleteItems
  ];
}
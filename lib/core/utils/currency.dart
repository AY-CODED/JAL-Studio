String formatNaira(int amountKobo) {
  final naira = amountKobo ~/ 100;
  final grouped = naira.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '₦$grouped';
}

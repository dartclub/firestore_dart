import 'dart:math';

var random = Random.secure();

List a = ['Burgerheart', 'Falafello', 'Mosch Mosch', 'Osteria'];

main() {
  print(a[random.nextInt(a.length)]);
}

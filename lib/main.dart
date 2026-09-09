import 'package:flutter/material.dart';
import 'dart:math';

// Типы оружия
enum WeaponType { ak74, svd, rpk74 }

// Направления отклонений
enum HDir { left, right }
enum VDir { down, up }

// Модель оружия с коэффициентами пересчёта
class Weapon {
  final WeaponType type;
  final String name;
  final double verticalCoefficient;   // см в 1 оборот маховика по вертикали
  final double horizontalCoefficient; // см в 1 мм боковой поправки
  final double maxDeviation; // ⚠️ ограничительный коэффициент (допустимое отклонение), см
  final double gabarit;      // ⚠️ габарит кучности, см

  Weapon({
    required this.type,
    required this.name,
    required this.verticalCoefficient,
    required this.horizontalCoefficient,
    required this.maxDeviation,
    required this.gabarit,
  });
}

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор СТП',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Color(0xFF1B2A1B),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2D4A2D),
          elevation: 0,
        ),
      ),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final List<Weapon> weapons = [
    Weapon(
      type: WeaponType.ak74,
      name: 'АК-74',
      verticalCoefficient: 20.0,
      horizontalCoefficient: 26.0,
      maxDeviation: 5.0,  // ⚠️ ЗАМЕНИТЕ на ваше значение
      gabarit: 15.0,      // ⚠️ ЗАМЕНИТЕ на ваше значение
    ),
    Weapon(
      type: WeaponType.svd,
      name: 'СВД',
      verticalCoefficient: 16.0,
      horizontalCoefficient: 16.0,
      maxDeviation: 3.0,  // ⚠️ ЗАМЕНИТЕ на ваше значение
      gabarit: 8.0,      // ⚠️ ЗАМЕНИТЕ на ваше значение
    ),
    Weapon(
      type: WeaponType.rpk74,
      name: 'РПК-74',
      verticalCoefficient: 14.0,
      horizontalCoefficient: 18.0,
      maxDeviation: 5.0,  // ⚠️ ЗАМЕНИТЕ на ваше значение
      gabarit: 15.0,      // ⚠️ ЗАМЕНИТЕ на ваше значение
    ),
  ];

  // 0 - выбор оружия, 1 - ввод отклонений, 2 - результат
  int step = 0;
  Weapon? selectedWeapon;

  final TextEditingController horizontalController = TextEditingController();
  final TextEditingController verticalController = TextEditingController();

  HDir hDir = HDir.right;
  VDir vDir = VDir.up;

  double? verticalResult;   // оборота
  double? horizontalResult; // миллиметров
  double? distance;         // дистанция СТП от начала координат
  bool? satisfactory;       // кучность удовлетворительная?

  bool get _horizontalValid =>
      horizontalController.text.isNotEmpty &&
      double.tryParse(horizontalController.text) != null;

  bool get _verticalValid =>
      verticalController.text.isNotEmpty &&
      double.tryParse(verticalController.text) != null;

  bool get _bothValid => _horizontalValid && _verticalValid;

  @override
  void dispose() {
    horizontalController.dispose();
    verticalController.dispose();
    super.dispose();
  }

  // Формат числа: 15.0 -> "15", 12.5 -> "12.5"
  String _fmt(double x) =>
      x == x.roundToDouble() ? x.toInt().toString() : x.toString();

  void _calculate() {
    if (selectedWeapon == null) return;
    final h = double.tryParse(horizontalController.text) ?? 0;
    final v = double.tryParse(verticalController.text) ?? 0;

    setState(() {
      // Независимая формула: расстояние от точки СТП до начала координат
      distance = sqrt(v * v + h * h);

      // Сравнение с ограничительным коэффициентом
      satisfactory = distance! <= selectedWeapon!.maxDeviation;

      // Расчёты второго этапа (показываются, если кучность НЕ удовлетворительная)
      verticalResult = v / selectedWeapon!.verticalCoefficient;
      horizontalResult = h / selectedWeapon!.horizontalCoefficient;

      step = 2;
    });
  }

  void _restart() {
    setState(() {
      step = 0;
      selectedWeapon = null;
      horizontalController.clear();
      verticalController.clear();
      hDir = HDir.right;
      vDir = VDir.up;
      verticalResult = null;
      horizontalResult = null;
      distance = null;
      satisfactory = null;
    });
  }

  // ---------- Вспомогательные элементы ----------

  Widget _stepIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            return Container(
              width: 12,
              height: 12,
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= step ? Colors.green : Colors.white24,
              ),
            );
          }),
        ),
        SizedBox(height: 8),
        Text(
          'Шаг ${step + 1} из 3',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }

  Widget _inputField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: Colors.white, fontSize: 20),
      textAlign: TextAlign.center,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Color(0xFF2D4A2D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _choiceButton(String label, bool selected, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? Colors.green : Color(0xFF2D4A2D),
        padding: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _nextButton(String text, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade700,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  Widget _backButton(VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white70,
        side: BorderSide(color: Colors.green.shade700),
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text('Назад', style: TextStyle(fontSize: 16)),
    );
  }

  // Дробь: числитель / знаменатель крупным шрифтом
  Widget _fraction(String numerator, String denominator) {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            numerator,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Container(
            height: 3,
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 6),
          ),
          Text(
            denominator,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ---------- Экраны этапов ----------

  // ШАГ 1: выбор оружия
  Widget _buildWeaponStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Выберите вид оружия',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        ...weapons.map((w) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () => setState(() => selectedWeapon = w),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedWeapon == w ? Colors.green : Color(0xFF2D4A2D),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  w.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: selectedWeapon == w ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            )),
        SizedBox(height: 16),
        _nextButton('Далее', selectedWeapon == null ? null : () => setState(() => step = 1)),
      ],
    );
  }

  // ШАГ 2: ввод отклонений с направлениями
  Widget _buildInputStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Введите отклонения СТП',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Оружие: ${selectedWeapon!.name}',
          style: TextStyle(color: Colors.white54, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        // Пункт 1: горизонталь + влево/вправо
        Text(
          'Введите отклонение СТП по горизонтали',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _choiceButton(
                'влево',
                hDir == HDir.left,
                () => setState(() => hDir = HDir.left),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _choiceButton(
                'вправо',
                hDir == HDir.right,
                () => setState(() => hDir = HDir.right),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        _inputField(horizontalController, 'Например: 32'),
        SizedBox(height: 20),
        // Пункт 2: вертикаль + вверх/вниз
        Text(
          'Введите отклонение СТП по вертикали',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _choiceButton(
                'вверх',
                vDir == VDir.up,
                () => setState(() => vDir = VDir.up),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _choiceButton(
                'вниз',
                vDir == VDir.down,
                () => setState(() => vDir = VDir.down),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        _inputField(verticalController, 'Например: 40'),
        SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _backButton(() => setState(() => step = 0))),
            SizedBox(width: 12),
            Expanded(child: _nextButton('Рассчитать', _bothValid ? _calculate : null)),
          ],
        ),
      ],
    );
  }

  // ШАГ 3: результат
  Widget _buildResultStep() {
    final w = selectedWeapon!;

    // Числитель дроби: П/Л + цифра горизонтали + +/- + цифра вертикали
    final letter = hDir == HDir.right ? 'П' : 'Л';
    final sign = vDir == VDir.up ? '+' : '-';
    final numerator =
        '$letter${horizontalController.text.trim()}$sign${verticalController.text.trim()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Результат',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Оружие: ${w.name}',
          style: TextStyle(color: Colors.white54, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),

        if (satisfactory == true) ...[
          // КУЧНОСТЬ УДОВЛЕТВОРИТЕЛЬНАЯ
          Text(
            'Кучность боя удовлетворительная, произведите запись ниже в карточку учёта состояния оружия (Ф н 15-арт)',
            style: TextStyle(fontSize: 17, color: Colors.white, height: 1.4),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 28),
          Center(
            child: _fraction(numerator, _fmt(w.gabarit)),
          ),
        ] else ...[
          // КУЧНОСТЬ НЕ УДОВЛЕТВОРИТЕЛЬНАЯ
          Text(
            'Кучность боя не удовлетворительная, произведите следующие изменения в прицельное приспособление',
            style: TextStyle(fontSize: 17, color: Colors.white, height: 1.4),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF2D4A2D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade700, width: 1),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      verticalResult!.toStringAsFixed(2),
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text('оборота', style: TextStyle(fontSize: 18, color: Colors.white70)),
                  ],
                ),
                SizedBox(height: 15),
                Divider(color: Colors.white24),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      horizontalResult!.toStringAsFixed(2),
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text('миллиметров', style: TextStyle(fontSize: 18, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
        ],

        SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _backButton(() => setState(() => step = 1))),
            SizedBox(width: 12),
            Expanded(child: _nextButton('Начать заново', _restart)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Калькулятор поправок', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _stepIndicator(),
                SizedBox(height: 24),
                if (step == 0) _buildWeaponStep(),
                if (step == 1) _buildInputStep(),
                if (step == 2) _buildResultStep(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

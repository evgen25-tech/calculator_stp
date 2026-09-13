import 'package:flutter/material.dart';
import 'dart:math';

// Типы оружия
enum WeaponType { ak74, svd, rpk74, pm, pya, aps, aks74u, akm, rpk, pk, aс }

// Направления отклонений
enum HDir { left, right }
enum VDir { down, up }

// Модель оружия с коэффициентами пересчёта
class Weapon {
  final WeaponType type;
  final String name;
  final double verticalCoefficient;   // см на 1 оборот (винтовки) / см на 1 номер целика (пистолеты)
  final double horizontalCoefficient; // см на 1 мм смещения
  final double maxDeviation; // ограничительный коэффициент (допустимое отклонение), см
  final double gabarit;      // габарит кучности, см
  final bool isPistol;       // пистолетный поток этапов (5 этапов)

  Weapon({
    required this.type,
    required this.name,
    required this.verticalCoefficient,
    required this.horizontalCoefficient,
    required this.maxDeviation,
    required this.gabarit,
    this.isPistol = false,
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
      maxDeviation: 5.0,
      gabarit: 15.0,
    ),
    Weapon(
      type: WeaponType.svd,
      name: 'СВД',
      verticalCoefficient: 16.0,
      horizontalCoefficient: 16.0,
      maxDeviation: 3.0,
      gabarit: 8.0,
    ),
    Weapon(
      type: WeaponType.rpk74,
      name: 'РПК-74',
      verticalCoefficient: 14.0,
      horizontalCoefficient: 18.0,
      maxDeviation: 5.0,
      gabarit: 15.0,
    ),
    Weapon(
      type: WeaponType.pm,
      name: 'ПМ',
      verticalCoefficient: 10.0,  // ⚠️ ЗАМЕНИТЕ: см на 1 номер целика
      horizontalCoefficient: 10.0,// ⚠️ ЗАМЕНИТЕ: см на 1 мм смещения
      maxDeviation: 5.0,          // ⚠️ ЗАМЕНИТЕ
      gabarit: 10.0,              // ⚠️ ЗАМЕНИТЕ
      isPistol: true,
    ),
    Weapon(
      type: WeaponType.pya,
      name: 'ПЯ',
      verticalCoefficient: 10.0,  // ⚠️ ЗАМЕНИТЕ: см на 1 номер целика
      horizontalCoefficient: 10.0,// ⚠️ ЗАМЕНИТЕ: см на 1 мм смещения
      maxDeviation: 5.0,          // ⚠️ ЗАМЕНИТЕ
      gabarit: 10.0,              // ⚠️ ЗАМЕНИТЕ
      isPistol: true,
    ),
    Weapon(
      type: WeaponType.aps,
      name: 'АПС',
      verticalCoefficient: 10.0,  // ⚠️ ЗАМЕНИТЕ: см на 1 номер целика
      horizontalCoefficient: 10.0,// ⚠️ ЗАМЕНИТЕ: см на 1 мм смещения
      maxDeviation: 5.0,          // ⚠️ ЗАМЕНИТЕ
      gabarit: 10.0,              // ⚠️ ЗАМЕНИТЕ
      isPistol: true,
    ),
    Weapon(
      type: WeaponType.aks74u,
      name: 'АКС-74У',
      verticalCoefficient: 10.0,   // ⚠️ заглушка
      horizontalCoefficient: 10.0, // ⚠️ заглушка
      maxDeviation: 5.0,           // ⚠️ заглушка
      gabarit: 15.0,               // ⚠️ заглушка
    ),
    Weapon(
      type: WeaponType.akm,
      name: 'АКМ',
      verticalCoefficient: 10.0,   // ⚠️ заглушка
      horizontalCoefficient: 10.0, // ⚠️ заглушка
      maxDeviation: 5.0,           // ⚠️ заглушка
      gabarit: 15.0,               // ⚠️ заглушка
    ),
    Weapon(
      type: WeaponType.rpk,
      name: 'РПК',
      verticalCoefficient: 10.0,   // ⚠️ заглушка
      horizontalCoefficient: 10.0, // ⚠️ заглушка
      maxDeviation: 5.0,           // ⚠️ заглушка
      gabarit: 15.0,               // ⚠️ заглушка
    ),
    Weapon(
      type: WeaponType.pk,
      name: 'ПК',
      verticalCoefficient: 10.0,   // ⚠️ заглушка
      horizontalCoefficient: 10.0, // ⚠️ заглушка
      maxDeviation: 5.0,           // ⚠️ заглушка
      gabarit: 15.0,               // ⚠️ заглушка
    ),
    Weapon(
      type: WeaponType.aс,
      name: 'АС Вал',
      verticalCoefficient: 10.0,   // ⚠️ заглушка
      horizontalCoefficient: 10.0, // ⚠️ заглушка
      maxDeviation: 5.0,           // ⚠️ заглушка
      gabarit: 15.0,               // ⚠️ заглушка
    ),
  ];

  // 0 - оружие, 1 - ввод отклонений, 2 - результат,
  // 3 - горизонтальное изменение (пистолеты), 4 - миллиметры (пистолеты)
  int step = 0;
  Weapon? selectedWeapon;

  final TextEditingController horizontalController = TextEditingController();
  final TextEditingController verticalController = TextEditingController();
  final TextEditingController h4Controller = TextEditingController();

  HDir hDir = HDir.right;
  VDir vDir = VDir.up;
  HDir hDir4 = HDir.right;

  double? verticalResult;   // оборота (винтовки)
  double? horizontalResult; // миллиметры (винтовки)
  double? distance;
  bool? satisfactory;

  bool get _horizontalValid =>
      horizontalController.text.isNotEmpty &&
      double.tryParse(horizontalController.text) != null;

  bool get _verticalValid =>
      verticalController.text.isNotEmpty &&
      double.tryParse(verticalController.text) != null;

  bool get _bothValid => _horizontalValid && _verticalValid;

  bool get _h4Valid =>
      h4Controller.text.isNotEmpty &&
      double.tryParse(h4Controller.text) != null;

  bool get _isPistol => selectedWeapon != null && selectedWeapon!.isPistol;

  @override
  void dispose() {
    horizontalController.dispose();
    verticalController.dispose();
    h4Controller.dispose();
    super.dispose();
  }

  String _fmt(double x) =>
      x == x.roundToDouble() ? x.toInt().toString() : x.toString();

  int _totalSteps() {
    if (step >= 3) return 5;
    if (step == 2 && satisfactory == false && _isPistol) return 5;
    return 3;
  }

  void _calculate() {
    if (selectedWeapon == null) return;
    final h = double.tryParse(horizontalController.text) ?? 0;
    final v = double.tryParse(verticalController.text) ?? 0;

    setState(() {
      distance = sqrt(v * v + h * h);
      satisfactory = distance! <= selectedWeapon!.maxDeviation;
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
      h4Controller.clear();
      hDir = HDir.right;
      vDir = VDir.up;
      hDir4 = HDir.right;
      verticalResult = null;
      horizontalResult = null;
      distance = null;
      satisfactory = null;
    });
  }

  // ---------- Вспомогательные элементы ----------

  Widget _stepIndicator() {
    final total = _totalSteps();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(total, (i) {
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
          'Шаг ${step + 1} из $total',
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

  Widget _directionRow(HDir value, ValueChanged<HDir> onChanged) {
    return Row(
      children: [
        Expanded(
          child: _choiceButton(
            'влево',
            value == HDir.left,
            () => onChanged(HDir.left),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _choiceButton(
            'вправо',
            value == HDir.right,
            () => onChanged(HDir.right),
          ),
        ),
      ],
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

  Widget _resultContainer(List<Widget> rows) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2D4A2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade700, width: 1),
      ),
      child: Column(children: rows),
    );
  }

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
        Text(
          'Введите отклонение СТП по горизонтали',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        SizedBox(height: 8),
        _directionRow(hDir, (d) => setState(() => hDir = d)),
        SizedBox(height: 8),
        _inputField(horizontalController, 'Например: 32'),
        SizedBox(height: 20),
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

    // Пистолеты: на сколько номеров целика заменить
    final v = double.tryParse(verticalController.text) ?? 0;
    final sightDelta = (v / w.verticalCoefficient).round();
    final sightWord = vDir == VDir.up ? 'меньше' : 'больше';

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
          // КУЧНОСТЬ УДОВЛЕТВОРИТЕЛЬНАЯ (все оружия)
          Text(
            'Кучность боя удовлетворительная, произведите запись ниже в карточку учёта состояния оружия (Ф н 15-арт)',
            style: TextStyle(fontSize: 17, color: Colors.white, height: 1.4),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 28),
          Center(
            child: _fraction(numerator, _fmt(w.gabarit)),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _backButton(() => setState(() => step = 1))),
              SizedBox(width: 12),
              Expanded(child: _nextButton('Начать заново', _restart)),
            ],
          ),
        ] else if (!w.isPistol) ...[
          // НЕУДОВЛЕТВОРИТЕЛЬНАЯ: ВИНТОВКИ (обороты + миллиметры)
          Text(
            'Кучность боя не удовлетворительная, произведите следующие изменения в прицельное приспособление',
            style: TextStyle(fontSize: 17, color: Colors.white, height: 1.4),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          _resultContainer([
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                vDir == VDir.up ? 'выкрутить' : 'вкрутить',
                style: TextStyle(fontSize: 15, color: Colors.white70),
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  verticalResult!.toStringAsFixed(2),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text('оборота(ов)', style: TextStyle(fontSize: 18, color: Colors.white70)),
              ],
            ),
            SizedBox(height: 15),
            Divider(color: Colors.white24),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                hDir == HDir.left ? 'сдвинуть влево' : 'сдвинуть вправо',
                style: TextStyle(fontSize: 15, color: Colors.white70),
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  horizontalResult!.toStringAsFixed(2),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text('миллиметра(ов)', style: TextStyle(fontSize: 18, color: Colors.white70)),
              ],
            ),
          ]),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _backButton(() => setState(() => step = 1))),
              SizedBox(width: 12),
              Expanded(child: _nextButton('Начать заново', _restart)),
            ],
          ),
        ] else ...[
          // НЕУДОВЛЕТВОРИТЕЛЬНАЯ: ПИСТОЛЕТЫ (только вертикаль, целик)
          Text(
            'Кучность боя не удовлетворительная, произведите следующие изменения в прицельное приспособление',
            style: TextStyle(fontSize: 17, color: Colors.white, height: 1.4),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          _resultContainer([
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'замените целик на',
                style: TextStyle(fontSize: 15, color: Colors.white70),
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$sightDelta',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(sightWord, style: TextStyle(fontSize: 18, color: Colors.white70)),
              ],
            ),
          ]),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _backButton(() => setState(() => step = 1))),
              SizedBox(width: 12),
              Expanded(
                child: _nextButton('Далее', () => setState(() {
                      hDir4 = hDir;
                      step = 3;
                    })),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ШАГ 4 (пистолеты): ввод горизонтального изменения
  Widget _buildHorizontalFixStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Введите горизонтальное изменение',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Оружие: ${selectedWeapon!.name}',
          style: TextStyle(color: Colors.white54, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        _directionRow(hDir4, (d) => setState(() => hDir4 = d)),
        SizedBox(height: 8),
        _inputField(h4Controller, 'Например: 12'),
        SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _backButton(() => setState(() => step = 2))),
            SizedBox(width: 12),
            Expanded(
              child: _nextButton(
                'Рассчитать',
                _h4Valid ? () => setState(() => step = 4) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ШАГ 5 (пистолеты): результат в миллиметрах
  Widget _buildMillimeterStep() {
    final w = selectedWeapon!;
    final h4 = double.tryParse(h4Controller.text) ?? 0;
    final mm = h4 / w.horizontalCoefficient;

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
        _resultContainer([
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              hDir4 == HDir.left ? 'сдвинуть вправо' : 'сдвинуть влево',
              style: TextStyle(fontSize: 15, color: Colors.white70),
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mm.toStringAsFixed(2),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text('миллиметра(ов)', style: TextStyle(fontSize: 18, color: Colors.white70)),
            ],
          ),
        ]),
        SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _backButton(() => setState(() => step = 3))),
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
                if (step == 3) _buildHorizontalFixStep(),
                if (step == 4) _buildMillimeterStep(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

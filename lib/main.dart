import 'package:flutter/material.dart';

// Типы оружия
enum WeaponType { ak74, svd, rpk74 }

// Модель оружия с коэффициентами пересчёта
class Weapon {
  final WeaponType type;
  final String name;
  final double verticalCoefficient;   // см в 1 оборот маховика по вертикали
  final double horizontalCoefficient; // см в 1 мм боковой поправки
  
  Weapon({
    required this.type,
    required this.name,
    required this.verticalCoefficient,
    required this.horizontalCoefficient,
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
  // Список оружия с исправленными коэффициентами
  final List<Weapon> weapons = [
    Weapon(
      type: WeaponType.ak74,
      name: 'АК-74',
      verticalCoefficient: 20.0,   // 1 оборот = 20 см
      horizontalCoefficient: 26.0, // 1 мм = 26 см
    ),
    Weapon(
      type: WeaponType.svd,
      name: 'СВД',
      verticalCoefficient: 16.0,   // 1 оборот = 16 см
      horizontalCoefficient: 16.0, // 1 мм = 16 см
    ),
    Weapon(
      type: WeaponType.rpk74,
      name: 'РПК-74',
      verticalCoefficient: 14.0,   // 1 оборот = 14 см
      horizontalCoefficient: 18.0, // 1 мм = 18 см
    ),
  ];

  Weapon? selectedWeapon;
  final TextEditingController verticalController = TextEditingController();
  final TextEditingController horizontalController = TextEditingController();
  
  double? verticalResult;
  double? horizontalResult;

  @override
  void dispose() {
    verticalController.dispose();
    horizontalController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (selectedWeapon == null) return;

    final verticalValue = double.tryParse(verticalController.text) ?? 0;
    final horizontalValue = double.tryParse(horizontalController.text) ?? 0;

    setState(() {
      // Формула: обороты/мм = отклонение / коэффициент
      verticalResult = verticalValue / selectedWeapon!.verticalCoefficient;
      horizontalResult = horizontalValue / selectedWeapon!.horizontalCoefficient;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Калькулятор поправок', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Заголовок
            Text(
              'Выберите вид оружия',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Панель выбора оружия
            Row(
              children: weapons.map((weapon) {
                final isSelected = selectedWeapon == weapon;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedWeapon = weapon;
                          verticalResult = null;
                          horizontalResult = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.green : Color(0xFF2D4A2D),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        weapon.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 30),

            // Поля ввода
            if (selectedWeapon != null) ...[
              Text(
                'Введите отклонение СТП по вертикали',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 8),
              TextField(
                controller: verticalController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Например: 5',
                  hintStyle: TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Color(0xFF2D4A2D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 20),

              Text(
                'Введите отклонение СТП по горизонтали',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 8),
              TextField(
                controller: horizontalController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Например: 3',
                  hintStyle: TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Color(0xFF2D4A2D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 25),

              ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Рассчитать',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),

              SizedBox(height: 25),

              // Результаты
              if (verticalResult != null && horizontalResult != null)
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFF2D4A2D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade700, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            verticalResult!.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'оборота',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
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
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'миллиметров',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

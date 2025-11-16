import 'package:flutter/material.dart';
import 'package:life_network/services/mining_service.dart';

class MiningScreen extends StatefulWidget {
  const MiningScreen({super.key});

  @override
  State<MiningScreen> createState() => _MiningScreenState();
}

class _MiningScreenState extends State<MiningScreen> {
  final MiningService _miningService = MiningService();

  int coins = 0;
  bool canMine = false;
  DateTime? lastMineTime;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    coins = await _miningService.getCoins();
    canMine = await _miningService.canMineNow();
    lastMineTime = await _miningService.getLastMiningTime();
    setState(() {});
  }

  String remainingTime() {
    if (lastMineTime == null) return "You can mine now!";
    final diff = DateTime.now().difference(lastMineTime!).inHours;
    final remain = 24 - diff;
    if (remain <= 0) return "You can mine now!";
    return "$remain hours remaining";
  }

  Future<void> startMining() async {
    bool success = await _miningService.mineCoins();
    await loadData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Mining started! You earned 10 LN coins"
              : "Please wait 24 hours",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LIFE NETWORK Mining"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Your Balance",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "$coins LN",
              style: const TextStyle(fontSize: 40, color: Colors.purple),
            ),
            const SizedBox(height: 30),
            Text(
              remainingTime(),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: canMine ? startMining : null,
              child: const Text(
                "START MINING",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

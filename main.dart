
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio/just_audio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Google Mobile Ads SDK (placeholder)
  MobileAds.instance.initialize();
  runApp(LifeNetworkApp());
}

class LifeNetworkApp extends StatefulWidget {
  @override
  _LifeNetworkAppState createState() => _LifeNetworkAppState();
}

class _LifeNetworkAppState extends State<LifeNetworkApp> {
  final String admobAppId = 'ADMOB_APP_ID_PLACEHOLDER';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIFE NETWORK',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _balance = 0.0;
  int _cooldownSec = 0;
  String _username = '';
  String _referral = '';
  Timer? _timer;
  late SharedPreferences _prefs;
  final int cooldownSecondsDefault = 3600; // demo 1 hour; change to 86400 for 24h in production

  // AdMob banner placeholder variables
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _loadState();
    _startTick();
    _loadBannerAd();
    _prepareAudio();
  }

  Future<void> _prepareAudio() async {
    try {
      // This will attempt to load assets/audio/arabic_bg.mp3
      await _audioPlayer.setAsset('assets/audio/arabic_bg.mp3');
      _audioPlayer.setLoopMode(LoopMode.one);
    } catch (e) {
      // If asset not found, ignore for demo
    }
  }

  void _toggleAudio() async {
    if (_isPlayingAudio) {
      await _audioPlayer.pause();
      setState(() => _isPlayingAudio = false);
    } else {
      try {
        await _audioPlayer.play();
        setState(() => _isPlayingAudio = true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ba a samu audio ba. Ka saka assets/audio/arabic_bg.mp3')));
      }
    }
  }

  void _loadBannerAd() {
    // Replace AD_UNIT_BANNER_PLACEHOLDER with your real Ad Unit ID
    _bannerAd = BannerAd(
      adUnitId: 'AD_UNIT_BANNER_PLACEHOLDER',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(onAdLoaded: (_) {
        setState(() => _isBannerLoaded = true);
      }, onAdFailedToLoad: (ad, err) {
        ad.dispose();
      }),
    );
    _bannerAd?.load();
  }

  void _startTick() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (_cooldownSec > 0) {
        setState(() => _cooldownSec--);
        _saveCooldown();
      }
    });
  }

  Future<void> _loadState() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _balance = _prefs.getDouble('balance') ?? 0.0;
      _cooldownSec = _prefs.getInt('cooldown') ?? 0;
      _username = _prefs.getString('username') ?? '';
      _referral = _prefs.getString('referral') ?? '';
    });
  }

  Future<void> _saveState() async {
    await _prefs.setDouble('balance', _balance);
    await _prefs.setInt('cooldown', _cooldownSec);
    await _prefs.setString('username', _username);
    await _prefs.setString('referral', _referral);
  }

  Future<void> _saveCooldown() async {
    await _prefs.setInt('cooldown', _cooldownSec);
  }

  void _mineNow() {
    if (_cooldownSec > 0) return;
    double reward = (Random().nextDouble() * 0.5) + 0.1;
    reward = double.parse(reward.toStringAsFixed(4));
    setState(() {
      _balance += reward;
      _cooldownSec = cooldownSecondsDefault;
    });
    _saveState();
    if (_referral.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An tura lada ga wanda ya turo maka: $_referral (demo).'),
      ));
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Ka kama coins $reward. Sabon balance: ${_balance.toStringAsFixed(4)}'),
    ));
  }

  void _resetData() async {
    await _prefs.clear();
    setState(() {
      _balance = 0.0;
      _cooldownSec = 0;
      _username = '';
      _referral = '';
    });
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return 'A shirye';
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerAd?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LIFE NETWORK'),
        actions: [
          IconButton(icon: Icon(Icons.volume_up), onPressed: _toggleAudio),
          IconButton(icon: Icon(Icons.settings), onPressed: _openSettings),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 6,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green[50],
                      ),
                      child: Center(child: Text('Hoton masallaci / gefen titi - canza asset din nan')),
                    ),
                    SizedBox(height: 12),
                    Text('Sannu ${_username.isEmpty ? 'Mai amfani' : _username}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('Balance: ${_balance.toStringAsFixed(4)} LIFE', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.bolt),
              label: Text(_cooldownSec > 0 ? 'Bako yanzu (Cooldown)' : 'Fara Mining'),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
              onPressed: _cooldownSec > 0 ? null : _mineNow,
            ),
            SizedBox(height: 8),
            Text('Next: ${_formatDuration(_cooldownSec)}'),
            SizedBox(height: 18),
            if (_isBannerLoaded && _bannerAd != null)
              Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              )
            else
              SizedBox(height: 50),
            SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text('Referral code'),
                subtitle: Text(_referral.isEmpty ? 'Ba ka shigar da code ba' : _referral),
                trailing: IconButton(icon: Icon(Icons.share), onPressed: _shareReferral),
              ),
            ),
            SizedBox(height: 12),
            Expanded(child: _buildActivityBox()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(icon: Icon(Icons.delete_forever), label: Text('Sake saita'), onPressed: () => _confirmReset()),
                TextButton.icon(icon: Icon(Icons.info_outline), label: Text('Game da'), onPressed: _showAbout),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActivityBox() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Ayyuka (Demo):', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('• Tap \"Fara Mining\" don samun coins. (Demo reward random)\\n• Shigar da referral code a Settings don karbar lada.\\n• Wannan app din demo ne — don ainihin amfani, kana bukatar backend da tsaro.'),
        ]),
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet(context: context, builder: (_) {
      TextEditingController userCtrl = TextEditingController(text: _username);
      TextEditingController refCtrl = TextEditingController(text: _referral);
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Saituna', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(controller: userCtrl, decoration: InputDecoration(labelText: 'Suna (username)')),
              TextField(controller: refCtrl, decoration: InputDecoration(labelText: 'Referral code (idan akwai)')),
              SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Soke')),
                ElevatedButton(onPressed: () {
                  setState(() {
                    _username = userCtrl.text.trim();
                    _referral = refCtrl.text.trim();
                  });
                  _saveState();
                  Navigator.pop(context);
                }, child: Text('Ajiye')),
              ]),
            ],
          ),
        ),
      );
    });
  }

  void _shareReferral() {
    if (_username.isEmpty && _referral.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Da fatan ka saita username ko referral a Settings.')));
      return;
    }
    String code = _referral.isNotEmpty ? _referral : (_username.isNotEmpty ? _username : 'user_demo');
    showDialog(context: context, builder: (_) => AlertDialog(title: Text('Raba referral'), content: SelectableText('https://life-network.example/invite?ref=$code\\n(Share this link — demo)'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Ok'))],));
  }

  void _confirmReset() {
    showDialog(context: context, builder: (_) => AlertDialog(title: Text('Tabbatar'), content: Text('Kuna son share duk bayanai na gida (local data)?'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('A'a')), ElevatedButton(onPressed: () { _resetData(); Navigator.pop(context); }, child: Text('Ee')),],));
  }

  void _showAbout() {
    showDialog(context: context, builder: (_) => AlertDialog(title: Text('Game da LIFE NETWORK'), content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Wannan app din demo ne na \"mining\" kamar Pi Network.'), SizedBox(height:8), Text('Abubuwan dake ciki (features):'), Text('• Local balance storage (shared_preferences)'), Text('• Mining action with cooldown'), Text('• Referral field and shareable invite link (demo)'), Text('• AdMob placeholders (google_mobile_ads)'), Text('• Arabic background audio support (just_audio)'), SizedBox(height:8), Text('Lura: Don gina aiyuka na gaske, ya kamata ka hada backend (server) don adana asusun masu amfani, tabbatarwa, da tsaro. Hakanan zaka bukaci tsarin KYC idan ka yanke shawarar mayar da coins kudi.'),],)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Rufe'))],));
  }
}


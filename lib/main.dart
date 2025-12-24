import 'package:brasil_crypto/core/dependency_injection/dependency_injector.dart';
import 'package:brasil_crypto/core/utils/currency_formatter.dart';
import 'package:brasil_crypto/ui/cubit/exchange_rate_cubit.dart';
import 'package:brasil_crypto/ui/pages/favorite_crypto_page.dart';
import 'package:brasil_crypto/ui/pages/search_crypto_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjector.load();

  // Fetch exchange rate on app startup
  final exchangeRateCubit = DependencyInjector.get<ExchangeRateCubit>();
  await exchangeRateCubit.fetchExchangeRate();

  SemanticsBinding.instance.ensureSemantics();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrasilCrypto',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.amber,
          secondary: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => DependencyInjector.get<ExchangeRateCubit>(),
        child: BlocListener<ExchangeRateCubit, ExchangeRateState>(
          listener: (context, state) {
            if (state is ExchangeRateLoadedState) {
              CurrencyFormatter.setExchangeRate(state.rate);
            }
          },
          child: const MainPage(),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[SearchCryptoPage(), FavoriteCryptoPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

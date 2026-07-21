import 'package:flutter/material.dart';
import 'add_book_tab.dart';
import 'library_tab.dart';
import 'info_tab.dart';

class MainTabsContainer extends StatefulWidget {
  const MainTabsContainer({super.key});

  @override
  State<MainTabsContainer> createState() => _MainTabsContainerState();
}

class _MainTabsContainerState extends State<MainTabsContainer> {
  int _currentIndex = 0;
  final GlobalKey<LibraryTabState> _libraryKey = GlobalKey<LibraryTabState>();

  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      AddBookTab(onBookAdded: () {
        // Trigger library reload when a book is successfully added
        _libraryKey.currentState?.carregarLivros();
      }),
      LibraryTab(key: _libraryKey),
      const InfoTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Adicionar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'Biblioteca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            activeIcon: Icon(Icons.info),
            label: 'Informações',
          ),
        ],
      ),
    );
  }
}

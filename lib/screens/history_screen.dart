import 'package:flutter/material.dart';
import 'package:flutter_proje/models/history.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Box<History> _historyBox;
  List<History> _selectedItems = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _historyBox = Hive.box<History>('historyBox');
  }

  Future<void> _deleteAllHistory() async {
    await _historyBox.clear();
    setState(() {});
  }

  Future<void> _deleteSelectedItems() async {
    for (var item in _selectedItems) {
      final key =
          _historyBox.keys.firstWhere((k) => _historyBox.get(k) == item);
      await _historyBox.delete(key);
    }
    setState(() {
      _selectedItems.clear();
      _isSelectionMode = false;
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedItems.clear();
    });
  }

  void _toggleSelection(History item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Silme Onayı'),
          content: Text('Seçili kayıtları silmek istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Hayır'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Evet'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteSelectedItems();
    }
  }

  Future<void> _showClearConfirmationDialog() async {
    final bool? shouldClear = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Temizleme Onayı'),
          content: Text('Tüm geçmişi silmek istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Hayır'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Evet'),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      await _deleteAllHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş'),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: _toggleSelectionMode,
            ),
          if (!_isSelectionMode)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _toggleSelectionMode,
            ),
        ],
      ),
      body: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: _historyBox.listenable(),
            builder: (context, Box<History> box, widget) {
              final histories = box.values.toList().cast<History>();

              // Verileri ters çeviriyoruz
              final reversedHistories = histories.reversed.toList();

              return ListView.builder(
                itemCount: reversedHistories.length,
                itemBuilder: (context, index) {
                  final history = reversedHistories[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12.0),
                      title: Text(
                        history.description,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            'Kullanıcı: ${history.username}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            'Tarih: ${history.timestamp.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            'Saat: ${history.timestamp.toLocal().toString().split(' ')[1].split('.')[0]}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      leading: _isSelectionMode
                          ? Checkbox(
                              value: _selectedItems.contains(history),
                              onChanged: (bool? checked) {
                                _toggleSelection(history);
                              },
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          ),
          if (_isSelectionMode)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _showClearConfirmationDialog,
                        child: const Text('Tüm Geçmişi Sil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 164, 11, 0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _showDeleteConfirmationDialog,
                        child: const Text('Seçili Kayıtları Sil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 9, 145, 113),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

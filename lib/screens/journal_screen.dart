import 'package:aura_safe_app/models/journal_entry_model.dart';
import 'package:aura_safe_app/services/journal_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:line_icons/line_icons.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _entryController = TextEditingController();
  final JournalService _journalService = JournalService();

  // --- 24.2: Record Reflection ---
  void _saveReflection() {
    if (_entryController.text.trim().isEmpty) return;
    _journalService.addJournalEntry(_entryController.text.trim());
    _entryController.clear(); // Clear the text field
    FocusScope.of(context).unfocus(); // Hide keyboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reflection saved.'), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- 24.2: Input Area ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _entryController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                suffixIcon: IconButton(
                  icon: const Icon(LineIcons.paperPlane, color: Colors.cyanAccent),
                  onPressed: _saveReflection,
                  tooltip: 'Save Reflection',
                ),
              ),
            ),
          ),
          const Divider(color: Colors.white24),

          // --- 24.3: List Area ---
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text('Past Reflections', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<List<JournalEntry>>(
              stream: _journalService.getJournalEntriesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No reflections saved yet.', style: TextStyle(color: Colors.white70)));
                }

                final entries = snapshot.data!;
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return ListTile(
                      leading: const Icon(LineIcons.bookOpen, color: Colors.cyanAccent),
                      title: Text(
                        entry.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        // Format the timestamp
                        DateFormat('MMM d, yyyy - h:mm a').format(entry.timestamp.toDate()),
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _journalService.deleteJournalEntry(entry.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
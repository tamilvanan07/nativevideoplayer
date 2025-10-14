import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'logger_file.dart';

class LoggerPage extends StatefulWidget {
  const LoggerPage({Key? key}) : super(key: key);

  @override
  State<LoggerPage> createState() => _LoggerPageState();
}

class _LoggerPageState extends State<LoggerPage> {
  final AppLogger _logger = AppLogger();
  List<LogEntry> _filteredLogs = [];
  LogLevel? _selectedLevel;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateFilteredLogs();
  }

  void _updateFilteredLogs() {
    List<LogEntry> logs = _logger.logs;

    // Filter by level if selected
    if (_selectedLevel != null) {
      logs = logs.where((log) => log.level == _selectedLevel).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      logs = _logger.searchLogs(_searchQuery);
      if (_selectedLevel != null) {
        logs = logs.where((log) => log.level == _selectedLevel).toList();
      }
    }

    // Sort by timestamp (newest first)
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    setState(() {
      _filteredLogs = logs;
    });
  }

  void _clearLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Logs'),
        content: const Text('Are you sure you want to clear all logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _logger.clear();
              _updateFilteredLogs();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logs cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _exportLogs() {
    final exportData = _logger.exportLogs();
    Clipboard.setData(ClipboardData(text: exportData));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs copied to clipboard')),
    );
  }

  void _showLogDetails(LogEntry log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${log.levelIcon} ${log.tag}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Time: ${log.timestamp.toString()}'),
              const SizedBox(height: 8),
              Text('Level: ${log.level.name.toUpperCase()}'),
              const SizedBox(height: 8),
              Text('Message: ${log.message}'),
              if (log.data != null) ...[
                const SizedBox(height: 8),
                Text('Data: ${log.data}'),
              ],
              if (log.stackTrace != null) ...[
                const SizedBox(height: 8),
                const Text('Stack Trace:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.stackTrace!,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final logText = '''
Time: ${log.timestamp}
Level: ${log.level.name.toUpperCase()}
Tag: ${log.tag}
Message: ${log.message}
${log.data != null ? 'Data: ${log.data}\n' : ''}
${log.stackTrace != null ? 'Stack Trace: ${log.stackTrace}\n' : ''}
              '''.trim();
              Clipboard.setData(ClipboardData(text: logText));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Log details copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Logs (${_filteredLogs.length})'),
        actions: [
          IconButton(
            onPressed: _exportLogs,
            icon: const Icon(Icons.file_copy),
            tooltip: 'Export logs',
          ),
          IconButton(
            onPressed: _clearLogs,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear logs',
          ),
          IconButton(
            onPressed: _updateFilteredLogs,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search logs...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _updateFilteredLogs();
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedLevel == null,
                        onSelected: (selected) {
                          _selectedLevel = selected ? null : _selectedLevel;
                          _updateFilteredLogs();
                        },
                      ),
                      const SizedBox(width: 8),
                      ...LogLevel.values.map((level) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('${LogEntry(
                            timestamp: DateTime.now(),
                            level: level,
                            tag: '',
                            message: '',
                          ).levelIcon} ${level.name.toUpperCase()}'),
                          selected: _selectedLevel == level,
                          onSelected: (selected) {
                            _selectedLevel = selected ? level : null;
                            _updateFilteredLogs();
                          },
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Logs list
          Expanded(
            child: _filteredLogs.isEmpty
                ? const Center(
              child: Text('No logs found'),
            )
                : ListView.builder(
              itemCount: _filteredLogs.length,
              itemBuilder: (context, index) {
                final log = _filteredLogs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Text(
                      log.levelIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    title: Text(
                      log.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${log.tag} • ${log.timestamp.toString().substring(0, 19)}'),
                        if (log.data != null)
                          Text(
                            'Data: ${log.data.toString()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: log.levelColor,
                    ),
                    onTap: () => _showLogDetails(log),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add some sample logs for testing
          _logger.debug('TestTag', 'This is a debug message', data: {'key': 'value'});
          _logger.info('VideoPlayer', 'Video started playing');
          _logger.warning('Network', 'Slow network detected');
          _logger.error('API', 'Failed to fetch data', data: {'error': 'timeout'});
          _logger.critical('System', 'Critical system error', stackTrace: 'Sample stack trace');
          _updateFilteredLogs();
        },
        child: const Icon(Icons.add),
        tooltip: 'Add sample logs',
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/chat_message.dart';
import '../../blocs/campus_ai/campus_ai_bloc.dart';
import '../../blocs/campus_ai/campus_ai_event.dart';
import '../../blocs/campus_ai/campus_ai_state.dart';
import '../../widgets/chat/chat_bubble.dart';
import '../../widgets/chat/chat_input_field.dart';
import '../../widgets/loading_indicator.dart';

class CampusOracleScreen extends StatefulWidget {
  const CampusOracleScreen({Key? key}) : super(key: key);

  @override
  State<CampusOracleScreen> createState() => _CampusOracleScreenState();
}

class _CampusOracleScreenState extends State<CampusOracleScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load conversation history when screen opens
    context.read<CampusAIBloc>().add(LoadConversationHistory());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Oracle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoBottomSheet(context);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _showClearConfirmationDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Clear conversation'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<CampusAIBloc, CampusAIState>(
        listener: (context, state) {
          if (state is CampusAILoaded || state is CampusAISending) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state is CampusAIInitial || state is CampusAILoading) {
            return const Center(child: LoadingIndicator());
          }

          List<ChatMessage> messages = [];
          bool isLoading = false;

          if (state is CampusAILoaded) {
            messages = state.messages;
          } else if (state is CampusAISending) {
            messages = state.messages;
            isLoading = true;
          } else if (state is CampusAIError) {
            messages = state.messages;
            // Show error message
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }

          return Column(
            children: [
              // Messages list
              Expanded(
                child: messages.isEmpty
                    ? const Center(
                        child: Text('No messages yet'),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                          top: 12,
                          bottom: 16,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return ChatBubble(
                            message: messages[index],
                            // Only show time on last message or if messages are more than 10 min apart
                            showTime: index == messages.length - 1 ||
                                (index < messages.length - 1 &&
                                    messages[index + 1]
                                            .timestamp
                                            .difference(
                                              messages[index].timestamp,
                                            )
                                            .inMinutes >
                                        10),
                          );
                        },
                      ),
              ),

              // Input field
              SafeArea(
                child: ChatInputField(
                  isLoading: isLoading,
                  onSendMessage: (message) {
                    context.read<CampusAIBloc>().add(SendMessage(message));
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Campus Oracle',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Campus Oracle is your AI assistant for university information. Ask questions about:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem(
                      icon: Icons.school,
                      title: 'Academics',
                      description:
                          'Course information, academic policies, and study resources',
                    ),
                    _buildInfoItem(
                      icon: Icons.event,
                      title: 'Campus Events',
                      description:
                          'Information about upcoming events, clubs, and activities',
                    ),
                    _buildInfoItem(
                      icon: Icons.map,
                      title: 'Campus Navigation',
                      description:
                          'Help finding buildings, services, and facilities on campus',
                    ),
                    _buildInfoItem(
                      icon: Icons.restaurant,
                      title: 'Dining and Services',
                      description:
                          'Information about dining options, hours, and campus services',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Campus Oracle uses AI to provide helpful information but may occasionally make mistakes. Always verify critical information with official university sources.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation?'),
        content: const Text(
            'This will delete all messages in your conversation with Campus Oracle. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CampusAIBloc>().add(ClearConversation());
            },
            child: const Text('Clear'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

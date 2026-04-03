import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/maintenance_models.dart';
import '../../services/chat_service.dart';
import '../../services/database_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _controller;
  late ChatService _chatService;
  late ScrollController _scrollController;
  final List<ChatMessage> _messages = [];
  String _userMode = 'engineer'; // 'engineer' or 'passenger'

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final db = context.read<DatabaseService>();
    _chatService = ChatService();
    await _chatService.init(db);
    _chatService.userMode = _userMode;

    // Load chat history
    final history = await _chatService.getChatHistory();

    setState(() {
      // Add welcome message if no history exists
      if (history.isEmpty) {
        _messages.add(
          ChatMessage(
            text: 'Hi! I\'m AeroAssistant, your ${_userMode == 'engineer' ? 'Engineering' : 'Aircraft'} AI Assistant. How can I help you today?',
            isUser: false,
          ),
        );
      } else {
        // Load historical messages
        _messages.addAll(history);
      }
    });
  }

  void _switchMode() {
    setState(() {
      _userMode = _userMode == 'engineer' ? 'passenger' : 'engineer';
      _chatService.userMode = _userMode;
      _messages.clear();
      _initializeChat();
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;
    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
    });

    // Get AI response
    try {
      final response = await _chatService.getResponse(userMessage);

      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
      });

      // Save to database
      await _chatService.saveChatMessage(userMessage, response);
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Error processing request: ${e.toString()}',
            isUser: false,
          ),
        );
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(
                'Aero',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Text(
                'Assistant',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFC107),
                ),
              ),
            ],
          ),
          elevation: 1,
          backgroundColor: AppTheme.primaryColor,
          actions: [
            Tooltip(
              message:
                  'Switch to ${_userMode == 'engineer' ? 'Passenger' : 'Engineer'} Mode',
              child: IconButton(
                icon: Icon(
                    _userMode == 'engineer' ? Icons.person : Icons.engineering),
                onPressed: _switchMode,
                tooltip: 'Switch Mode',
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 12.h),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) =>
                            _buildMessageBubble(_messages[index]),
                      ),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      );

  Widget _buildMessageBubble(ChatMessage message) {
    final timeFormat = DateFormat('HH:mm');
    final timestamp = timeFormat.format(message.timestamp);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primaryColor
                    : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12.r),
              ),
              constraints: BoxConstraints(
                maxWidth: 0.75 * MediaQuery.of(context).size.width,
              ),
              child: SelectableText(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : const Color(0xFF333333),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4.h, left: 12.w, right: 12.w),
              child: Text(
                timestamp,
                style: TextStyle(
                  fontSize: 8.sp,
                  color: AppTheme.textGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() => Container(
        padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE8E8E8), width: 1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Ask a question...',
                  hintStyle: TextStyle(fontSize: 10.sp, color: const Color(0xFFAAAAAA)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(
                        color: AppTheme.primaryColor, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 10.h),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                ),
                style: TextStyle(fontSize: 10.5.sp),
                minLines: 1,
                maxLines: 3,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              height: 42.h,
              width: 42.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Center(
                    child: Icon(
                      Icons.send,
                      size: 18.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

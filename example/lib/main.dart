import 'package:cdx_comments/cdx_comments.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/example_comment_service.dart';
import 'services/example_feature_checker.dart';
import 'widgets/simple_comment_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CDX Comments Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      localizationsDelegates: [
        ...CdxCommentsLocalizations.localizationsDelegates,
      ],
      supportedLocales: CdxCommentsLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Service implementation (in-memory for this example)
  final ExampleCommentService _service = ExampleCommentService();
  
  late final CommentConfig _config;
  late final UserInfo _user;
  late final CommentController _controller;
  late final CommentValidator _validator;

  @override
  void initState() {
    super.initState();
    
    // Configuration for comments module
    // In a real app, this would come from your app's configuration
    _config = const CommentConfig(
      badWords: 'bad\nword\ntest\n# Lines starting with # are ignored',
    );
    
    // Current user information
    // In a real app, this would come from your authentication system
    _user = const UserInfo(
      uuid: 'user-1',
      name: 'John Doe',
    );
    
    // Create the controller that orchestrates comment operations
    _controller = CommentController(
      service: _service,
      config: _config,
      user: _user,
    );
    
    // Create the validator for comment content
    _validator = CommentValidator(badWordsData: _config.badWords);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('CDX Comments Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to CDX Comments Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tap the button below to open the comments section',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => CommentProvider(
                        controller: _controller,
                        postId: 'example-post-1',
                        validator: _validator,
                      ),
                      child: const CommentsPage(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.comment),
              label: const Text('Open Comments'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentsPage extends StatefulWidget {
  const CommentsPage({super.key});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  late final FeatureChecker _featureChecker;

  @override
  void initState() {
    super.initState();
    _featureChecker = ExampleFeatureChecker();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentProvider>();
    final service = (provider.controller.service as ExampleCommentService);
    final user = provider.controller.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: SimpleCommentList(
        provider: provider,
        service: service,
        user: user,
        featureChecker: _featureChecker,
      ),
    );
  }
}

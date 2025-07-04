import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    
  );
    
  runApp( ServicePlatformApp());
}

class ServicePlatformApp extends StatelessWidget {
  const ServicePlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          elevation: 1,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final bool? seenOnboarding = prefs.getBool('seenOnboarding');

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => seenOnboarding == true
            ? const AuthScreen(isLogin: true)
            : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Service Platform', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 20)),
            // Image.asset('assets/images/logo.png', width: 150),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// Onboarding Screens
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Find Local Services',
      'description': 'Discover skilled professionals near you',
      'image': 'https://images.unsplash.com/photo-1581091012184-7f636a26b287?fit=crop&w=800&q=80',
    },
    {
      'title': 'Book Instantly',
      'description': 'Schedule appointments with just a few taps',
      'image': 'https://images.unsplash.com/photo-1591012911200-2c912dcd52c5?fit=crop&w=800&q=80',
    },
    {
      'title': 'Secure Payments',
      'description': 'Pay safely through our secure platform',
      'image': 'https://images.unsplash.com/photo-1605902711622-cfb43c4437d3?fit=crop&w=800&q=80',
    },
  ];


  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen(isLogin: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    title: onboardingData[index]['title']!,
                    description: onboardingData[index]['description']!,
                    image: onboardingData[index]['image']!,
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _currentPage == onboardingData.length - 1
                      ? _completeOnboarding
                      : () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                  child: Text(
                    _currentPage == onboardingData.length - 1 ? 'Get Started' : 'Next',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(image, height: 250),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Authentication Screens
class AuthScreen extends StatefulWidget {
  final bool isLogin;
  const AuthScreen({super.key, this.isLogin = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(); // NEW
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    try {
      UserCredential userCredential;

      if (widget.isLogin) {
        // LOGIN
        userCredential = await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // SIGN UP
        userCredential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Save user data to Firestore
        await firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': Timestamp.now(),
        });
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Authentication failed';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email already in use.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleAuthMode() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AuthScreen(isLogin: !widget.isLogin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/images/auth.jpg', height: 200),
                  const SizedBox(height: 30),
                  Text(
                    widget.isLogin ? 'Welcome Back' : 'Create Account',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Name field (only for sign up)
                  if (!widget.isLogin)
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),

                  if (!widget.isLogin) const SizedBox(height: 20),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  if (!widget.isLogin) ...[
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(widget.isLogin ? 'Login' : 'Sign Up'),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _toggleAuthMode,
                    child: Text(
                      widget.isLogin
                          ? 'Don\'t have an account? Sign Up'
                          : 'Already have an account? Login',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

// Main App Navigation
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const BookingsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Home Screen and Components
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Platform'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ServiceSearchDelegate());
            },
          ),
        ],
      ),
      body: const SafeArea(
        child: HomeContent(),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SearchBar(),
          const SizedBox(height: 16),
          const _CategoriesSection(),
          const SizedBox(height: 24),
          const _FeaturedProvidersSection(),
          const SizedBox(height: 24),
          const _NearbyProvidersSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          showSearch(context: context, delegate: ServiceSearchDelegate());
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: Colors.grey),
              SizedBox(width: 10),
              Text('Search for services...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CategoriesScreen()),
                ),
                child: const Text('See all'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: AppData.categories.length,
            itemBuilder: (context, index) {
              final category = AppData.categories[index];
              return _CategoryCard(category: category);
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProvidersScreen(category: category),
          ),
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: category['color'].withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(category['icon'], size: 30, color: category['color']),
            ),
            const SizedBox(height: 8),
            Text(
              category['name'],
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryProvidersScreen extends StatelessWidget {
  final Map<String, dynamic> category;

  const CategoryProvidersScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Filter providers by category
    final categoryProviders = AppData.featuredProviders
        .where((provider) => provider['categoryId'] == category['id'])
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category['name']),
      ),
      body: categoryProviders.isEmpty
          ? const Center(
        child: Text('No providers available for this category'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categoryProviders.length,
        itemBuilder: (context, index) {
          final provider = categoryProviders[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProviderDetailsScreen(provider: provider),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.asset(
                      provider['imageUrl'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            provider['profession'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                provider['rating'].toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                '${provider['startingPrice']} CFA',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedProvidersSection extends StatelessWidget {
  const _FeaturedProvidersSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Providers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See all'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: AppData.featuredProviders.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProviderDetailsScreen(provider: AppData.featuredProviders[index]),
                    ),
                  );
                },
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.asset(
                          AppData.featuredProviders[index]['imageUrl'],
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppData.featuredProviders[index]['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppData.featuredProviders[index]['profession'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  AppData.featuredProviders[index]['rating'].toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                Text(
                                  '${AppData.featuredProviders[index]['startingPrice']} CFA',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NearbyProvidersSection extends StatelessWidget {
  const _NearbyProvidersSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nearby Providers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See all'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AppData.featuredProviders.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProviderDetailsScreen(provider: AppData.featuredProviders[index]),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Image.asset(
                          AppData.featuredProviders[index]['imageUrl'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppData.featuredProviders[index]['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppData.featuredProviders[index]['profession'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppData.featuredProviders[index]['rating'].toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${AppData.featuredProviders[index]['startingPrice']} CFA',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Categories Screen
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Categories'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: AppData.categories.length,
        itemBuilder: (context, index) {
          final category = AppData.categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryProvidersScreen(category: category),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: category['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    category['icon'],
                    size: 30,
                    color: category['color'],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'],
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Provider Details Screen
class ProviderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> provider;

  const ProviderDetailsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(provider['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(provider['imageUrl']),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            provider['profession'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                provider['rating'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.attach_money, color: Colors.white, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                'Starting from ${provider['startingPrice']} CFA',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Contact',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(provider['phone']),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(provider['email']),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(provider['location']),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(provider['workingHours']),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(provider['description']),
                      const SizedBox(height: 12),
                      if (provider['services'] != null)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List<Widget>.from(
                            provider['services'].map((service) => Chip(
                              label: Text(service),
                              backgroundColor: Colors.blue.withOpacity(0.1),
                            )),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Service Pricing',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...AppData.packages.map((package) => Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                package['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${package['price']} CFA',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(package['description']),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(package['duration']),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingScreen(
                                      provider: provider,
                                      package: package,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Book Now'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Booking Screen
class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> provider;
  final Map<String, dynamic> package;

  const BookingScreen({
    super.key,
    required this.provider,
    required this.package,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Package',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Provider:'),
                          Text(widget.provider['name']),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Package:'),
                          Text(widget.package['name']),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Duration:'),
                          Text(widget.package['duration']),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Price:'),
                          Text(
                            '${widget.package['price']} CFA',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Service Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Service Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                controller: TextEditingController(
                  text: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please select a date' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Service Time',
                  suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null && picked != selectedTime) {
                    setState(() {
                      selectedTime = picked;
                    });
                  }
                },
                controller: TextEditingController(
                  text: selectedTime.format(context),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please select a time' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            provider: widget.provider,
                            package: widget.package,
                            bookingDetails: {
                              'date': selectedDate,
                              'time': selectedTime,
                              'name': _nameController.text,
                              'phone': _phoneController.text,
                              'notes': _notesController.text,
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Continue to Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Payment Screen
class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> provider;
  final Map<String, dynamic> package;
  final Map<String, dynamic> bookingDetails;

  const PaymentScreen({
    super.key,
    required this.provider,
    required this.package,
    required this.bookingDetails,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 0;
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Mobile Money',
      'icon': Icons.phone_android,
      'description': 'Pay with MTN, Orange, or other mobile money services',
    },
    {
      'name': 'Credit Card',
      'icon': Icons.credit_card,
      'description': 'Pay with Visa, Mastercard, or other credit cards',
    },
    {
      'name': 'Bank Transfer',
      'icon': Icons.account_balance,
      'description': 'Direct bank transfer',
    },
    {
      'name': 'Cash',
      'icon': Icons.money,
      'description': 'Pay in cash when service is completed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _paymentMethods.length,
                    itemBuilder: (context, index) {
                      final method = _paymentMethods[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: RadioListTile<int>(
                          title: Text(method['name']),
                          subtitle: Text(method['description']),
                          secondary: Icon(method['icon']),
                          value: index,
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value!;
                            });
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _OrderSummaryItem(
                    label: 'Service',
                    value: widget.package['name'],
                  ),
                  _OrderSummaryItem(
                    label: 'Provider',
                    value: widget.provider['name'],
                  ),
                  _OrderSummaryItem(
                    label: 'Date',
                    value: '${widget.bookingDetails['date'].day}/${widget.bookingDetails['date'].month}/${widget.bookingDetails['date'].year}',
                  ),
                  _OrderSummaryItem(
                    label: 'Time',
                    value: widget.bookingDetails['time'].format(context),
                  ),
                  const Divider(height: 24),
                  _OrderSummaryItem(
                    label: 'Total Amount',
                    value: '${widget.package['price']} CFA',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentSuccessScreen(
                        provider: widget.provider,
                        package: widget.package,
                        bookingDetails: widget.bookingDetails,
                        paymentMethod: _paymentMethods[_selectedPaymentMethod]['name'],
                      ),
                    ),
                  );
                },
                child: const Text('Confirm Payment'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _OrderSummaryItem({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).primaryColor : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }
}

// Payment Success Screen
class PaymentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> provider;
  final Map<String, dynamic> package;
  final Map<String, dynamic> bookingDetails;
  final String paymentMethod;

  const PaymentSuccessScreen({
    super.key,
    required this.provider,
    required this.package,
    required this.bookingDetails,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You have successfully paid ${package['price']} CFA',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _SuccessInfoItem(
                        label: 'Service',
                        value: package['name'],
                      ),
                      _SuccessInfoItem(
                        label: 'Provider',
                        value: provider['name'],
                      ),
                      _SuccessInfoItem(
                        label: 'Date',
                        value: '${bookingDetails['date'].day}/${bookingDetails['date'].month}/${bookingDetails['date'].year}',
                      ),
                      _SuccessInfoItem(
                        label: 'Time',
                        value: bookingDetails['time'].format(context),
                      ),
                      _SuccessInfoItem(
                        label: 'Payment Method',
                        value: paymentMethod,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationScreen(),
                      ),
                          (route) => false,
                    );
                  },
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _SuccessInfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Search Screen
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Services'),
      ),
      body: const Center(
        child: Text('Search functionality will go here'),
      ),
    );
  }
}

// Bookings Screen
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: const Center(
        child: Text('Your bookings will appear here'),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data();
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          final user = FirebaseAuth.instance.currentUser;
          final email = user?.email ?? '';

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          final name = data?['name'] ?? 'No Name';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://www.w3schools.com/howto/img_avatar.png'),

                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                _ProfileMenuItem(
                  icon: Icons.history,
                  title: 'Booking History',
                  onTap: () {},
                ),
                const Divider(),
                _ProfileMenuItem(
                  icon: Icons.favorite,
                  title: 'Favorites',
                  onTap: () {},
                ),
                const Divider(),
                _ProfileMenuItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {},
                ),
                const Divider(),
                _ProfileMenuItem(
                  icon: Icons.help,
                  title: 'Help & Support',
                  onTap: () {},
                ),
                const Divider(),
                _ProfileMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  color: Colors.red,
                  onTap: () => _logout(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}



// Search Delegate
class ServiceSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('Search results for: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text('Search suggestions for: $query'),
    );
  }
}

// App Data
class AppData {
  static final List<Map<String, dynamic>> categories = [
    {'id': '1', 'name': 'Electricians', 'icon': Icons.electrical_services, 'color': Colors.blue},
    {'id': '2', 'name': 'Welders', 'icon': Icons.build, 'color': Colors.orange},
    {'id': '3', 'name': 'Developers', 'icon': Icons.code, 'color': Colors.purple},
    {'id': '4', 'name': 'Designers', 'icon': Icons.design_services, 'color': Colors.pink},
    {'id': '5', 'name': 'Plumbers', 'icon': Icons.plumbing, 'color': Colors.blueAccent},
    {'id': '6', 'name': 'Cleaning', 'icon': Icons.cleaning_services, 'color': Colors.green},
    {'id': '7', 'name': 'Tutors', 'icon': Icons.school, 'color': Colors.teal},
    {'id': '8', 'name': 'Photographers', 'icon': Icons.camera_alt, 'color': Colors.indigo},
    {'id': '9', 'name': 'Caterers', 'icon': Icons.restaurant, 'color': Colors.red},
    {'id': '10', 'name': 'Tailors', 'icon': Icons.style, 'color': Colors.brown},
    {'id': '11', 'name': 'Barbers', 'icon': Icons.cut, 'color': Colors.blueGrey},
    {'id': '12', 'name': 'Mechanics', 'icon': Icons.directions_car, 'color': Colors.deepOrange},
  ];

  static final List<Map<String, dynamic>> featuredProviders = [
    {
      'id': '1',
      'categoryId': '3', // Developer category
      'name': 'Mukum Ghislain',
      'profession': 'Developer',
      'description': 'Full-stack developer specialized in web and mobile applications. E-commerce expert with 10 years of experience building scalable solutions for businesses of all sizes.',
      'location': 'Bonanjo Business Center, Douala',
      'phone': '+237 678 345 678',
      'email': 'robert.tamgno@example.com',
      'workingHours': 'Mon-Fri: 9am-6pm',
      'experienceYears': 10,
      'rating': 4.7,
      'startingPrice': 15000,
      'imageUrl': 'assets/images/developer1.jpg',
      'services': ['Web Development', 'Mobile Apps', 'E-commerce', 'API Integration'],
    },
    {
      'id': '2',
      'categoryId': '8', // Photographer category
      'name': 'Jaymadit',
      'profession': 'Photographer',
      'description': 'Professional photographer specialized in events, portraits and commercial photography. Capturing your special moments with creativity and passion.',
      'location': 'Akwa, Douala',
      'phone': '+237 679 456 789',
      'email': 'sylvie.ndoumbe@hotmail.com',
      'workingHours': 'Mon-Sat: 8am-8pm',
      'experienceYears': 7,
      'rating': 4.8,
      'startingPrice': 35000,
      'imageUrl': 'assets/images/photographer1.jpg',
      'services': ['Portraits', 'Events', 'Commercial', 'Product Photography'],
    },
    {
      'id': '3',
      'categoryId': '1', // Electrician category
      'name': 'Fonguong Edrick',
      'profession': 'Electrician',
      'description': 'Certified electrician with 15 years of experience in residential and commercial electrical installations, repairs and maintenance.',
      'location': 'Bonaberi, Douala',
      'phone': '+237 677 123 456',
      'email': 'jean.mbarga@gmail.com',
      'workingHours': 'Mon-Sun: 7am-9pm',
      'experienceYears': 15,
      'rating': 4.9,
      'startingPrice': 10000,
      'imageUrl': 'assets/images/electrician1.jpg',
      'services': ['Installations', 'Repairs', 'Maintenance', 'Wiring'],
    },
    {
      'id': '4',
      'categoryId': '1', // Electrician category
      'name': 'Sir Wise',
      'profession': 'Tutor',
      'description': 'Certified electrician with 15 years of experience in residential and commercial electrical installations, repairs and maintenance.',
      'location': 'Bambili, Bamenda',
      'phone': '+237 677 123 456',
      'email': 'prof.wise@gmail.com',
      'workingHours': 'Mon-Sun: 7am-9pm',
      'experienceYears': 15,
      'rating': 4.9,
      'startingPrice': 10000,
      'imageUrl': 'assets/images/tutor.jpg',
      'services': ['Installations', 'Repairs', 'Maintenance', 'Wiring'],
    },

  ];

  static final List<Map<String, dynamic>> packages = [
    {
      'id': '1',
      'name': 'Basic',
      'description': 'Standard service package with all essential features',
      'duration': '2-3h',
      'price': 15000,
    },
    {
      'id': '2',
      'name': 'Standard',
      'description': 'Extended service package with additional features',
      'duration': '3-4h',
      'price': 25000,
    },
    {
      'id': '3',
      'name': 'Premium',
      'description': 'Complete service package with all premium features',
      'duration': '4-6h',
      'price': 35000,
    },
  ];
}
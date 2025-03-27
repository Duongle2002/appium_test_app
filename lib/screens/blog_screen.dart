import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/blog.dart';
import 'blog_detail_screen.dart';
import 'package:intl/intl.dart'; // Thêm để định dạng ngày

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  _BlogScreenState createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  late Future<List<Blog>> futureBlogs;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    futureBlogs = ApiService.getBlogs() as Future<List<Blog>>;
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Blog', style: Theme.of(context).textTheme.headlineLarge),
          SizedBox(height: 16),
          // Thanh tìm kiếm
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search blogs...',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
              ),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFF8A4AF0)),
              ),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Blog>>(
              future: futureBlogs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyMedium),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No blogs found', style: Theme.of(context).textTheme.bodyMedium),
                  );
                }

                final blogs = snapshot.data!
                    .where((blog) =>
                _searchQuery.isEmpty ||
                    blog.title.toLowerCase().contains(_searchQuery) ||
                    blog.description.toLowerCase().contains(_searchQuery))
                    .toList();

                if (blogs.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                    child: Text('No matching blogs found', style: Theme.of(context).textTheme.bodyMedium),
                  );
                }

                return ListView.builder(
                  itemCount: blogs.length,
                  itemBuilder: (context, index) {
                    final blog = blogs[index];
                    return BlogCard(blog: blog);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class BlogCard extends StatelessWidget {
  final Blog blog;

  const BlogCard({required this.blog, super.key});

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date); // Định dạng dd/MM/yyyy
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BlogDetailScreen(blogId: blog.id)),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16), // Sửa 'custom' thành 'bottom'
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                blog.image,
                width: double.infinity,
                height: 150, // Tăng chiều cao ảnh cho đẹp hơn
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    blog.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(blog.date),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => BlogDetailScreen(blogId: blog.id)),
                          );
                        },
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor == Color(0xFFF8E1E9)
                                ? Color(0xFF8A4AF0)
                                : Colors.orange,
                          ),
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
  }
}
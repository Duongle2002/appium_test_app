import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/blog.dart';

class BlogDetailScreen extends StatelessWidget {
  final String blogId;

  const BlogDetailScreen({required this.blogId, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Blog Detail', style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: 16),
            FutureBuilder<Blog>(
              future: ApiService.getBlogById(blogId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyMedium));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('Blog not found', style: Theme.of(context).textTheme.bodyMedium));
                }

                final blog = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        blog.image,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      blog.title,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24),
                    ),
                    SizedBox(height: 8),
                    Text(
                      blog.date.toString().split(' ')[0],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    Text(
                      blog.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    Text(
                      blog.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
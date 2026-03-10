import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/gallery_provider.dart';
import 'photo_detail_page.dart';
import 'utils/app_language.dart';

class GridDemoPage extends StatelessWidget {
  const GridDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLanguage.t(context, 'gridview_title')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => Provider.of<GalleryProvider>(context, listen: false).fetchPhotos(),
          ),
        ],
      ),
      body: Consumer<GalleryProvider>(
        builder: (context, galleryProvider, child) {
          if (galleryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (galleryProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(galleryProvider.errorMessage, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => galleryProvider.fetchPhotos(),
                    child: Text(AppLanguage.t(context, 'try_again')),
                  ),
                ],
              ),
            );
          }

          final photos = galleryProvider.photos;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle(context, AppLanguage.t(context, 'gridview_count'), AppLanguage.t(context, 'gridview_count_desc')),
              const SizedBox(height: 12),
              SizedBox(
                height: 250,
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  physics: const NeverScrollableScrollPhysics(),
                  children: photos.take(3).map((photo) => _buildGridItem(context, photo)).toList(),
                ),
              ),

              const SizedBox(height: 30),

              _buildSectionTitle(context, AppLanguage.t(context, 'gridview_builder'), AppLanguage.t(context, 'gridview_builder_desc')),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    if (index + 3 >= photos.length) return const SizedBox();
                    return _buildGridItem(context, photos[index + 3]);
                  },
                ),
              ),

              const SizedBox(height: 30),

              _buildSectionTitle(context, AppLanguage.t(context, 'gridview_extent'), AppLanguage.t(context, 'gridview_extent_desc')),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: GridView.extent(
                  maxCrossAxisExtent: 150,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: photos.skip(7).take(4).map((photo) => _buildGridItem(context, photo)).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  Widget _buildGridItem(BuildContext context, Map<String, dynamic> photo) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoDetailPage(photo: photo),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'photo-${photo['id']}',
              child: Image.network(
                photo['thumbnailUrl'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: const Icon(Icons.broken_image_outlined, color: Colors.red),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                },
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
              ),
            ),
            alignment: Alignment.bottomLeft,
            child: Text(
              photo['title'] ?? 'No Title',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

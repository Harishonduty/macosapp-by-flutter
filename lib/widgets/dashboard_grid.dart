import 'package:flutter/material.dart';

class DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int badgeCount;

  DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeCount = 0,
  });
}

class DashboardGrid extends StatelessWidget {
  final List<DashboardItem> items;

  const DashboardGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          color: item.color,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.badgeCount > 0)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${item.badgeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

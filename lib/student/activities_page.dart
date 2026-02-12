import 'package:flutter/material.dart';
import 'package:gdapp/models/student_activity.dart';
import 'package:gdapp/services/api_service.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({Key? key}) : super(key: key);

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  late Future<List<StudentActivity>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = ApiService.getStudentActivities();
  }

  Future<void> _refreshActivities() async {
    setState(() {
      _activitiesFuture = ApiService.getStudentActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Activities'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshActivities,
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshActivities,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search activities by name or skill',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: 'All activity types',
                            items: [
                              'All activity types',
                              'Skill tracks',
                              'Assessments'
                            ]
                                .map((e) => DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (_) {},
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton<String>(
                            underline: const SizedBox.shrink(),
                            value: 'Sort by activity',
                            items: ['Sort by activity', 'Progress', 'Newest']
                                .map((e) => DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (_) {},
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<StudentActivity>>(
                  future: _activitiesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                              const SizedBox(height: 16),
                              const Text(
                                'API Fetch Failed',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _refreshActivities,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try Again'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No activities found'));
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ApiService.lastActivitiesFetchWasSuccessful
                                  ? '✅ Live activities updated'
                                  : 'ℹ️ Offline mode: Showing saved activities'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: ApiService.lastActivitiesFetchWasSuccessful 
                                  ? Colors.green 
                                  : Colors.orange,
                            ),
                          );
                        }
                      });
                    }

                    final activities = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        return _buildActivityCard(activities[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(StudentActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F7FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Center(
              child: Icon(Icons.group, size: 56, color: Colors.blue),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(activity.subtitle,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const Spacer(),
                    Text(activity.progressLabel,
                        style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Levels: ${activity.level}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 8),
                _buildProgressIndicator(activity),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(StudentActivity activity) {
    final total = activity.level;
    final exact = (activity.progress * total).clamp(0.0, total.toDouble());
    final full = exact.floor();
    final fraction = (exact - full).clamp(0.0, 1.0);
    const segmentWidth = 28.0;
    const segmentHeight = 8.0;
    const segmentSpacing = 6.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(total, (i) {
              final isFull = i < full;
              final isCurrent = i == full && fraction > 0;

              return Container(
                margin:
                    EdgeInsets.only(right: i == total - 1 ? 0 : segmentSpacing),
                child: Stack(
                  children: [
                    Container(
                      width: segmentWidth,
                      height: segmentHeight,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    if (isFull)
                      Container(
                        width: segmentWidth,
                        height: segmentHeight,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                    else if (isCurrent)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: segmentWidth * fraction,
                            height: segmentHeight,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Text(
            'Progress: ${(full + (fraction > 0 ? fraction : 0.0)).toStringAsFixed(2)}/$total levels (${(activity.progress * 100).toStringAsFixed(0)}%)',
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}


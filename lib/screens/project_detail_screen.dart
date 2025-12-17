import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../services/auth_service.dart';
import '../services/project_service.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import '../widgets/comment_section.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  ProjectModel? _project;
  bool _isLoading = true;
  bool _hasVoted = false;
  String? _votedProjectId;
  bool _isVoting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final projectService = context.read<ProjectService>();
    final authService = context.read<AuthService>();

    final project = await projectService.getProjectById(widget.projectId);
    final userNik = authService.currentUser?.nik ?? '';
    final hasVoted = await projectService.hasUserVoted(userNik);
    final votedProjectId = await projectService.getUserVotedProjectId(userNik);

    if (mounted) {
      setState(() {
        _project = project;
        _hasVoted = hasVoted;
        _votedProjectId = votedProjectId;
        _isLoading = false;
      });
    }
  }

  Future<void> _vote() async {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null) return;

    if (!user.isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun Anda belum terverifikasi. Silakan upload KTP terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Confirm vote
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Vote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Anda akan memberikan suara untuk:'),
            const SizedBox(height: 8),
            Text(
              _project?.title ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Anda hanya bisa memberikan 1 suara. Pilihan tidak dapat diubah.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Konfirmasi Vote'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isVoting = true;
    });

    final projectService = context.read<ProjectService>();
    final error = await projectService.vote(
      projectId: widget.projectId,
      userId: user.id,
      userNik: user.nik,
    );

    setState(() {
      _isVoting = false;
    });

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terima kasih! Suara Anda telah tercatat.'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Proyek')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Proyek')),
        body: const Center(child: Text('Proyek tidak ditemukan')),
      );
    }

    final project = _project!;
    final isVotedProject = _votedProjectId == project.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Proyek'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Project Image/Header
            Container(
              height: 200,
              color: _getCategoryColor(project.category).withOpacity(0.2),
              child: Center(
                child: Icon(
                  _getCategoryIcon(project.category),
                  size: 80,
                  color: _getCategoryColor(project.category),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(project.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      project.category,
                      style: TextStyle(
                        color: _getCategoryColor(project.category),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    project.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Budget Card
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estimasi Anggaran',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                Helpers.formatCurrency(project.budget),
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.how_to_vote,
                          label: 'Suara',
                          value: '${project.voteCount}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.calendar_today,
                          label: 'Berakhir',
                          value: Helpers.daysRemaining(project.endDate),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Description
                  Text(
                    'Deskripsi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: 24),
                  // Vote Button
                  if (project.status == ProjectStatus.voting) ...[
                    if (_hasVoted)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isVotedProject
                              ? Colors.green.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isVotedProject
                                ? Colors.green.shade200
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isVotedProject
                                  ? Icons.check_circle
                                  : Icons.info_outline,
                              color: isVotedProject
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isVotedProject
                                    ? 'Anda sudah memberikan suara untuk proyek ini'
                                    : 'Anda sudah memberikan suara untuk proyek lain',
                                style: TextStyle(
                                  color: isVotedProject
                                      ? Colors.green.shade700
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isVoting ? null : _vote,
                          icon: _isVoting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.how_to_vote),
                          label: Text(_isVoting ? 'Memproses...' : 'Vote Proyek Ini'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_clock, color: Colors.grey.shade600),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Voting untuk proyek ini telah berakhir',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  // Comments Section
                  Text(
                    'Diskusi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  CommentSection(projectId: widget.projectId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'infrastruktur':
        return AppTheme.chartColors[0];
      case 'olahraga':
        return AppTheme.chartColors[1];
      case 'teknologi':
        return AppTheme.chartColors[2];
      case 'pendidikan':
        return AppTheme.chartColors[3];
      case 'kesehatan':
        return AppTheme.chartColors[4];
      default:
        return AppTheme.chartColors[5];
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'infrastruktur':
        return Icons.construction;
      case 'olahraga':
        return Icons.sports_soccer;
      case 'teknologi':
        return Icons.wifi;
      case 'pendidikan':
        return Icons.school;
      case 'kesehatan':
        return Icons.local_hospital;
      default:
        return Icons.category;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

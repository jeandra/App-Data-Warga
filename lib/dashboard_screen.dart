import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'detail_screen.dart';
import 'models.dart';
import 'resident_form.dart';
import 'widgets.dart';

enum ResidentFilter { all, permanent, contract, temporary }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  final TextEditingController _searchController = TextEditingController();
  final List<Resident> _residents = List<Resident>.of(sampleResidents);
  ResidentFilter _filter = ResidentFilter.all;
  String _query = '';
  int _navIndex = 0;

  @override
  void dispose() {
    _entrance.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Resident> _applyFilter(List<Resident> source) {
    var list = source;
    switch (_filter) {
      case ResidentFilter.all:
        break;
      case ResidentFilter.permanent:
        list = list.where((r) => r.status == ResidentStatus.permanent).toList();
        break;
      case ResidentFilter.contract:
        list = list.where((r) => r.status == ResidentStatus.contract).toList();
        break;
      case ResidentFilter.temporary:
        list = list.where((r) => r.status == ResidentStatus.temporary).toList();
        break;
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((r) =>
              r.name.toLowerCase().contains(q) || r.nik.contains(q))
          .toList();
    }
    return list;
  }

  int get _householdCount =>
      _residents.where((r) => r.relation == 'Kepala Keluarga').length;
  int get _permanentCount =>
      _residents.where((r) => r.status == ResidentStatus.permanent).length;
  int get _contractCount =>
      _residents.where((r) => r.status == ResidentStatus.contract).length;
  int get _temporaryCount =>
      _residents.where((r) => r.status == ResidentStatus.temporary).length;

  int get _nextId =>
      _residents.fold<int>(0, (max, r) => r.id > max ? r.id : max) + 1;

  Future<void> _openDetail(Resident resident) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(
          resident: resident,
          onUpdated: _replaceResident,
        ),
      ),
    );
  }

  void _replaceResident(Resident updated) {
    final index = _residents.indexWhere((r) => r.id == updated.id);
    if (index < 0) return;
    setState(() => _residents[index] = updated);
  }

  Future<void> _addResident() async {
    final created = await showResidentForm(context, nextId: _nextId);
    if (created == null || !mounted) return;
    setState(() {
      _residents.insert(0, created);
      _filter = ResidentFilter.all;
      _query = '';
      _searchController.clear();
      _navIndex = 0;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Warga baru berhasil ditambahkan.')),
      );
  }

  void _selectTab(int index) {
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _applyFilter(_residents);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FCFD), Color(0xFFE6F3F7)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: IndexedStack(
                  index: _navIndex,
                  children: [
                    _navIndex == 0
                        ? _HomeTab(
                            visible: visible,
                            entrance: _entrance,
                            searchController: _searchController,
                            query: _query,
                            onQueryChanged: (value) =>
                                setState(() => _query = value),
                            filter: _filter,
                            onFilterChanged: (f) => setState(() => _filter = f),
                            onOpenDetail: _openDetail,
                            total: _residents.length,
                            householdCount: _householdCount,
                            permanentCount: _permanentCount,
                            contractCount: _contractCount,
                            temporaryCount: _temporaryCount,
                          )
                        : const SizedBox.shrink(),
                    _navIndex == 1
                        ? _WargaTab(
                            visible: visible,
                            entrance: _entrance,
                            searchController: _searchController,
                            query: _query,
                            onQueryChanged: (value) =>
                                setState(() => _query = value),
                            filter: _filter,
                            onFilterChanged: (f) => setState(() => _filter = f),
                            onOpenDetail: _openDetail,
                            total: _residents.length,
                            householdCount: _householdCount,
                            permanentCount: _permanentCount,
                            contractCount: _contractCount,
                            temporaryCount: _temporaryCount,
                          )
                        : const SizedBox.shrink(),
                    _navIndex == 2
                        ? _LaporanTab(
                            total: _residents.length,
                            householdCount: _householdCount,
                            permanentCount: _permanentCount,
                            contractCount: _contractCount,
                            temporaryCount: _temporaryCount,
                            entrance: _entrance,
                          )
                        : const SizedBox.shrink(),
                    _navIndex == 3
                        ? _ProfilTab(
                            total: _residents.length,
                            householdCount: _householdCount,
                            entrance: _entrance,
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _FloatingNav(
        index: _navIndex,
        onTap: _selectTab,
        onCreate: _addResident,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Home tab
// ---------------------------------------------------------------------------

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.visible,
    required this.entrance,
    required this.searchController,
    required this.query,
    required this.onQueryChanged,
    required this.filter,
    required this.onFilterChanged,
    required this.onOpenDetail,
    required this.total,
    required this.householdCount,
    required this.permanentCount,
    required this.contractCount,
    required this.temporaryCount,
  });

  final List<Resident> visible;
  final AnimationController entrance;
  final TextEditingController searchController;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ResidentFilter filter;
  final ValueChanged<ResidentFilter> onFilterChanged;
  final ValueChanged<Resident> onOpenDetail;
  final int total;
  final int householdCount;
  final int permanentCount;
  final int contractCount;
  final int temporaryCount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        Entrance(
          animation: entrance,
          begin: 0,
          end: 0.35,
          child: _PageHeader(
            eyebrow: 'SELAMAT PAGI',
            title: 'Data Warga',
            initial: 'A',
          ),
        ),
        const SizedBox(height: 16),
        _SearchField(
          controller: searchController,
          onQueryChanged: onQueryChanged,
        ),
        const SizedBox(height: 12),
        _FilterChipRow(
          filter: filter,
          onFilterChanged: onFilterChanged,
          showTemporary: false,
        ),
        const SizedBox(height: 16),
        Entrance(
          animation: entrance,
          begin: 0.15,
          end: 0.55,
          child: _TotalCard(total: total),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _SummaryChip(label: '$householdCount KK'),
            const SizedBox(width: 8),
            _SummaryChip(label: '$permanentCount orang'),
            const SizedBox(width: 8),
            _SummaryChip(label: '$contractCount kontrak'),
          ],
        ),
        const SizedBox(height: 20),
        _SectionHeading(
          title: 'Daftar Warga',
          trailing: query.isEmpty ? '$total warga' : '${visible.length} data',
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          const _EmptyState()
        else
          ...visible.map(
            (resident) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ResidentRow(
                resident: resident,
                onTap: () => onOpenDetail(resident),
              ),
            ),
          ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.eyebrow,
    required this.title,
    required this.initial,
  });

  final String eyebrow;
  final String title;
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.light,
            shape: BoxShape.circle,
          ),
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onQueryChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onQueryChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintText: 'Cari warga...',
        hintStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.navMuted,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 18,
          color: AppColors.muted,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.filter,
    required this.onFilterChanged,
    required this.showTemporary,
  });

  final ResidentFilter filter;
  final ValueChanged<ResidentFilter> onFilterChanged;
  final bool showTemporary;

  static const _labels = {
    ResidentFilter.all: 'Semua',
    ResidentFilter.permanent: 'Tetap',
    ResidentFilter.contract: 'Kontrak',
    ResidentFilter.temporary: 'Sementara',
  };

  @override
  Widget build(BuildContext context) {
    final filters = <ResidentFilter>[
      ResidentFilter.all,
      ResidentFilter.permanent,
      ResidentFilter.contract,
      if (showTemporary) ResidentFilter.temporary,
    ];

    return Row(
      children: [
        for (var i = 0; i < filters.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _FilterChip(
              label: _labels[filters[i]] ?? '',
              active: filter == filters[i],
              onTap: () => onFilterChanged(filters[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppColors.line),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: active ? Colors.white : AppColors.chipMuted,
          ),
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.heroStart, AppColors.heroEnd],
        ),
        boxShadow: AppShadows.hero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL WARGA TERDATA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: AppColors.softBlue,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CountUpText(
                value: total,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x2EFFFFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '+6 bulan ini',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.softBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'di lingkungan RT 04 / RW 02',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.softBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: const Text(
        'Tidak ada warga yang cocok.',
        style: TextStyle(fontSize: 12, color: AppColors.muted),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared resident list + row
// ---------------------------------------------------------------------------

class _SearchResidentList extends StatelessWidget {
  const _SearchResidentList({
    required this.visible,
    required this.onOpenDetail,
    required this.query,
  });

  final List<Resident> visible;
  final ValueChanged<Resident> onOpenDetail;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (visible.isEmpty) return const _EmptyState();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeading(
          title: 'Daftar Warga',
          trailing: query.isEmpty ? '${visible.length} warga' : '${visible.length} data',
        ),
        const SizedBox(height: 12),
        for (final resident in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ResidentRow(
              resident: resident,
              onTap: () => onOpenDetail(resident),
            ),
          ),
      ],
    );
  }
}

class _ResidentRow extends StatelessWidget {
  const _ResidentRow({required this.resident, required this.onTap});

  final Resident resident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPermanent = resident.status == ResidentStatus.permanent;
    return PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
          boxShadow: AppShadows.row,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isPermanent ? AppColors.light : const Color(0xFFE8F5F8),
                shape: BoxShape.circle,
              ),
              child: Text(
                resident.initials,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resident.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${resident.maskedNik}  ·  ${resident.gender}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PulseDot(
              color: isPermanent ? AppColors.primary : AppColors.accent,
              size: 7,
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.navMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Warga tab
// ---------------------------------------------------------------------------

class _WargaTab extends StatelessWidget {
  const _WargaTab({
    required this.visible,
    required this.entrance,
    required this.searchController,
    required this.query,
    required this.onQueryChanged,
    required this.filter,
    required this.onFilterChanged,
    required this.onOpenDetail,
    required this.total,
    required this.householdCount,
    required this.permanentCount,
    required this.contractCount,
    required this.temporaryCount,
  });

  final List<Resident> visible;
  final AnimationController entrance;
  final TextEditingController searchController;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ResidentFilter filter;
  final ValueChanged<ResidentFilter> onFilterChanged;
  final ValueChanged<Resident> onOpenDetail;
  final int total;
  final int householdCount;
  final int permanentCount;
  final int contractCount;
  final int temporaryCount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        Entrance(
          animation: entrance,
          begin: 0,
          end: 0.35,
          child: const _PageHeader(
            eyebrow: 'DAFTAR LENGKAP',
            title: 'Warga',
            initial: 'A',
          ),
        ),
        const SizedBox(height: 16),
        _SearchField(
          controller: searchController,
          onQueryChanged: onQueryChanged,
        ),
        const SizedBox(height: 12),
        _FilterChipRow(
          filter: filter,
          onFilterChanged: onFilterChanged,
          showTemporary: true,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(label: 'TOTAL', value: '$total'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(label: 'KEPALA KK', value: '$householdCount'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(label: 'KONTRAK', value: '$contractCount'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SearchResidentList(
          visible: visible,
          onOpenDetail: onOpenDetail,
          query: query,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.fontSize = 18,
  });

  final String label;
  final String value;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: AppColors.muted,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              height: 1.05,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Laporan tab
// ---------------------------------------------------------------------------

class _LaporanTab extends StatelessWidget {
  const _LaporanTab({
    required this.total,
    required this.householdCount,
    required this.permanentCount,
    required this.contractCount,
    required this.temporaryCount,
    required this.entrance,
  });

  final int total;
  final int householdCount;
  final int permanentCount;
  final int contractCount;
  final int temporaryCount;
  final AnimationController entrance;

  static const _ages = [
    ('20-29', '28'),
    ('30-39', '41'),
    ('40-49', '33'),
    ('50-59', '18'),
    ('60+', '8'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        Entrance(
          animation: entrance,
          begin: 0,
          end: 0.35,
          child: const _PageHeader(
            eyebrow: 'RINGKASAN BULAN INI',
            title: 'Laporan',
            initial: 'A',
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'November 2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Data per hari ini',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AppColors.navMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Entrance(
          animation: entrance,
          begin: 0.15,
          end: 0.55,
          child: _TotalCard(total: total),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'LAKI-LAKI',
                value: '${total ~/ 2}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'PEREMPUAN',
                value: '${total - total ~/ 2}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'KEPALA KK',
                value: '$householdCount',
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionHeading(title: 'Komposisi Status', trailing: 'warga'),
        const SizedBox(height: 12),
        Column(
          children: [
            _LaporanStatusCard(
              label: 'Tetap',
              value: '$permanentCount',
              color: AppColors.primary,
              barColor: AppColors.primary,
            ),
            const SizedBox(height: 10),
            _LaporanStatusCard(
              label: 'Kontrak',
              value: '$contractCount',
              color: AppColors.accent,
              barColor: AppColors.accent,
            ),
            const SizedBox(height: 10),
            _LaporanStatusCard(
              label: 'Sementara',
              value: '$temporaryCount',
              color: AppColors.highlight,
              barColor: AppColors.highlight,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionHeading(title: 'Kelompok Usia', trailing: 'tahun'),
        const SizedBox(height: 12),
        Column(
          children: [
            for (final age in _ages) ...[
              _LaporanAgeCard(
                label: age.$1,
                value: age.$2,
                barColor: AppColors.primary,
              ),
              if (age != _ages.last) const SizedBox(height: 10),
            ],
          ],
        ),
      ],
    );
  }
}

class _LaporanStatusCard extends StatelessWidget {
  const _LaporanStatusCard({
    required this.label,
    required this.value,
    required this.color,
    required this.barColor,
  });

  final String label;
  final String value;
  final Color color;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final fraction = (int.tryParse(value) ?? 0) / 128;
    return Container(
      height: 58,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: AppColors.light,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LaporanAgeCard extends StatelessWidget {
  const _LaporanAgeCard({
    required this.label,
    required this.value,
    required this.barColor,
  });

  final String label;
  final String value;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final fraction = (int.tryParse(value) ?? 0) / 41;
    return Container(
      height: 58,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label tahun',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: barColor,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: AppColors.light,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profil tab
// ---------------------------------------------------------------------------

class _ProfilTab extends StatelessWidget {
  const _ProfilTab({
    required this.total,
    required this.householdCount,
    required this.entrance,
  });

  final int total;
  final int householdCount;
  final AnimationController entrance;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        Entrance(
          animation: entrance,
          begin: 0,
          end: 0.35,
          child: const _PageHeader(
            eyebrow: 'AKUN PENGELOLA',
            title: 'Profil',
            initial: 'A',
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.accent,
                child: Text(
                  'BS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Budi Santoso',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ketua RW 02 · Admin',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'WARGA DIKELOLA',
                value: '$total',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'KARTU KELUARGA',
                value: '$householdCount',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionHeading(title: 'Pengaturan', trailing: ''),
        const SizedBox(height: 8),
        _SettingTile(icon: Icons.tune_rounded, title: 'Setelan Umum'),
        _SettingTile(icon: Icons.notifications_none_rounded, title: 'Notifikasi'),
        _SettingTile(icon: Icons.lock_outline_rounded, title: 'Privasi & Keamanan'),
        _SettingTile(icon: Icons.help_outline_rounded, title: 'Bantuan'),
        _SettingTile(icon: Icons.logout_rounded, title: 'Keluar'),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'SIP-Warga 1.0.0+1',
            style: TextStyle(fontSize: 10, color: AppColors.navMuted),
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.navMuted,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Floating bottom navigation
// ---------------------------------------------------------------------------

class _FloatingNav extends StatelessWidget {
  const _FloatingNav({
    required this.index,
    required this.onTap,
    required this.onCreate,
  });

  final int index;
  final ValueChanged<int> onTap;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 96,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 62,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(31),
                  border: Border.all(color: const Color(0xFFE4F2F6)),
                  boxShadow: AppShadows.floating,
                ),
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Beranda',
                      selected: index == 0,
                      onTap: () => onTap(0),
                    ),
                    _NavItem(
                      icon: Icons.people_alt_rounded,
                      label: 'Warga',
                      selected: index == 1,
                      onTap: () => onTap(1),
                    ),
                    const SizedBox(width: 62),
                    _NavItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'Laporan',
                      selected: index == 2,
                      onTap: () => onTap(2),
                    ),
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: 'Profil',
                      selected: index == 3,
                      onTap: () => onTap(3),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onCreate,
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.accent,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tambah',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.navMuted;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

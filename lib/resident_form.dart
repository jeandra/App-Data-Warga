import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'models.dart';

/// Bottom sheet form untuk menambah warga baru atau mengubah data yang ada.
/// Mengembalikan [Resident] hasil isian, atau `null` bila dibatalkan.
Future<Resident?> showResidentForm(
  BuildContext context, {
  Resident? resident,
  required int nextId,
}) {
  return showModalBottomSheet<Resident>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ResidentFormSheet(
      resident: resident,
      nextId: nextId,
    ),
  );
}

class ResidentFormSheet extends StatefulWidget {
  const ResidentFormSheet({
    super.key,
    this.resident,
    required this.nextId,
  });

  final Resident? resident;
  final int nextId;

  @override
  State<ResidentFormSheet> createState() => _ResidentFormSheetState();
}

class _ResidentFormSheetState extends State<ResidentFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _nik;
  late final TextEditingController _job;
  late final TextEditingController _address;
  late final TextEditingController _age;

  late String _gender;
  late String _status;
  late String _relation;
  late String _bloodType;

  bool get _isEdit => widget.resident != null;

  static const _genders = ['Laki-laki', 'Perempuan'];
  static const _statuses = [
    ResidentStatus.permanent,
    ResidentStatus.contract,
    ResidentStatus.temporary,
  ];
  static const _relations = [
    'Kepala Keluarga',
    'Istri',
    'Anak',
    'Orang Tua',
  ];
  static const _bloodTypes = ['A', 'B', 'AB', 'O'];

  @override
  void initState() {
    super.initState();
    final resident = widget.resident;
    _name = TextEditingController(text: resident?.name ?? '');
    _nik = TextEditingController(text: resident?.nik ?? '');
    _job = TextEditingController(text: resident?.job ?? '');
    _address = TextEditingController(text: resident?.address ?? '');
    _age = TextEditingController(
      text: resident == null ? '' : '${resident.age}',
    );
    _gender = resident?.gender ?? _genders.first;
    _status = resident?.status ?? ResidentStatus.permanent;
    _relation = resident?.relation ?? 'Kepala Keluarga';
    _bloodType = resident?.bloodType ?? _bloodTypes.last;
  }

  @override
  void dispose() {
    _name.dispose();
    _nik.dispose();
    _job.dispose();
    _address.dispose();
    _age.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final base = widget.resident;
    final values = (
      name: _name.text.trim(),
      nik: _nik.text.trim(),
      job: _job.text.trim().isEmpty ? 'Belum diisi' : _job.text.trim(),
      address: _address.text.trim().isEmpty
          ? 'Alamat belum dilengkapi'
          : _address.text.trim(),
      age: int.tryParse(_age.text.trim()) ?? 0,
    );

    final result = base == null
        ? Resident(
            id: widget.nextId,
            name: values.name,
            nik: values.nik,
            gender: _gender,
            age: values.age,
            status: _status,
            relation: _relation,
            job: values.job,
            bloodType: _bloodType,
            address: values.address,
            registeredYear: DateTime.now().year,
          )
        : base.copyWith(
            name: values.name,
            nik: values.nik,
            gender: _gender,
            age: values.age,
            status: _status,
            relation: _relation,
            job: values.job,
            bloodType: _bloodType,
            address: values.address,
          );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: const BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: AppColors.line,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    _isEdit ? 'Edit Data Warga' : 'Tambah Data Warga',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    label: 'NAMA LENGKAP',
                    controller: _name,
                    hint: 'Nama sesuai KTP',
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Nama tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    label: 'NIK',
                    controller: _nik,
                    hint: '16 digit angka',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final nik = value?.trim() ?? '';
                      if (nik.length != 16 || int.tryParse(nik) == null) {
                        return 'NIK harus 16 digit angka';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _FormDropdown(
                          label: 'JENIS KELAMIN',
                          value: _gender,
                          items: _genders,
                          onChanged: (value) => setState(() => _gender = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FormField(
                          label: 'USIA',
                          controller: _age,
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final age = int.tryParse(value?.trim() ?? '');
                            if (age == null || age < 1 || age > 120) {
                              return '1–120';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FormDropdown(
                    label: 'STATUS WARGA',
                    value: _status,
                    items: _statuses,
                    onChanged: (value) => setState(() => _status = value),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _FormDropdown(
                          label: 'HUBUNGAN',
                          value: _relation,
                          items: _relations,
                          onChanged: (value) => setState(() => _relation = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FormDropdown(
                          label: 'GOL. DARAH',
                          value: _bloodType,
                          items: _bloodTypes,
                          onChanged: (value) =>
                              setState(() => _bloodType = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    label: 'PEKERJAAN',
                    controller: _job,
                    hint: 'Contoh: Karyawan Swasta',
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    label: 'ALAMAT',
                    controller: _address,
                    hint: 'Jl. Melati No. 12, RT 04 / RW 02',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  _SaveButton(
                    label: _isEdit ? 'Simpan Perubahan' : 'Simpan Warga',
                    onTap: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.card,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.navMuted,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormDropdown extends StatelessWidget {
  const _FormDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          isDense: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.muted,
          ),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          items: [
            for (final item in items)
              DropdownMenuItem(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ],
    );
  }
}

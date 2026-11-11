class ResidentStatus {
  const ResidentStatus._();

  static const permanent = 'Warga Tetap';
  static const contract = 'Warga Kontrak / Kos';
  static const temporary = 'Domisili Sementara';
}

class Resident {
  const Resident({
    required this.id,
    required this.name,
    required this.nik,
    required this.gender,
    required this.age,
    required this.status,
    required this.relation,
    required this.job,
    required this.bloodType,
    required this.address,
    this.registeredYear = 2019,
  });

  final int id;
  final String name;
  final String nik;
  final String gender;
  final int age;
  final String status;
  final String relation;
  final String job;
  final String bloodType;
  final String address;
  final int registeredYear;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get formattedNik =>
      'NIK ${nik.substring(0, 4)} ${nik.substring(4, 8)} ${nik.substring(8, 12)} ${nik.substring(12)}';

  String get maskedNik => 'NIK •••• ${nik.substring(12)}';

  Resident copyWith({
    String? name,
    String? nik,
    String? gender,
    int? age,
    String? status,
    String? relation,
    String? job,
    String? bloodType,
    String? address,
  }) {
    return Resident(
      id: id,
      name: name ?? this.name,
      nik: nik ?? this.nik,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      status: status ?? this.status,
      relation: relation ?? this.relation,
      job: job ?? this.job,
      bloodType: bloodType ?? this.bloodType,
      address: address ?? this.address,
      registeredYear: registeredYear,
    );
  }
}

final List<Resident> sampleResidents = List.unmodifiable(_buildResidents());

List<Resident> _buildResidents() {
  final residents = <Resident>[
    const Resident(
      id: 1,
      name: 'Siti Aminah',
      nik: '3271082119904821',
      gender: 'Perempuan',
      age: 34,
      status: ResidentStatus.permanent,
      relation: 'Istri',
      job: 'Karyawan Swasta',
      bloodType: 'O',
      address: 'Jl. Melati No. 12, RT 04 / RW 02, Kel. Sukamaju',
    ),
    const Resident(
      id: 2,
      name: 'Budi Santoso',
      nik: '3271081519851650',
      gender: 'Laki-laki',
      age: 41,
      status: ResidentStatus.permanent,
      relation: 'Kepala Keluarga',
      job: 'Wiraswasta',
      bloodType: 'B',
      address: 'Jl. Melati No. 12, RT 04 / RW 02, Kel. Sukamaju',
    ),
  ];

  const maleNames = [
    'Agus', 'Andi', 'Rizky', 'Fajar', 'Hendra', 'Joko', 'Bayu', 'Dimas',
    'Arif', 'Yoga', 'Galih', 'Reza', 'Taufik', 'Ilham', 'Rudi', 'Doni',
    'Asep', 'Hafiz', 'Bagas', 'Farhan',
  ];
  const femaleNames = [
    'Ayu', 'Dewi', 'Rina', 'Fitri', 'Nur', 'Intan', 'Maya', 'Sari',
    'Lestari', 'Putri', 'Indah', 'Yuni', 'Wulan', 'Ratna', 'Dian', 'Eka',
    'Nia', 'Tari', 'Salsa', 'Mila',
  ];
  const lastNames = [
    'Pratama', 'Wijaya', 'Lestari', 'Nugroho', 'Saputra', 'Hidayat',
    'Permata', 'Kusuma', 'Setiawan', 'Halim', 'Maulana', 'Rahayu',
    'Firmansyah', 'Anggraini', 'Siregar', 'Simanjuntak', 'Purnama',
    'Mulyani', 'Hartono', 'Susanto',
  ];
  const jobs = [
    'Karyawan Swasta', 'Wiraswasta', 'Buruh', 'PNS', 'Guru', 'Pedagang',
    'Petani', 'Sopir', 'Ibu Rumah Tangga', 'Mahasiswa',
  ];
  const bloodTypes = ['A', 'B', 'AB', 'O'];

  final usedNames = residents.map((resident) => resident.name).toSet();

  for (var i = 0; i < 126; i++) {
    final gender = i.isEven ? 'Laki-laki' : 'Perempuan';
    final pool = gender == 'Laki-laki' ? maleNames : femaleNames;

    var name = '${pool[i % pool.length]} ${lastNames[(i * 7 + 3) % lastNames.length]}';
    var salt = 2;
    while (usedNames.contains(name)) {
      name = '${pool[i % pool.length]} '
          '${lastNames[(i * 7 + 3 + salt) % lastNames.length]}';
      salt++;
    }
    usedNames.add(name);

    final status = i < 94
        ? ResidentStatus.permanent
        : (i < 118 ? ResidentStatus.contract : ResidentStatus.temporary);

    var relation = i < 41
        ? 'Kepala Keluarga'
        : const ['Istri', 'Anak', 'Anak', 'Orang Tua'][i % 4];

    final effectiveGender = relation == 'Istri' ? 'Perempuan' : gender;
    if (relation == 'Kepala Keluarga') {
      relation = 'Kepala Keluarga';
    }

    final nik = '3271'
        '${(i % 28 + 1).toString().padLeft(2, '0')}'
        '${(i % 12 + 1).toString().padLeft(2, '0')}'
        '${(1970 + (i % 35)).toString().padLeft(4, '0')}'
        '${(1000 + i).toString().padLeft(4, '0')}';

    residents.add(
      Resident(
        id: 3 + i,
        name: name,
        nik: nik,
        gender: effectiveGender,
        age: 20 + (i * 7) % 46,
        status: status,
        relation: relation,
        job: jobs[i % jobs.length],
        bloodType: bloodTypes[i % bloodTypes.length],
        address: 'Jl. Melati No. ${13 + i}, RT 04 / RW 02, Kel. Sukamaju',
      ),
    );
  }

  return residents;
}

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/exercise.dart';
import '../widgets/exercise_card.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({super.key});

  static const List<Exercise> exercises = [
    Exercise(
      id: 'bulgarian_split_squat',
      name: 'Bulgarian Split Squat',
      targetMuscles: 'Quadriceps, Gluteus Maximus, Hip Stabilizer',
      functionForHm: 'Krusial untuk pelari karena lari adalah serangkaian lompatan 1 kaki. Memperbaiki ketimpangan kekuatan kaki kiri vs kanan dan menstabilkan panggul saat mendarat.',
      formCues: 'Letakkan satu punggung kaki di kursi/bangku di belakang. Turunkan lutut belakang hingga hampir menyentuh lantai. Pastikan lutut depan sejajar dengan jemari kaki (tidak goyang ke dalam). Dorong kembali ke atas melalui tumit kaki depan.',
      dosage: '3 Set x 8-10 Reps / kaki',
      importantNotes: 'Istirahat 60 detik antar kaki. Jaga dada tetap tegak.',
      imageAssetPath: 'assets/images/exercises/bulgarian_split_squat.png',
    ),
    Exercise(
      id: 'calf_raises',
      name: 'Single-Leg Calf Raises',
      targetMuscles: 'Soleus & Gastrocnemius (Betis & Achilles)',
      functionForHm: 'Mencegah cedera paling umum pelari: Shin Splints (nyeri tulang kering) dan Plantar Fasciitis. Soleus menyerap beban 6-8x berat badan di setiap hentakan kaki.',
      formCues: 'Berdiri di tepi anak tangga dengan satu kaki. Turunkan tumit ke bawah hingga terasa tarikan di betis, lalu dorong ke atas setinggi mungkin dengan bertumpu pada jempol kaki. Tahan 1 detik di puncak.',
      dosage: '3 Set x 15-20 Reps / kaki',
      importantNotes: 'Lakukan perlahan (2 detik naik, 2 detik turun). Jangan membal.',
      imageAssetPath: 'assets/images/exercises/calf_raises.png',
    ),
    Exercise(
      id: 'glute_bridge',
      name: 'Glute Bridge & Single-Leg',
      targetMuscles: 'Gluteus Maximus, Hamstrings, Pelvic Stability',
      functionForHm: 'Mencegah Glute Amnesia (pantat mati rasa akibat sering duduk kerja 9-6). Pantat yang kuat menghasilkan tenaga dorongan lari yang efisien tanpa membebani pinggang bawah.',
      formCues: 'Berbaring terlentang, tekuk lutut, telapak kaki menapak di lantai selebar pinggul. Angkat pinggul ke atas hingga paha dan dada membentuk garis lurus. Peras pantat sekuat tenaga di puncak selama 2 detik.',
      dosage: '3 Set x 12-15 Reps',
      importantNotes: 'Tingkatkan ke 1 kaki (Single-leg) saat sudah terbiasa.',
      imageAssetPath: 'assets/images/exercises/glute_bridge.png',
    ),
    Exercise(
      id: 'side_plank',
      name: 'Side Plank with Leg Raise',
      targetMuscles: 'Gluteus Medius & Tensor Fasciae Latae (TFL)',
      functionForHm: 'VAKSIN RESMI PENCEGAH ITBS (Iliotibial Band Syndrome / nyeri samping lutut). Gluteus medius yang lemah membuat panggul miring (hip drop) dan menarik pita IT band.',
      formCues: 'Berbaring miring bertumpu pada siku. Angkat pinggul hingga badan lurus dari kepala ke tumit. Perlahan angkat kaki bagian atas 30 derajat ke atas tanpa memutar pinggul ke belakang, lalu turunkan.',
      dosage: '3 Set x 30-40 Detik / sisi',
      importantNotes: 'Jangan biarkan pinggul melorot ke bawah.',
      imageAssetPath: 'assets/images/exercises/side_plank.png',
    ),
    Exercise(
      id: 'plank_taps',
      name: 'Front Plank with Shoulder Taps',
      targetMuscles: 'Transversus Abdominis, Anti-Rotation Core',
      functionForHm: 'Menjaga postur tubuh tetap tegak dan tidak bungkuk di km 15-21 saat tubuh sudah lelah. Inti tubuh yang kuat mentransfer energi ayunan lengan langsung ke langkah kaki.',
      formCues: 'Posisi push-up plank. Kaki dibuka sedikit lebih lebar dari bahu. Angkat satu tangan menyentuh bahu sisi berlawanan secara bergantian. PINGGUL HARUS TETAP DIAM (tidak bergoyang ke kiri/kanan).',
      dosage: '3 Set x 12-16 Sentuhan bahu',
      importantNotes: 'Tarik pusar ke arah tulang belakang sepanjang gerakan.',
      imageAssetPath: 'assets/images/exercises/plank_taps.png',
    ),
    Exercise(
      id: 'bird_dog',
      name: 'Bird-Dog Cross Sling',
      targetMuscles: 'Lower Back (Erector Spinae), Glutes, Kontrol Diagonal Panggul',
      functionForHm: 'Menguatkan rantai silang (cross-body sling) yang menyinkronkan lengan kanan dengan kaki kiri saat berlari. Sangat aman bagi yang sering pegal pinggang di kantor.',
      formCues: 'Posisi merangkak. Luruskan lengan kanan ke depan dan kaki kiri ke belakang secara bersamaan hingga sejajar lantai. Tahan 2 detik, kembali, ganti sisi.',
      dosage: '3 Set x 10-12 Reps / sisi',
      importantNotes: 'Bayangkan ada secangkir kopi panas di punggung yang tidak boleh tumpah.',
      imageAssetPath: 'assets/images/exercises/bird_dog.png',
    ),
    Exercise(
      id: 'single_leg_rdl',
      name: 'Single-Leg Romanian Deadlift (RDL)',
      targetMuscles: 'Hamstrings, Glutes, Stabilitas Pergelangan Kaki & Lutut',
      functionForHm: 'Menguatkan paha belakang yang bertugas menarik kaki ke belakang saat melangkah. Melatih keseimbangan proprioseptif telapak kaki.',
      formCues: 'Berdiri satu kaki. Condongkan badan ke depan dengan punggung lurus sambil kaki lainnya terangkat lurus ke belakang. Rasakan tarikan di paha belakang kaki penumpu, dorong pinggul ke depan untuk kembali tegak.',
      dosage: '3 Set x 8-10 Reps / kaki',
      importantNotes: 'Lutut kaki penumpu sedikit ditekuk (soft knee).',
      imageAssetPath: 'assets/images/exercises/single_leg_rdl.png',
    ),
    Exercise(
      id: 'wall_sit',
      name: 'Wall Sit (Isometric Hold)',
      targetMuscles: 'Quadriceps & Tendon Patella Lutut',
      functionForHm: 'Membangun ketahanan isometrik paha depan dan tendon patella untuk menahan impak lari jarak jauh di jalanan aspal keras Jakarta.',
      formCues: 'Sandarkan punggung ke dinding, turunkan badan hingga paha sejajar lantai (membentuk sudut 90 derajat seperti duduk di kursi tak kasat mata). Tahan posisi ini.',
      dosage: '3 Set x 45-60 Detik',
      importantNotes: 'Bernafas teratur. Jangan letakkan tangan di atas lutut.',
      imageAssetPath: 'assets/images/exercises/wall_sit.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        title: const Text('Kamus Strength Training Pelari', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (ctx, i) => ExerciseCard(exercise: exercises[i]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'mantra.dart';

class MantraData {
  static const List<Mantra> mantras = [
    Mantra(
      id: 'radhe_radhe',
      name: 'Radhe Radhe',
      imagePath: 'assets/images/radha.png',
      primaryColor: Colors.deepOrange,
      secondaryColor: Colors.orange,
    ),
    Mantra(
      id: 'om_namah_shivay',
      name: 'Om Namah Shivay',
      imagePath: 'assets/images/shiva.png',
      primaryColor: Colors.blue,
      secondaryColor: Colors.indigo,
    ),
    Mantra(
      id: 'shree_ram',
      name: 'Shree Ram Jay Ram Jay Jay Ram',
      imagePath: 'assets/images/ram.png',
      primaryColor: Colors.orange,
      secondaryColor: Colors.deepOrange,
    ),
    Mantra(
      id: 'om_namo_bhagwate',
      name: 'Om Namo Bhagwate Vasudevay',
      imagePath: 'assets/images/krishna.png',
      primaryColor: Colors.deepPurple,
      secondaryColor: Colors.purple,
    ),
    Mantra(
      id: 'om_gan_ganpate',
      name: 'Om Gan Ganpate Namo Namah',
      imagePath: 'assets/images/ganesha.png',
      primaryColor: Colors.red,
      secondaryColor: Colors.deepOrange,
    ),
    Mantra(
      id: 'om_hanumante',
      name: 'Om Hanumante Namah',
      imagePath: 'assets/images/hanuman.png',
      primaryColor: Colors.orange,
      secondaryColor: Colors.red,
    ),
    Mantra(
      id: 'gayatri_mantra',
      name: 'Gayatri Mantra',
      imagePath: 'assets/images/gayatri.png',
      primaryColor: Colors.yellow,
      secondaryColor: Colors.orange,
    ),
  ];

  static Mantra getMantraById(String id) {
    return mantras.firstWhere(
      (mantra) => mantra.id == id,
      orElse: () => mantras[0],
    );
  }
}

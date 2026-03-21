import 'package:latlong2/latlong.dart';

class MedicalCenter {
  final LatLng coords;
  final String name;
  final String address;
  final String mapsUrl;

  const MedicalCenter({
    required this.coords,
    required this.name,
    required this.address,
    required this.mapsUrl,
  });
}

const List<MedicalCenter> medicalCenters = [
  // Астана
  MedicalCenter(
    coords: LatLng(51.1684126, 71.4377708),
    name: 'Медицинский центр «Авиценна»',
    address: 'просп. Мәңгілік Ел, 55/21',
    mapsUrl: 'https://www.google.com/maps?q=51.1684126,71.4377708',
  ),
  MedicalCenter(
    coords: LatLng(51.110174, 71.4405484),
    name: 'Медицинский центр',
    address: 'район Сарыарка, Астана',
    mapsUrl: 'https://www.google.com/maps?q=51.110174,71.4405484',
  ),
  MedicalCenter(
    coords: LatLng(51.1458321, 71.391254),
    name: 'Медицинский центр',
    address: 'район Есиль, Астана',
    mapsUrl: 'https://www.google.com/maps?q=51.1458321,71.391254',
  ),
  MedicalCenter(
    coords: LatLng(51.1404791, 71.4816291),
    name: 'Медицинский центр',
    address: 'район Есиль, Астана',
    mapsUrl: 'https://www.google.com/maps?q=51.1404791,71.4816291',
  ),
  MedicalCenter(
    coords: LatLng(51.1318099, 71.4431659),
    name: 'Медицинский центр',
    address: 'ул. Сыганак, Астана',
    mapsUrl: 'https://www.google.com/maps?q=51.1318099,71.4431659',
  ),
  MedicalCenter(
    coords: LatLng(51.1584428, 71.4392943),
    name: 'Медицинский центр',
    address: 'просп. Мангилик Ел, Астана',
    mapsUrl: 'https://www.google.com/maps?q=51.1584428,71.4392943',
  ),
  MedicalCenter(
    coords: LatLng(51.1645947, 71.4210839),
    name: 'Медицинский центр',
    address: 'район Сарыарка, Астана',
    mapsUrl: 'https://www.google.com/maps?q=51.1645947,71.4210839',
  ),
  MedicalCenter(
    coords: LatLng(51.1141434, 71.419799),
    name: 'Медицинский центр «Асем»',
    address: 'ул. Кенесары, 40, Астана',
    mapsUrl: 'https://www.google.com/maps?q=51.1141434,71.419799',
  ),
  MedicalCenter(
    coords: LatLng(51.0968369, 71.4283003),
    name: 'Медицинский центр «Аура Мед»',
    address: 'ул. Кабанбай батыра, 60, Астана',
    mapsUrl: 'https://www.google.com/maps?q=51.0968369,71.4283003',
  ),
  // Алматы
  MedicalCenter(
    coords: LatLng(43.2279509, 76.9298164),
    name: 'Медицинский центр',
    address: 'Бостандыкский район, Алматы',
    mapsUrl: 'https://www.google.com/maps?q=43.2279509,76.9298164',
  ),
  MedicalCenter(
    coords: LatLng(43.2483956, 76.9242436),
    name: 'Медицинский центр',
    address: 'ул. Толе би / просп. Абая, Алматы',
    mapsUrl: 'https://www.google.com/maps?q=43.2483956,76.9242436',
  ),
  MedicalCenter(
    coords: LatLng(43.2588596, 76.9215298),
    name: 'Медицинский центр',
    address: 'район просп. Абая, Алматы',
    mapsUrl: 'https://www.google.com/maps?q=43.2588596,76.9215298',
  ),
  MedicalCenter(
    coords: LatLng(43.2647393, 76.9418947),
    name: 'Медицинский центр Аврора',
    address: 'ул. Тимирязева, 42, мкр. Самал-2, Алматы',
    mapsUrl: 'https://www.google.com/maps?q=43.2647393,76.9418947',
  ),
  MedicalCenter(
    coords: LatLng(43.1954553, 76.9166263),
    name: 'Медицинский центр',
    address: 'ул. Кабанбай батыра, 87, Алматы',
    mapsUrl: 'https://www.google.com/maps?q=43.1954553,76.9166263',
  ),
  MedicalCenter(
    coords: LatLng(43.2607363, 76.9382604),
    name: 'Медицинский центр',
    address: 'Бостандыкский район, Алматы',
    mapsUrl: 'https://www.google.com/maps?q=43.2607363,76.9382604',
  ),
  MedicalCenter(
    coords: LatLng(43.2631766, 76.9407591),
    name: 'Медицинский центр',
    address: 'ул. Калдаякова, 2, Алматы',
    mapsUrl: 'https://www.google.com/maps?q=43.2631766,76.9407591',
  ),
  MedicalCenter(
    coords: LatLng(43.2625185, 76.917988),
    name: 'Медицинский центр',
    address: 'Бостандыкский район, Алматы',
    mapsUrl: 'https://www.google.com/maps?q=43.2625185,76.917988',
  ),
  MedicalCenter(
    coords: LatLng(43.259426, 76.923469),
    name: 'Медицинский центр «Аймед»',
    address: 'ул. Кунаева, 21Б, Алматы',
    mapsUrl: 'https://www.google.com/maps?q=43.259426,76.923469',
  ),
  MedicalCenter(
    coords: LatLng(43.2531557, 76.9462131),
    name: 'Медицинский центр',
    address: 'район просп. Достык, Алматы',
    mapsUrl: 'https://www.google.com/maps?q=43.2531557,76.9462131',
  ),
  MedicalCenter(
    coords: LatLng(43.2441716, 76.9029286),
    name: 'Медицинский центр',
    address: 'район ул. Тимирязева, Алматы',
    mapsUrl: 'https://www.google.com/maps?q=43.2441716,76.9029286',
  ),
  MedicalCenter(
    coords: LatLng(43.257839, 76.936721),
    name: 'Медицинский центр',
    address: 'район просп. Аль-Фараби, Алматы',
    mapsUrl: 'https://www.google.com/maps?q=43.257839,76.936721',
  ),
  MedicalCenter(
    coords: LatLng(43.2491872, 76.9153096),
    name: 'Медицинский центр',
    address: 'Бостандыкский район, Алматы',
    mapsUrl: 'https://www.google.com/maps?q=43.2491872,76.9153096',
  ),
];

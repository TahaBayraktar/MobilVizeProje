import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main ()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taha Bayraktar Kütüphane',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white10),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Taha Bayraktar Kütüphane'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  final _firestore=FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    CollectionReference sayiref=_firestore.collection("Kitap");
    return Scaffold(
      appBar:PreferredSize(
        preferredSize: Size.fromHeight(30.0),
        child: AppBar(
          backgroundColor: Colors.blue,
          title: Text(widget.title),
        ),
      ),
      body: Center(
          child: Container(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StreamBuilder<QuerySnapshot>(
                      stream: sayiref.snapshots(),
                      builder:(BuildContext context, AsyncSnapshot asyncSnapshot){
                        if(asyncSnapshot.hasError){
                          return Center(child: Text("Bir hata oluştu tekrar deneyiniz."),);
                        }
                        else{
                          if(asyncSnapshot.hasData){
                            List<DocumentSnapshot> listOfDocumentSnap=asyncSnapshot.data.docs;
                            return Flexible(
                              child: ListView.builder(
                                itemCount:listOfDocumentSnap.length,
                                itemBuilder: (context,index)
                                {
                                  bool goruncekmi=(listOfDocumentSnap[index].data() as Map<String, dynamic>)?["goruncekmi"] ?? false;
                                  if (goruncekmi==false) {
                                    return Container(); //
                                  }
                                  return Card(
                                      child:Container(
                                        color: Colors.white,
                                        height: 60,
                                        child: ListTile(
                                            title:
                                            Text(
                                                '${"kitap adı:"+(listOfDocumentSnap[index].data() as Map<String, dynamic>)?["ad"] ?? "Belirtilen Değer Yok"}',
                                                style:TextStyle(fontSize:12,fontWeight: FontWeight.w800)),
                                            subtitle: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: [
                                                  Text(
                                                      '${"yazar adı:"+(listOfDocumentSnap[index].data() as Map<String, dynamic>)?["yazar"] ?? "Belirtilen Değer Yok"}',
                                                      style: TextStyle(fontSize:10,)    //fontWeight: FontWeight),
                                                  ),
                                                  SizedBox(
                                                    width: 5.0,
                                                  ),
                                                  Text(
                                                    'Sayfa sayısı: ${(listOfDocumentSnap[index].data() as Map<String, dynamic>)?["sayfa"] ?? "Belirtilen Değer Yok"}.',
                                                    style: TextStyle(fontSize: 10),
                                                  )
                                                ],
                                              ),
                                            ),
                                            trailing:Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children:[
                                                  IconButton(
                                                    icon: Icon(Icons.edit),
                                                    onPressed: () async {
                                                      await listOfDocumentSnap[index].reference.delete();
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => Ekle()),
                                                      );
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.delete),
                                                    onPressed: () async {
                                                      bool deleteConfirmed = await showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            title: Text('Silme İşlemi'),
                                                            content: Text('Bu öğeyi silmek istediğinizden emin misiniz?'),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(context).pop(false);
                                                                },
                                                                child: Text('Hayır'),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(context).pop(true);
                                                                },
                                                                child: Text('Evet'),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                      if (deleteConfirmed == true) {
                                                        await listOfDocumentSnap[index].reference.delete();
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text('Silme İşlemi Tamamlandı'),
                                                          ),
                                                        );

                                                      }
                                                      else{
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text('Silme İşlemi Tamamlanmadı!!!!'),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ]
                                            )
                                        ),
                                      )
                                  );
                                },
                              ),
                            );
                          }else{
                            return Center(child:CircularProgressIndicator());
                          }
                        }
                      }
                  ),
                ],
              ),

          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Ekle()),
          );
        },
        backgroundColor: Colors.black54,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Kitaplar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Satın Al',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}
class Ekle extends StatefulWidget {
  @override
  Eklepaket createState() => Eklepaket();
}
class Eklepaket extends State<Ekle> {
  final _firestore=FirebaseFirestore.instance;
  final TextEditingController kitapAd=TextEditingController();
  final TextEditingController yazarAd=TextEditingController();
  final TextEditingController sayfa=TextEditingController();
  final TextEditingController yil=TextEditingController();
  final TextEditingController yayinevi=TextEditingController();
  bool Secildimi = false;
  String secilenKategori = 'Roman'; // Varsayılan kategori
  final List<String> kategoriler = [
    'Roman',
    'Tarih',
    'Edebiyat',
    'Şiir',
    'Ansiklopedi',
  ];
  @override
  Widget build(BuildContext context) {
    var kitapref=_firestore.collection("Kitap");
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0),
        child: AppBar(
            backgroundColor: Colors.blue,
          title: Text('Kitap Ekle'),
          automaticallyImplyLeading: false,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:10.0),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: kitapAd,
                          decoration: InputDecoration(
                            labelText: 'Kitap adını giriniz',
                          ),
                        ),
                        TextFormField(
                          controller: yayinevi,
                          decoration: InputDecoration(
                            labelText: 'Yayinevi adınız giriniz',
                          ),
                        ),
                        TextFormField(
                          controller: yazarAd,
                          decoration: InputDecoration(
                            labelText: 'Yazar adını giriniz',
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 55,
                          child: Row(
                            children: [
                              Text(
                                'Kategori: ',
                                style: TextStyle(fontSize: 16),
                              ),
                              Expanded(
                                child: DropdownButton<String>(
                                  value: secilenKategori,
                                  items: kategoriler.map((kategori) {
                                    return DropdownMenuItem<String>(
                                      value: kategori,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(kategori),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? yeniDeger) {
                                    setState(() {
                                      secilenKategori = yeniDeger!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextFormField(
                          controller: sayfa,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Sayfa sayısını giriniz',
                          ),
                        ),
                        TextFormField(
                          controller: yil,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Basım yılını griniz',
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(height: 16),
                            Text(
                              'Kitap yayınlansın mı?',
                            ),
                            Checkbox(
                              value: Secildimi,
                              onChanged: (value) {
                                setState(() {
                                  Secildimi = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Text("Kaydet"),
        onPressed: () async{
          String sayfayazi = sayfa.text;
          String yilyazi=yil.text;
          int? sayfaInt = int.tryParse(sayfayazi);
          int? yilInt = int.tryParse(yilyazi);
          if (sayfaInt != null && yilInt != null &&
               yazarAd.text!=null&& yayinevi.text!=null&& kitapAd.text!=null) {
            Map<String,dynamic> sayfaData={"sayfa":sayfaInt,"ad":kitapAd.text,
              "yazar":yazarAd.text,"yayınevi":yayinevi.text,"yil":yilInt,"kategori":secilenKategori,"goruncekmi":Secildimi};
            DateTime now = DateTime.now();
            await kitapref.doc("$now").set(sayfaData);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kitap kaydedildi'),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lütfen sayı istenen değerlere sayı giriniz ve bütün alanları'
                    'doldurunuz.'),
              ),
            );
          }
        },
        backgroundColor: Colors.black45,
      ),
    );
  }
}
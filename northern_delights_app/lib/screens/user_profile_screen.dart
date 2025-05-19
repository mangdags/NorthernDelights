import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:northern_delights_app/screens/home_screen.dart';
import 'package:northern_delights_app/screens/pin_location_screen.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';



class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController shopNameController;
  late TextEditingController pointsController;

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _overviewController = TextEditingController();
  late Timestamp openingTime = Timestamp.fromDate(DateTime(2000, 1, 1, 9, 0));
  late Timestamp closingTime = Timestamp.fromDate(DateTime(2000, 1, 1, 17, 0));
  late TimeOfDay openTimeOfDay;
  late TimeOfDay closeTimeOfDay;
  late String storeType;
  late String location;

  late bool isAdmin;
  late bool isSeller;
  bool isLoading = true;

  List<File> _selectedImages = [];

  String? _imageUrl;
  bool isUploading = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    openTimeOfDay = TimeOfDay(hour: 9, minute: 0);
    closeTimeOfDay = TimeOfDay(hour: 17, minute: 0);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await _firestore.collection('users').doc(widget.userId).get();
    isSeller = doc['isSeller'] ? true : false;

    if (doc.exists) {
      setState(() {
        firstNameController = TextEditingController(text: doc['first_name'] ?? '');
        lastNameController = TextEditingController(text: doc['last_name'] ?? '');
        shopNameController = TextEditingController(text: doc['shop_name'] ?? '');
        pointsController = isSeller ? TextEditingController(text: '') : TextEditingController(text: doc['points']?.toString() ?? '0');
        _imageUrl = doc['image_url'] ?? '';
        isLoading = false;
      });
    }
    if (isSeller){
      storeType = doc['store_type'];
      _loadStoreData(storeType);
    } else {
      storeType = 'users';
    }
  }

  Future<void> _loadStoreData(String type) async {
    final doc = await _firestore.collection(type).doc(widget.userId).get();

    if (doc.exists) {
      setState(() {
        openingTime = doc['open_time'] ?? Timestamp.fromDate(DateTime(2000, 1, 1, 0, 0));
        closingTime = doc['close_time'] ?? Timestamp.fromDate(DateTime(2000, 1, 1, 0, 0));

        openTimeOfDay = convertToTimeOfDay(openingTime);
        closeTimeOfDay = convertToTimeOfDay(closingTime);

        _locationController.text = doc['location'] ?? '';
        _overviewController.text = doc['overview'] ?? '';

        isLoading = false;
      });
    } else {
      setState(() {
        openTimeOfDay = TimeOfDay(hour: 0, minute: 0);
        closeTimeOfDay = TimeOfDay(hour: 0, minute: 0);
        isLoading = false;
      });
    }
  }

  Future<void> _updateProfile(bool isSeller, String type) async {
    final double? latitude = double.tryParse(_latController.text);
    final double? longitude = double.tryParse(_longController.text);

    final selectedOpenTime = _selectedOpenTime != null
        ? convertToDateTime(_selectedOpenTime!)
        : convertToDateTime(openTimeOfDay);

    final selectedCloseTime = _selectedCloseTime != null
        ? convertToDateTime(_selectedCloseTime!)
        : convertToDateTime(closeTimeOfDay);

    final openTimestamp = Timestamp.fromDate(selectedOpenTime);
    final closeTimestamp = Timestamp.fromDate(selectedCloseTime);

    if(isSeller) {
      if(storeType == 'both') {
        await FirebaseFirestore.instance.collection('restaurants').doc(widget.userId).update({
          'name' : shopNameController.text,
          'open_time': openTimestamp,
          'close_time': closeTimestamp,
          'location' : _locationController.text,
          'overview' : _overviewController.text,
        });

        await FirebaseFirestore.instance.collection('gastropubs').doc(widget.userId).update({
          'name' : shopNameController.text,
          'open_time': openTimestamp,
          'close_time': closeTimestamp,
          'location' : _locationController.text,
          'overview' : _overviewController.text,
        });


        await _uploadImages('restaurants');
        await _uploadImages('gastropubs');

      } else {
        await FirebaseFirestore.instance.collection(type).doc(widget.userId).update({
          'name' : shopNameController.text,
          'open_time': openTimestamp,
          'close_time': closeTimestamp,
          'location' : _locationController.text,
          'overview' : _overviewController.text,
        });

        await _uploadImages(storeType);

      }
    } else {
      await _firestore.collection('users').doc(widget.userId).update({
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
      });

      await _uploadImages('users');
    }

    if(!isUploading){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  DateTime convertToDateTime(TimeOfDay? timeOfDay) {
    if (timeOfDay == null) {
      return DateTime.now();
    }
    final now = DateTime.now();
    return DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }


  TimeOfDay convertToTimeOfDay(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }


  TimeOfDay? _selectedOpenTime;
  TimeOfDay? _selectedCloseTime;

  Future<void> _selectOpenTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedOpenTime ?? TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedOpenTime = picked;
      });
    }
  }

  bool isOpenTimeSelected() {
    return _selectedOpenTime != null;
  }

  Future<void> _selectCloseTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedCloseTime ?? TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedCloseTime = picked;
      });
    }
  }

  bool isCloseTimeSelected() {
    return _selectedCloseTime != null;
  }

  String convertToDateString(TimeOfDay? timeOfDay) {
    if (timeOfDay == null) {
      return '00:00';
    }
    final hours = timeOfDay.hourOfPeriod;
    final minutes = timeOfDay.minute;
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hours:${minutes.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _imagePicker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      List<File> validFiles = [];

      for (var xFile in pickedFiles) {
        File file = File(xFile.path);

        final fileSize = await file.length();
        if (fileSize <= 3000000) { // 3MB
          validFiles.add(file);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('One or more images exceed 3MB and were skipped.')),
          );
        }
      }

      setState(() {
        _selectedImages = validFiles;
      });
    }
  }




  Future<void> _uploadImages(String storeType) async {
    if (_selectedImages.isEmpty || isUploading) return;

    setState(() {
      isUploading = true;
    });

    try {
      List<String> uploadedUrls = [];

      for (int i = 0; i < _selectedImages.length; i++) {
        final folder = widget.userId;
        final originalFile = File(_selectedImages[i].path);
        final fileName = '${widget.userId}_${DateTime.now()}_$i.jpg';
        final storageRef = _storage.ref().child('$storeType/$folder/$fileName');

        final dir = await getTemporaryDirectory();
        final targetPath = path.join(dir.absolute.path, 'temp_$fileName');

        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          originalFile.path,
          targetPath,
          quality: 80,
          format: CompressFormat.jpeg,
        );

        if (compressedFile == null) {
          throw Exception('Failed to compress image $i');
        }

        final uploadTask = await storageRef.putFile(File(compressedFile.path));
        final imageUrl = await uploadTask.ref.getDownloadURL();
        uploadedUrls.add(imageUrl);
      }

      await _firestore.collection('users').doc(widget.userId).update({
        'image_urls': uploadedUrls,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Images uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(_selectedImages[index]),
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: _pickImages,
                child: const Text("Select Images"),
              ),

              const SizedBox(height: 20),
              Offstage(
                offstage: isSeller,
                child:
                Text('Points: ${pointsController.text}'),
              ),
              const SizedBox(height: 20,),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              const SizedBox(height: 12),

              // IS SELLER
              if (isSeller) ...[
                TextField(
                  controller: shopNameController,
                  decoration: const InputDecoration(labelText: 'Shop Name'),
                ),
                const SizedBox(height: 20),

                const Divider(
                  color: Colors.grey,
                  thickness: 1.5,
                  indent: 20.0,
                  endIndent: 20.0,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Opening: ${_selectedOpenTime != null ? convertToDateString(_selectedOpenTime!)
                              : convertToDateString(openTimeOfDay)}',
                          style: TextStyle(fontSize: 16),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectOpenTime(context),
                          child: Text('Opening Time'),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Closing: ${_selectedCloseTime != null ? convertToDateString(_selectedCloseTime!)
                              : convertToDateString(closeTimeOfDay)}',
                          style: TextStyle(fontSize: 16),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectCloseTime(context),
                          child: Text('Closing Time'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Divider for separation
                const Divider(
                  color: Colors.grey,
                  thickness: 1.5,
                  indent: 20.0,
                  endIndent: 20.0,
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PinLocationScreen(sellerId: widget.userId, storeType: storeType)));
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(300, 50),
                  ),
                  child: const Text('Set Location'),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                ),

                const SizedBox(height: 20,),
                TextField(
                  maxLines: 10,
                  controller: _overviewController,
                  decoration: InputDecoration(
                    labelText: 'Overview',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: isUploading
                      ? null
                      : () => _updateProfile(isSeller, storeType),
                    child: isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes'),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: isUploading
                      ? null
                      : () => _updateProfile(isSeller, storeType),
                  child: isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes'),
                ),
              ],
              // IS SELLER END
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

    );
  }
}

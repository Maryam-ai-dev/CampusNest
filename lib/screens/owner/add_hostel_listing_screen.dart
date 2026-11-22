import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class AddHostelListingScreen extends StatefulWidget {
  const AddHostelListingScreen({super.key});

  @override
  State<AddHostelListingScreen> createState() => _AddHostelListingScreenState();
}

class _AddHostelListingScreenState extends State<AddHostelListingScreen> {
  // Design colors matching CampusNest theme
  static const Color _bgColor = Color(0xFFFBF7F2);
  static const Color _cardBg = Color(0xFFFFFFFF);
  static const Color _borderColor = Color(0xFFEAE4DC);
  static const Color _primaryRust = Color(0xFFB85021);
  static const Color _textDark = Color(0xFF1A1918);
  static const Color _textMuted = Color(0xFF8C857E);
  static const Color _labelColor = Color(0xFF6F6A65);
  static const Color _photoPlaceholderFill = Color(0xFFECE4D8);

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final List<Uint8List> _pickedPhotos = [];
  final _hostelNameCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _vacantRoomsCtrl = TextEditingController();

  final List<String> _facilities = [
    'AC',
    'WiFi',
    'Laundry',
    'Attached Bath',
  ];

  // Default selected chips like the design (AC & WiFi active)
  final Set<String> _selectedFacilities = {'AC', 'WiFi'};

  // Placeholder slots for uploaded/preview photos
  int _extraPhotoSlots = 2;

  @override
  void dispose() {
    _hostelNameCtrl.dispose();
    _rentCtrl.dispose();
    _depositCtrl.dispose();
    _locationCtrl.dispose();
    _vacantRoomsCtrl.dispose();
    super.dispose();
  }

  Future<void> _onAddPhotoTap() async {
  try {
    final List<XFile> files = await _picker.pickMultiImage(
      imageQuality: 80,
    );
    if (files.isEmpty) return;

    final List<Uint8List> newBytes = [];
    for (final file in files) {
      newBytes.add(await file.readAsBytes());
    }

    if (!mounted) return;
    setState(() {
      _pickedPhotos.addAll(newBytes);
    });
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Could not pick photo: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

  void _onSubmitForReview() {
    if (!_formKey.currentState!.validate()) return;

    final listingData = {
      'hostelName': _hostelNameCtrl.text.trim(),
      'rentPerMonth': _rentCtrl.text.trim(),
      'deposit': _depositCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'facilities': _selectedFacilities.toList(),
      'vacantRooms': int.tryParse(_vacantRoomsCtrl.text.trim()) ?? 0,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: _primaryRust,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Submitted "${listingData['hostelName']}" for review!',
          ),
        ),
      );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
          color: _labelColor,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        color: _textDark,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: _textMuted,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: _cardBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryRust, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

 Widget _buildPhotosRow() {
  final int totalSlots = _pickedPhotos.isEmpty
      ? 3
      : 1 + _pickedPhotos.length;

  return SizedBox(
    height: 76,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: totalSlots,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return InkWell(
            onTap: _onAddPhotoTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD8D0C5), width: 1.3),
              ),
              child: const Center(
                child: Icon(
                  Icons.file_upload_outlined,
                  color: _labelColor,
                  size: 24,
                ),
              ),
            ),
          );
        }

        if (_pickedPhotos.isEmpty) {
          return Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF3ECE2),
                  _photoPlaceholderFill,
                ],
              ),
            ),
          );
        }

        final int photoIndex = index - 1;
        final Uint8List imageBytes = _pickedPhotos[photoIndex];

        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                imageBytes,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _pickedPhotos.removeAt(photoIndex);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
         

  Widget _buildFacilitiesChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _facilities.map((facility) {
        final isSelected = _selectedFacilities.contains(facility);
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedFacilities.remove(facility);
              } else {
                _selectedFacilities.add(facility);
              }
            });
          },
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? _primaryRust : _cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? _primaryRust : _borderColor,
                width: 1.2,
              ),
            ),
            child: Text(
              facility,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : _labelColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 52,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: _textDark,
            size: 28,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Add Hostel Listing',
          style: TextStyle(
            color: _textDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('Photos'),
                _buildPhotosRow(),
                const SizedBox(height: 22),

                _buildSectionLabel('Hostel Name'),
                _buildInputField(
                  controller: _hostelNameCtrl,
                  hint: 'Al-Noor Boys Hostel',
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Please enter hostel name'
                      : null,
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('Rent / Mo'),
                          _buildInputField(
                            controller: _rentCtrl,
                            hint: 'Rs 18,000',
                            keyboardType: TextInputType.number,
                            validator: (val) =>
                                (val == null || val.trim().isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('Deposit'),
                          _buildInputField(
                            controller: _depositCtrl,
                            hint: 'Rs 15,000',
                            keyboardType: TextInputType.number,
                            validator: (val) =>
                                (val == null || val.trim().isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildSectionLabel('Location'),
                _buildInputField(
                  controller: _locationCtrl,
                  hint: 'Near NUST Gate 2, H-12',
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Please enter location'
                      : null,
                ),
                const SizedBox(height: 20),

                _buildSectionLabel('Facilities'),
                _buildFacilitiesChips(),
                const SizedBox(height: 20),

                _buildSectionLabel('Vacant Rooms'),
                _buildInputField(
                  controller: _vacantRoomsCtrl,
                  hint: '4',
                  keyboardType: TextInputType.number,
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Please enter vacant rooms count'
                      : null,
                ),
                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _onSubmitForReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryRust,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Submit for Review',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
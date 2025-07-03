import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feup_rides/schedule_screen.dart';
import 'package:feup_rides/home.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'car_page.dart';

class UserProfilePage extends StatefulWidget {
  final String userUid;

  const UserProfilePage({Key? key, required this.userUid}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isDriver = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('Users').doc(widget.userUid).get();
      if (userSnapshot.exists) {
        final Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
        if (userData != null) {
          setState(() {
            _firstNameController.text = userData['firstName'] ?? '';
            _lastNameController.text = userData['lastName'] ?? '';
            _addressController.text = userData['address'] ?? '';
            _isDriver = userData['isDriver'] ?? false;
          });
        }
      }
    } catch (e) {
      print("Error loading user profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child:const Text('User Profile')),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditableField('First Name', _firstNameController, true),
                  _buildEditableField('Last Name', _lastNameController, true),
                  _buildEditableField('Address', _addressController, false),
                  _buildEditableCheckbox('Driver?', _isDriver),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SchedulePage(userUid: widget.userUid)));
                        },
                        child: const Text('My schedule'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CarPage(userUid: widget.userUid)));
                        },
                        child: const Text('My Car'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveProfileChanges,
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, bool required) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (required && (value == null || value.isEmpty)) {
              return '$label is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEditableCheckbox(String label, bool value) {
    return CheckboxListTile(
      title: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      value: value,
      onChanged: (newValue) {
        setState(() {
          _isDriver = newValue ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _saveProfileChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final DocumentReference userDocRef = FirebaseFirestore.instance.collection('Users').doc(widget.userUid);
        await userDocRef.update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'address': _addressController.text,
          'isDriver': _isDriver,
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyHomePage(userUid: widget.userUid)));
      } catch (e) {
        print("Error saving profile changes: $e");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update profile')));
      }
    }
  }
}

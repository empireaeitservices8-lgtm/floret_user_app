import 'package:flutter/material.dart';
import 'package:floret_app/providers/view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../repos/profile_repository.dart';

class ContactSupportViewModel extends ViewModel {
  final ProfileRepository _repository;

  ContactSupportViewModel({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  String _selectedInquiry = 'General Enquiry';
  bool _hasValidated = false;

  String? _nameError;
  String? _emailError;
  String? _subjectError;
  String? _messageError;

  final List<String> inquiryTypes = const [
    'General Enquiry',
    'Schedule Pickup',
    'Billing Issue',
    'Technical Support',
    'Feedback',
    'Other',
  ];

  String get selectedInquiry => _selectedInquiry;
  bool get hasValidated => _hasValidated;
  String? get nameError => _nameError;
  String? get emailError => _emailError;
  String? get subjectError => _subjectError;
  String? get messageError => _messageError;

  void setInquiryType(String type) {
    if (_selectedInquiry != type) {
      _selectedInquiry = type;
      notifyListeners();
    }
  }

  void onNameChanged(String val) {
    if (_hasValidated) {
      _nameError = val.trim().isEmpty ? 'Required' : null;
      notifyListeners();
    }
  }

  void onEmailChanged(String val) {
    if (_hasValidated) {
      if (val.trim().isEmpty) {
        _emailError = 'Required';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
        _emailError = 'Invalid email address';
      } else {
        _emailError = null;
      }
      notifyListeners();
    }
  }

  void onSubjectChanged(String val) {
    if (_hasValidated) {
      _subjectError = val.trim().isEmpty ? 'Required' : null;
      notifyListeners();
    }
  }

  void onMessageChanged(String val) {
    if (_hasValidated) {
      _messageError = val.trim().isEmpty ? 'Required' : null;
      notifyListeners();
    }
  }

  bool validateForm() {
    _hasValidated = true;
    bool isValid = true;

    if (nameController.text.trim().isEmpty) {
      _nameError = 'Required';
      isValid = false;
    } else {
      _nameError = null;
    }

    final email = emailController.text.trim();
    if (email.isEmpty) {
      _emailError = 'Required';
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _emailError = 'Invalid email address';
      isValid = false;
    } else {
      _emailError = null;
    }

    if (subjectController.text.trim().isEmpty) {
      _subjectError = 'Required';
      isValid = false;
    } else {
      _subjectError = null;
    }

    if (messageController.text.trim().isEmpty) {
      _messageError = 'Required';
      isValid = false;
    } else {
      _messageError = null;
    }

    notifyListeners();
    return isValid;
  }

  Future<void> makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '9292023601');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      debugPrint('Error launching phone dialer: $e');
    }
  }

  Future<void> sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'florettechnologies@gmail.com',
      queryParameters: {
        'subject': 'Support Request - Safai 360',
      },
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(emailUri);
      }
    } catch (e) {
      debugPrint('Error launching email client: $e');
    }
  }

  Future<void> openWhatsApp() async {
    final Uri nativeUri = Uri.parse(
      'whatsapp://send?phone=919292023601&text=Hello%20Safai%20360%20Support',
    );
    final Uri webUri = Uri.parse(
      'https://wa.me/919292023601?text=Hello%20Safai%20360%20Support',
    );

    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (ex) {
        debugPrint('Error launching WhatsApp: $ex');
      }
    }
  }

  Future<void> openOfficeLocation() async {
    final Uri webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=Ernakulam,+Kerala',
    );
    try {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }

  Future<bool> submitMessage({
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    if (!validateForm()) {
      onError('Please fill in all required fields');
      return false;
    }

    try {
      showLoading();
      await _repository.submitSupportTicket(
        subject: subjectController.text.trim(),
        message: messageController.text.trim(),
      );
      hideLoading();

      nameController.clear();
      phoneController.clear();
      emailController.clear();
      subjectController.clear();
      messageController.clear();
      _hasValidated = false;
      _nameError = null;
      _emailError = null;
      _subjectError = null;
      _messageError = null;
      _selectedInquiry = 'General Enquiry';
      notifyListeners();

      onSuccess();
      return true;
    } catch (_) {
      hideLoading();
      onError('Failed to send message. Please try again.');
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }
}

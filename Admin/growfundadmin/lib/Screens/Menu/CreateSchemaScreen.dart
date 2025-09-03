import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../API/API.dart';

class CreateSchemaScreen extends StatefulWidget {
  const CreateSchemaScreen({super.key});

  @override
  State<CreateSchemaScreen> createState() => _CreateSchemaScreenState();
}

class _CreateSchemaScreenState extends State<CreateSchemaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _roi = TextEditingController();
  final TextEditingController _duration = TextEditingController();
  final TextEditingController _money = TextEditingController();
  final TextEditingController _maturityAmount = TextEditingController();

  String? _schemaType;
  DateTime? _startDate;
  File? _pickedFile;

  // Pick Start Date
  void _pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  // Pick File
  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _pickedFile = File(result.files.single.path!));
    }
  }

  @override
  void initState() {
    super.initState();
    _money.addListener(_calculateMaturityAmount);
    _roi.addListener(_calculateMaturityAmount);
    _duration.addListener(_calculateMaturityAmount);
  }

  @override
  void dispose() {
    _money.dispose();
    _roi.dispose();
    _duration.dispose();
    _name.dispose();
    _desc.dispose();
    _maturityAmount.dispose();
    super.dispose();
  }

  void _calculateMaturityAmount() {
    double principal = double.tryParse(_money.text) ?? 0.0;
    double roi = double.tryParse(_roi.text) ?? 0.0;
    double duration = double.tryParse(_duration.text) ?? 0.0;

    double years = _schemaType == "Monthly" ? duration / 12 : duration;

    double maturity = principal + (principal * roi * years / 100);
    _maturityAmount.text = maturity.toStringAsFixed(2);
  }

  // Preview Schema
  void _previewSchema() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('📋 Preview Schema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _previewRow('Name', _name.text),
              _previewRow('Description', _desc.text),
              _previewRow('Money', _money.text),
              _previewRow('ROI', _roi.text),
              _previewRow('Duration', _duration.text),
              _previewRow('Type', _schemaType ?? ''),
              _previewRow('Start Date', _startDate != null ? _startDate.toString().split(' ')[0] : 'Not selected'),
              _pickedFile != null
                  ? const Text("📎 File attached", style: TextStyle(color: Colors.green))
                  : const Text("❌ No file attached", style: TextStyle(color: Colors.red)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      );
    }
  }

  // Helper function for preview row
  Widget _previewRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Submit the schema
  void _submit({bool isDraft = false}) async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await ApiService.submitSchema(
          name: _name.text,
          description: _desc.text,
          amount: _money.text,
          maturityAmount: _maturityAmount.text,
          roi: _roi.text,
          duration: _duration.text,
          type: _schemaType ?? '',
          startDate: _startDate!.toIso8601String().split('T')[0],
          file: _pickedFile,
        );

        // Handle successful response
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isDraft ? "Saved as Draft" : "Schema Submitted")),
          );
          Navigator.pop(context);
        } else {
          // Handle failed response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit schema: ${response.body}')),
          );
        }
      } catch (e) {
        // Handle errors during the API call
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }


  // Build text fields
  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (val) => val == null || val.isEmpty ? "Required" : null,
      ),
    );
  }

  // Build Start Date Picker Widget
  Widget _buildStartDatePicker() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text("Start Date"),
      subtitle: Text(
        _startDate != null ? _startDate.toString().split(' ')[0] : 'No date selected',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.calendar_month),
        onPressed: _pickStartDate,
      ),
    );
  }

  // Build File Upload Button
  Widget _buildFileUploadButton() {
    return ElevatedButton.icon(
      onPressed: _pickFile,
      icon: const Icon(Icons.attach_file),
      label: Text(_pickedFile != null ? "File Attached" : "Upload Flyer / Document"),
      style: ElevatedButton.styleFrom(
        backgroundColor: _pickedFile != null ? Colors.green : Colors.blue,
      ),
    );
  }

  // Build Schema Type Dropdown
  Widget _buildSchemaTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _schemaType,
      items: const [
        DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
        DropdownMenuItem(value: 'Yearly', child: Text('Yearly')),
      ],
      decoration: const InputDecoration(labelText: 'Schema Type'),
      onChanged: (val) {
        setState(() {
          _schemaType = val;
          _calculateMaturityAmount();
        });
      },
      validator: (val) => val == null ? "Required" : null,
    );
  }
  Widget _buildReadOnlyField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFE9ECEF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Center(
        child: Container(
          width: 800, // Adjust width for better layout
          margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          padding: const EdgeInsets.all(34),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("📄 Create New Schema", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildTextField(_name, "Schema Name"),
                  _buildTextField(_desc, "Description", maxLines: 3),
                  _buildTextField(_money, "Total Amount (₹)", inputType: TextInputType.number),
                  _buildTextField(_roi, "ROI %", inputType: TextInputType.number),
                  _buildTextField(_duration, "Duration (months/years)", inputType: TextInputType.number),
                  _buildReadOnlyField(_maturityAmount, "Maturity Amount (₹)"),
                  _buildSchemaTypeDropdown(),
                  const SizedBox(height: 16),
                  _buildStartDatePicker(),
                  const SizedBox(height: 12),
                  _buildFileUploadButton(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _previewSchema,
                        icon: const Icon(Icons.remove_red_eye),
                        label: const Text("Preview"),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => _submit(isDraft: true),
                            child: const Text("Save as Draft"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _submit(),
                            child: const Text("Submit"),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

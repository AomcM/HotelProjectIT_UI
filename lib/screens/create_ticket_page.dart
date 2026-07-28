import 'package:flutter/material.dart';
import '../models/department.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';



class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
final _formKey = GlobalKey<FormState>();
final ApiService apiService = ApiService();
final _titleController = TextEditingController();
final _descriptionController = TextEditingController();
List<Department> departments = [];
int? selectedDepartmentId;
@override
void initState() {
  super.initState();

  loadDepartments();
}
Future<void> loadDepartments() async {

  departments = await apiService.getDepartments();

  setState(() {});

}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Ticket"),
      ),

     body: Padding(
  padding: const EdgeInsets.all(16),
  child: Form(
    key: _formKey,
    child: Column(
      children: [

  TextFormField(
    controller: _titleController,
    decoration: const InputDecoration(
      labelText: "Title",
      border: OutlineInputBorder(),
    ),
  ),

  const SizedBox(height: 16),

  TextFormField(
    controller: _descriptionController,
    maxLines: 4,
    decoration: const InputDecoration(
      labelText: "Description",
      border: OutlineInputBorder(),
    ),
  ),

const SizedBox(height: 16),

DropdownButtonFormField<int>(
  value: selectedDepartmentId,
  decoration: const InputDecoration(
    labelText: "Department",
    border: OutlineInputBorder(),
  ),
  items: departments.map((department) {
    return DropdownMenuItem<int>(
      value: department.departmentId,
      child: Text(department.departmentName),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      selectedDepartmentId = value;
    });
  },
),

const SizedBox(height: 20),

SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () async {
      

  if (selectedDepartmentId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a department"),
      ),
    );
    return;
  }

  Ticket ticket = Ticket(
  title: _titleController.text,
  description: _descriptionController.text,
  priority: "",
  status: "",
  userId: 4,
  technicianId: null,
  departmentId: selectedDepartmentId!,

  category: "",
  suggestedPriority: "",
  suggestedSolution: "",
);
  bool success = await apiService.createTicket(ticket);
  if (!mounted) return;
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Ticket submitted successfully"),
      ),
    );

    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Failed to submit ticket"),
      ),
    );
  }


    },
    child: const Text("Submit Ticket"),
  ),
),
      ],
    ),
  ),
),
    );
  }
}
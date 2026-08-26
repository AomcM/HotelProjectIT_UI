import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/department.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class CreateTicketPage extends StatefulWidget {
  final Ticket? ticket;

  const CreateTicketPage({
    super.key,
    this.ticket,
  });

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
  String? selectedDepartmentName;

  String role = "";
  bool isLoadingProfile = true;

  /// True when this employee's department should be locked (auto-filled,
  /// not user-selectable): creating a brand-new ticket, as an employee.
  bool get lockDepartment => role.toLowerCase() == "employee" && widget.ticket == null;

  @override
  void initState() {
    super.initState();

    if (widget.ticket != null) {
      _titleController.text = widget.ticket!.title;
      _descriptionController.text = widget.ticket!.description;
      selectedDepartmentId = widget.ticket!.departmentId;
    }

    _loadProfileAndDepartments();
  }

  Future<void> _loadProfileAndDepartments() async {
    final prefs = await SharedPreferences.getInstance();
    role = prefs.getString("role") ?? "";

    // Always load the full department list first — we need it either way:
    // to resolve the employee's department name -> id, or to populate
    // the dropdown for other roles / edit mode.
    departments = await apiService.getDepartments();

    // For a new ticket created by an employee, resolve their department
    // (saved as a name string at login) against the fetched list to get its id.
    if (role.toLowerCase() == "employee" && widget.ticket == null) {
      final savedDepartmentName = prefs.getString("departmentName") ?? "";

      final match = departments.where(
        (d) => d.departmentName.toLowerCase() == savedDepartmentName.toLowerCase(),
      );

      if (match.isNotEmpty) {
        selectedDepartmentId = match.first.departmentId;
        selectedDepartmentName = match.first.departmentName;
      } else {
        // No match found (e.g. name mismatch or not set) — leave unset so
        // the submit button's existing validation catches it.
        selectedDepartmentName = savedDepartmentName.isNotEmpty ? savedDepartmentName : null;
      }
    }

    setState(() {
      isLoadingProfile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ticket == null ? "Create Ticket" : "Edit Ticket"),
      ),
      body: isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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

                    if (lockDepartment)
                      // Auto-assigned, read-only department display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.apartment_outlined, size: 20, color: AppColors.textSecondary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Department", style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedDepartmentName?.isNotEmpty == true
                                        ? selectedDepartmentName!
                                        : "Not set on your profile",
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  if (selectedDepartmentId == null && selectedDepartmentName?.isNotEmpty == true) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      "Couldn't match this to a known department — contact IT.",
                                      style: TextStyle(color: AppColors.priorityHigh, fontSize: 11),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(Icons.lock_outline, size: 16, color: AppColors.textSecondary),
                          ],
                        ),
                      )
                    else
                      // Editable dropdown — editing a ticket, or non-employee role
                      DropdownButtonFormField<int>(
                        initialValue: selectedDepartmentId,
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
                            createdAt: "",
                            userId: 4,
                            technicianId: null,
                            technicianName: "",
                            departmentId: selectedDepartmentId!,
                            departmentName: "",
                            category: "",
                            suggestedPriority: "",
                            suggestedSolution: "",
                          );

                          bool success;

                          if (widget.ticket == null) {
                            success = await apiService.createTicket(ticket);
                          } else {
                            success = await apiService.updateTicket(
                              widget.ticket!.ticketId!,
                              ticket,
                            );
                          }

                          if (!mounted) return;
                          if (success) {
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to submit ticket"),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Text(widget.ticket == null ? "Submit Ticket" : "Save Changes"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
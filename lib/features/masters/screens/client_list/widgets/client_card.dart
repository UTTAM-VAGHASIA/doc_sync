import 'package:doc_sync/features/masters/controllers/client_list_controller.dart';
import 'package:doc_sync/features/masters/models/client_model.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientExpansionCard extends StatefulWidget {
  final Client client;
  final Color cardBackgroundColor;
  final Color textColor;
  final Color subtleTextColor;
  
  const ClientExpansionCard({
    super.key, 
    required this.client,
    required this.cardBackgroundColor,
    required this.textColor,
    required this.subtleTextColor,
  });
  
  @override
  ClientExpansionCardState createState() => ClientExpansionCardState();
}

class ClientExpansionCardState extends State<ClientExpansionCard> with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightFactor = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.client.status.toLowerCase() == 'enable';
    
    return Card(
      elevation: 2,
      color: widget.cardBackgroundColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Main client header - always visible
          InkWell(
            onTap: _toggleExpand,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isExpanded ? 0 : 12),
              bottomRight: Radius.circular(isExpanded ? 0 : 12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isEnabled 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isEnabled
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        color: isEnabled
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.client.firmName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: widget.textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "File No: ${widget.client.fileNo}",
                          style: TextStyle(fontSize: 12, color: widget.subtleTextColor),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.client.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isEnabled
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Animated expanded content
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  heightFactor: _heightFactor.value,
                  child: child,
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.0,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Actions menu
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          label: 'Edit',
                          icon: Icons.edit_outlined,
                          color: Colors.green,
                          onTap: () {
                            Get.find<ClientListController>().editClient(widget.client);
                          },
                        ),
                        SizedBox(width: 16),
                        _buildActionButton(
                          label: 'Delete',
                          icon: Icons.delete_outline,
                          color: Colors.red,
                          onTap: () {
                            // Show delete confirmation dialog
                            Get.dialog(
                              AlertDialog(
                                title: const Text('Delete Client'),
                                content: Text(
                                  'Are you sure you want to delete ${widget.client.firmName}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                      Get.find<ClientListController>().deleteClient(widget.client.clientId);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Divider between actions and details
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                  
                  // Client details
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
                        buildDetailRow(
                          context,
                          'Client ID',
                          widget.client.clientId,
                          Icons.tag,
                          AppColors.primary,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Firm Name',
                          widget.client.firmName,
                          Icons.business,
                          Colors.blue,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'File No',
                          widget.client.fileNo,
                          Icons.folder_outlined,
                          Colors.orange,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Contact Person',
                          widget.client.contactPerson,
                          Icons.person_outline,
                          Colors.purple,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Contact No',
                          widget.client.contactNo,
                          Icons.phone_outlined,
                          Colors.green,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Email',
                          widget.client.email,
                          Icons.email_outlined,
                          Colors.red,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'GSTN',
                          widget.client.gstn.isEmpty ? 'N/A' : widget.client.gstn,
                          Icons.receipt_long_outlined,
                          Colors.teal,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'TAN',
                          widget.client.tan.isEmpty ? 'N/A' : widget.client.tan,
                          Icons.assignment_outlined,
                          Colors.indigo,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'PAN',
                          widget.client.pan.isEmpty ? 'N/A' : widget.client.pan,
                          Icons.credit_card_outlined,
                          Colors.amber.shade800,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Accountant ID',
                          widget.client.accountantId,
                          Icons.account_circle_outlined,
                          Colors.deepPurple,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Group ID',
                          widget.client.groupId.isEmpty ? 'N/A' : widget.client.groupId,
                          Icons.group_outlined,
                          Colors.cyan,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Other ID',
                          widget.client.otherId.isEmpty ? 'N/A' : widget.client.otherId,
                          Icons.more_horiz,
                          Colors.brown,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Operation',
                          widget.client.operation,
                          Icons.history,
                          Colors.blueGrey,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Status',
                          widget.client.status,
                          isEnabled ? Icons.check_circle_outline : Icons.cancel_outlined,
                          isEnabled ? Colors.green : Colors.red,
                          widget.textColor,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color textColor, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textColor),
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        if(!isLast) Divider(color: Colors.grey.shade200, height: 1),
      ],
    );
  }
} 
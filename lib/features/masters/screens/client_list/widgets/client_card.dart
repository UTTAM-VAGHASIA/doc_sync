import 'package:doc_sync/features/masters/controllers/client_list_controller.dart';
import 'package:doc_sync/features/masters/models/client_model.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

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
                      color: widget.client.status.toLowerCase() == 'enable' 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        widget.client.status.toLowerCase() == 'enable'
                            ? Iconsax.tick_circle
                            : Iconsax.close_circle,
                        color: widget.client.status.toLowerCase() == 'enable'
                            ? Colors.green
                            : Colors.red,
                        size: 24,
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
                      color: widget.client.status.toLowerCase() == 'enable'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.client.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.client.status.toLowerCase() == 'enable'
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
                          icon: Iconsax.edit,
                          color: Colors.green,
                          onTap: () {
                            Get.find<ClientListController>().editClient(widget.client);
                          },
                        ),
                        _buildActionButton(
                          label: 'Delete',
                          icon: Iconsax.trash,
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
                                      Get.find<ClientListController>()
                                          .deleteClient(widget.client.clientId);
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          title: "Contact Person", 
                          value: widget.client.contactPerson, 
                          icon: Iconsax.user,
                          textColor: widget.textColor,
                          subtleTextColor: widget.subtleTextColor,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          title: "Contact No", 
                          value: widget.client.contactNo, 
                          icon: Iconsax.call,
                          textColor: widget.textColor,
                          subtleTextColor: widget.subtleTextColor,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          title: "Email", 
                          value: widget.client.email, 
                          icon: Iconsax.sms,
                          textColor: widget.textColor,
                          subtleTextColor: widget.subtleTextColor,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          title: "PAN", 
                          value: widget.client.pan.isEmpty ? "Not Available" : widget.client.pan, 
                          icon: Iconsax.document,
                          textColor: widget.textColor,
                          subtleTextColor: widget.subtleTextColor,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          title: "GST No", 
                          value: widget.client.gstn.isEmpty ? "Not Available" : widget.client.gstn, 
                          icon: Iconsax.document_1,
                          textColor: widget.textColor,
                          subtleTextColor: widget.subtleTextColor,
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

  // Helper method to build action buttons
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to build detail rows
  Widget _buildDetailRow({
    required String title,
    required String value,
    required IconData icon,
    required Color textColor,
    required Color subtleTextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: subtleTextColor,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: subtleTextColor,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 
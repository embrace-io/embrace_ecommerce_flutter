import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';

/// AddressBookScreen - Manage saved addresses
class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  // Mock addresses for demo
  final List<Address> _addresses = [
    const Address(
      id: '1',
      firstName: 'John',
      lastName: 'Doe',
      street: '123 Main Street',
      street2: 'Apt 4B',
      city: 'New York',
      state: 'NY',
      zipCode: '10001',
      isDefault: true,
      type: AddressType.both,
    ),
    const Address(
      id: '2',
      firstName: 'John',
      lastName: 'Doe',
      street: '456 Work Avenue',
      city: 'Brooklyn',
      state: 'NY',
      zipCode: '11201',
      isDefault: false,
      type: AddressType.shipping,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address Book'),
      ),
      body: _addresses.isEmpty
          ? _EmptyAddresses()
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                return _AddressCard(
                  address: _addresses[index],
                  onEdit: () => _editAddress(_addresses[index]),
                  onDelete: () => _deleteAddress(_addresses[index]),
                  onSetDefault: () => _setDefaultAddress(_addresses[index]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAddress,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addAddress() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add address coming soon!')),
    );
  }

  void _editAddress(Address address) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit address coming soon!')),
    );
  }

  void _deleteAddress(Address address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _addresses.removeWhere((a) => a.id == address.id);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _setDefaultAddress(Address address) {
    setState(() {
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(
          isDefault: _addresses[i].id == address.id,
        );
      }
    });
  }
}

class _EmptyAddresses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          const Text('No saved addresses'),
          const SizedBox(height: AppConstants.spacingSm),
          const Text('Add an address for faster checkout'),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    address.fullName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(address.street),
            if (address.street2 != null && address.street2!.isNotEmpty)
              Text(address.street2!),
            Text('${address.city}, ${address.state} ${address.zipCode}'),
            const SizedBox(height: AppConstants.spacingMd),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
                if (!address.isDefault) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: onSetDefault,
                    child: const Text('Set as Default'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

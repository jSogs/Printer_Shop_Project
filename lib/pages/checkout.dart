import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo_dart;
import '/models/order.dart';
import '/pages/handle_payment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends StatefulWidget {
  final List<dynamic> cart;

  const CheckoutPage({super.key, required this.cart});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool showAddressForm = false;
  String deliveryAddress = '';
  String selectedDeliveryOption = 'Free Delivery'; // Default delivery option
  double totalPrice = 0.0;
  final TextEditingController addressController = TextEditingController();

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  double calculateSubtotal() {
    return widget.cart.fold(
          0.0,
          (sum, item) => sum + (double.parse(item['price']) * item['quantity']),
        ) +
        (selectedDeliveryOption == 'Free Delivery' ? 0.00 : 29.99);
  }

  double calculateTaxes(double subtotal) {
    return subtotal * 0.1; // Example: 10% tax
  }

  @override
  Widget build(BuildContext context) {
    final double subtotal = calculateSubtotal();
    final double taxes = calculateTaxes(subtotal);
    final double total = subtotal + taxes;
    totalPrice = total;

    return Scaffold(
      appBar: _appBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                showAddressForm ? _addressSection() : _cartSection(),
                if (showAddressForm) _deliveryOptionsSection(),
                if (!showAddressForm && deliveryAddress.isNotEmpty)
                  _deliveryAddressSection(),
              ],
            ),
          ),
          _priceAndAddressSection(subtotal, taxes, total),
          if (!showAddressForm)_payButton(),
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text(
        'Checkout',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 2.0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _cartSection() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.cart.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.grey),
      itemBuilder: (context, index) {
        final item = widget.cart[index];
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              // Item Image
              Image.network(
                item['imageURL'],
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 10),

              // Item Details
              Expanded(
                child: Text(
                  '${item['name']} x${item['quantity']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(item['color'].toInt()),
                  border: Border.all(
                    color:Colors.black,
                    width: 2,
                  ),
                ),
                width: 15,
                height: 15,
              ),
              Text(
                '\$${(double.parse(item['price']) * item['quantity']).toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _addressSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Address',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: addressController,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your delivery address here',
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showAddressForm = false; // Return to cart section
              });
              deliveryAddress = addressController.text;
            },
            child: const Text('Save Address'),
          ),
        ],
      ),
    );
  }

  Widget _deliveryAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Address:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            deliveryAddress,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            (selectedDeliveryOption == 'Free Delivery'
                ? 'Free Delivery \$0.00'
                : 'Express Delivery \$29.99'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            (selectedDeliveryOption == 'Free Delivery'
                ? '10-14 days'
                : '1-3 days'),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _deliveryOptionsSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Options:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          RadioListTile<String>(
            value: 'Free Delivery',
            groupValue: selectedDeliveryOption,
            onChanged: (value) {
              setState(() {
                selectedDeliveryOption = value!;
              });
            },
            title: const Text('Free Delivery (10-14 days)'),
          ),
          RadioListTile<String>(
            value: 'Express Delivery',
            groupValue: selectedDeliveryOption,
            onChanged: (value) {
              setState(() {
                selectedDeliveryOption = value!;
              });
            },
            title: const Text('Express Delivery (1-3 days)'),
          ),
        ],
      ),
    );
  }

  Widget _priceAndAddressSection(double subtotal, double taxes, double total) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _priceRow('Subtotal', subtotal),
          _priceRow('Taxes (10%)', taxes),
          _priceRow('Delivery Fee',
              selectedDeliveryOption == 'Free Delivery' ? 0.00 : 29.99),
          _priceRow('Total', total, isBold: true),
          const SizedBox(height: 10),
          if(!showAddressForm) ElevatedButton(
            onPressed: () {
              setState(() {
                showAddressForm = true; // Navigate to the address entry form
              });
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: deliveryAddress.isEmpty
                ? const Text('Enter Delivery Options')
                : const Text('Edit Delivery Options'),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _payButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          final address = addressController.text.trim();
          if (address.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Please enter your address before proceeding.')),
            );
            return;
          }

          // Handle payment process here
          final prefs = await SharedPreferences.getInstance();
          String userId = prefs.getString('unique_id') ?? "";
          DateTime now = DateTime.now();
          String date = DateFormat('MM/dd/yyyy').format(now);
          Order newOrder = Order(
              userId: mongo_dart.ObjectId.parse(userId),
              cart: widget.cart,
              price: totalPrice,
              address: deliveryAddress,
              deliveryMethod: selectedDeliveryOption,
              date: date);
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => PaymentPage(order: newOrder)));
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Pay', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

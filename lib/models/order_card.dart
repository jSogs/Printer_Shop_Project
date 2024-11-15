import 'package:flutter/material.dart';

class OrderCard extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderCard({super.key, required this.order});

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          // Collapsed View: Order Summary
          ListTile(
            title: Text(
              'Order #${order['_id'].oid.toString().substring(0,18)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${order['date']} - \$${order['price'].toStringAsFixed(2)}'),
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          ),

          // Expanded View: Order Details
          if (isExpanded)
            Column(
              children: [
                const Divider(),
                ...order['cart'].map<Widget>((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Image.network(
                          item['imageURL'],
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 10),
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
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
        ],
      ),
    );
  }
}
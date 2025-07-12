import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genmon4/widgets/animated_blocks_background.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Wallet', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          const AnimatedBlocksBackground(neonColor: Color(0xFFFFA500)),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBalanceCard(context),
                        const SizedBox(height: 24),
                        _buildQuickActions(context),
                        const SizedBox(height: 24),
                        _buildTransactionHistory(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Wallet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '\$1,234.56',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceAction(
                context,
                'Add Money',
                FontAwesomeIcons.plus,
                () {
                  // TODO: Implement add money
                },
              ),
              _buildBalanceAction(
                context,
                'Withdraw',
                FontAwesomeIcons.arrowRight,
                () {
                  // TODO: Implement withdraw
                },
              ),
              _buildBalanceAction(
                context,
                'Transfer',
                FontAwesomeIcons.exchangeAlt,
                () {
                  // TODO: Implement transfer
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceAction(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickAction(
              context,
              'Scan QR',
              FontAwesomeIcons.qrcode,
              () {
                // TODO: Implement QR scan
              },
            ),
            _buildQuickAction(
              context,
              'Pay Bills',
              FontAwesomeIcons.fileInvoiceDollar,
              () {
                // TODO: Implement bill payment
              },
            ),
            _buildQuickAction(
              context,
              'Rewards',
              FontAwesomeIcons.gift,
              () {
                // TODO: Implement rewards
              },
            ),
            _buildQuickAction(
              context,
              'More',
              FontAwesomeIcons.ellipsisH,
              () {
                // TODO: Show more options
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full transaction history
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return _buildTransactionItem(context, index);
          },
        ),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, int index) {
    final transactions = [
      {
        'title': 'Game Purchase',
        'subtitle': 'PUBG Mobile',
        'amount': '-\$29.99',
        'date': 'Today',
        'icon': FontAwesomeIcons.gamepad,
        'color': Colors.blue,
      },
      {
        'title': 'Tournament Win',
        'subtitle': 'Fortnite Tournament',
        'amount': '+\$150.00',
        'date': 'Yesterday',
        'icon': FontAwesomeIcons.trophy,
        'color': Colors.green,
      },
      {
        'title': 'Wallet Top-up',
        'subtitle': 'Credit Card',
        'amount': '+\$100.00',
        'date': 'Mar 15',
        'icon': FontAwesomeIcons.creditCard,
        'color': Colors.orange,
      },
      {
        'title': 'Game Purchase',
        'subtitle': 'Minecraft',
        'amount': '-\$19.99',
        'date': 'Mar 14',
        'icon': FontAwesomeIcons.gamepad,
        'color': Colors.blue,
      },
      {
        'title': 'Tournament Entry',
        'subtitle': 'CS:GO Tournament',
        'amount': '-\$25.00',
        'date': 'Mar 13',
        'icon': FontAwesomeIcons.trophy,
        'color': Colors.red,
      },
    ];

    final transaction = transactions[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: transaction['color'] as Color? ?? Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction['icon'] as IconData? ?? FontAwesomeIcons.gamepad,
              color: transaction['color'] as Color? ?? Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'] as String? ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction['subtitle'] as String? ?? '',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction['amount'] as String? ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: (transaction['amount'] as String? ?? '').startsWith('+')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                transaction['date'] as String? ?? '',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 
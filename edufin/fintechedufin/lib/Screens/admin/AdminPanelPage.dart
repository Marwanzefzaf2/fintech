import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ADMIN PANEL',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 14,
            color: Color.fromARGB(255, 233, 126, 20),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 250, 217),
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 233, 126, 20),
            width: 4,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              color: Color.fromARGB(255, 233, 126, 20),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 255, 250, 217),
              Color.fromARGB(255, 233, 126, 20),
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: usersRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'ERROR LOADING USERS',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 12,
                    color: Colors.red[400],
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            final users = snapshot.data!.docs;

            return ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: users.length,
              separatorBuilder:
                  (_, __) => const Divider(color: Colors.white, height: 2),
              itemBuilder: (context, index) {
                final data = users[index].data() as Map<String, dynamic>;

                return Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 233, 243),
                    border: Border.all(
                      color: Color.fromARGB(255, 248, 201, 155),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 248, 201, 155),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      data['username']?.toString().toUpperCase() ?? 'NO NAME',
                      style: const TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      data['email'] ?? 'NO EMAIL',
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    trailing: SizedBox(
                      width: 150,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildInfoBox('LEVEL: ${data['level'] ?? '-'}'),
                            _buildInfoBox('POINTS: ${data['points'] ?? '-'}'),
                            _buildInfoBox('XP: ${data['xpProgress'] ?? '-'}'),
                            const SizedBox(height: 4),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  final confirmation = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => _buildRetroDialog(context),
                                  );

                                  if (confirmation == true) {
                                    await usersRef
                                        .doc(users[index].id)
                                        .delete();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Color.fromARGB(255, 233, 126, 20), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 8,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildRetroDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Color.fromARGB(255, 233, 126, 20),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white, width: 3),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CONFIRM DELETION',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 14,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'DELETE THIS USER?',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 10,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.green, width: 2),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      color: Colors.green,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.red, width: 2),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'DELETE',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text(
            'Documents',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 0, // TODO: Replace with actual documents
        itemBuilder: (context, index) {
          return const Placeholder(); // TODO: Replace with actual document item
        },
      ),
    );
  }
}

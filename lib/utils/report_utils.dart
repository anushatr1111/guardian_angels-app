import 'dart:typed_data'; // Required for PDF generation
import 'package:flutter/material.dart'; // For BuildContext, SnackBar
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Use 'pw' prefix to avoid conflicts
import 'package:printing/printing.dart'; // For sharing/saving PDF
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ReportUtils {
  // --- PDF Generation ---
  static Future<void> generateAndSharePdf({
    required BuildContext context,
    required String currentTime,
    required String currentLocation,
    required String primaryContact,
    required String incidentDetails,
    required String involvedParties,
    required String witnesses,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context pdfContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Incident Report - Aura Safe',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              _buildPdfInfoRow('Time:', currentTime),
              _buildPdfInfoRow('Location:', currentLocation),
              _buildPdfInfoRow('Primary Contact Notified:', primaryContact),
              pw.Divider(height: 30),
              pw.Header(level: 1, text: 'Incident Details'),
              pw.Paragraph(text: incidentDetails.isNotEmpty
                  ? incidentDetails
                  : 'No details provided.'),
              pw.SizedBox(height: 20),
              pw.Header(level: 1, text: 'Involved Parties'),
              pw.Paragraph(text: involvedParties.isNotEmpty
                  ? involvedParties
                  : 'No details provided.'),
              pw.SizedBox(height: 20),
              pw.Header(level: 1, text: 'Witnesses'),
              pw.Paragraph(
                  text: witnesses.isNotEmpty ? witnesses : 'No details provided.'),
            ],
          );
        },
      ),
    );

    try {
      // Use the printing package to share/save the PDF
      await Printing.sharePdf(
          bytes: await pdf.save(), filename: 'aura_safe_incident_report.pdf');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing PDF: $e')),
      );
    }
  }

  // Helper for PDF formatting
  static pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150, // Fixed width for label column
            child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }


  // --- Email Sending ---
  static Future<void> sendEmailWithReport({
    required BuildContext context,
    required String recipientEmail, // Email address to send to
    required String currentTime,
    required String currentLocation,
    required String primaryContact,
    required String incidentDetails,
    required String involvedParties,
    required String witnesses,
  }) async {
    // ------------------------------------------------------------------
    // ⚠️ IMPORTANT SECURITY & SETUP NOTE FOR EMAIL ⚠️
    // Sending email directly from a client app like Flutter is generally
    // NOT RECOMMENDED for production due to security risks (exposing credentials).
    // You typically need a backend server to handle email sending securely.
    //
    // For testing with GMAIL, you'll need to:
    // 1. Enable 2-Step Verification on your Google Account.
    // 2. Create an "App Password" for Mail on this device:
    //    https://myaccount.google.com/apppasswords
    // 3. Replace 'your_gmail_username' and 'your_app_password' below.
    //
    // DO NOT commit your actual username or password to version control!
    // Consider using environment variables or a secure config method.
    // ------------------------------------------------------------------

    final String username = 'anusharajeshkumar08@gmail.com'; // Replace
    final String password = 'gnid zblk maur jpfo';           // Replace

    // Configure SMTP server (using Gmail as an example)
    final smtpServer = gmail(username, password);

    // Create the email message
    final message = Message()
      ..from = Address(username, 'Aura Safe Report')
      ..recipients.add(recipientEmail)
      ..subject = 'Incident Report - ${currentTime}'
      ..text = '''
Incident Report from Aura Safe App
=================================

Time: $currentTime
Location: $currentLocation
Primary Contact Notified: $primaryContact

Incident Details:
-----------------
${incidentDetails.isNotEmpty ? incidentDetails : 'N/A'}

Involved Parties:
-----------------
${involvedParties.isNotEmpty ? involvedParties : 'N/A'}

Witnesses:
----------
${witnesses.isNotEmpty ? witnesses : 'N/A'}
''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Email sent: ' + sendReport.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report sent successfully to $recipientEmail')),
      );
    } on MailerException catch (e) {
      print('Message not sent. MailerException: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email: ${e.message}')),
      );
       // More specific error handling can be added here based on 'e'
    } catch (e) {
       print('Message not sent. Error: ${e.toString()}');
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }
}
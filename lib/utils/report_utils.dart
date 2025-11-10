import 'dart:typed_data'; // Required for PDF generation
import 'package:flutter/material.dart'; // For BuildContext, SnackBar
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Use 'pw' prefix to avoid conflicts
import 'package:printing/printing.dart'; // For sharing/saving PDF
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:intl/intl.dart'; // For timestamp
import 'dart:convert'; // For jsonEncode (if you use it in other functions)

class ReportUtils {

  // --- 1. Function for MANUAL Report (from ReportTemplateScreen) ---
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing PDF: $e')),
        );
      }
    }
  }

  // Helper for the manual PDF
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

  // --- 2. Function for MANUAL Report Email ---
  static Future<void> sendEmailWithReport({
    required BuildContext context,
    required String recipientEmail,
    required String currentTime,
    required String currentLocation,
    required String primaryContact,
    required String incidentDetails,
    required String involvedParties,
    required String witnesses,
  }) async {
    
    // ------------------------------------------------------------------
    // ⚠️ IMPORTANT: Use your Gmail username and App Password here
    // ------------------------------------------------------------------
    final String username = 'anusharajeshkumar08@gmail.com'; // Replace
    final String password = 'gnid zblk maur jpfo';           // Replace

    if (username == 'your_gmail_username@gmail.com') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email service is not configured.'), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    final smtpServer = gmail(username, password);

    // Create the email message
    final message = Message()
      ..from = Address(username, 'Aura Safe Report')
      ..recipients.add(recipientEmail)
      ..subject = 'Incident Report - $currentTime'
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
      await send(message, smtpServer);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report sent successfully to $recipientEmail')),
        );
      }
    } on MailerException catch (e) {
      print('Message not sent. MailerException: ${e.toString()}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email: ${e.message}')),
        );
      }
    } catch (e) {
       print('Message not sent. Error: ${e.toString()}');
       if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
       }
    }
  }


  // --- 3. NEW Function for AI-Generated PDF (Step 21.3) ---
  static Future<void> generateAndSharePdfFromText({
    required BuildContext context,
    required String generatedReportText,
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
                child: pw.Text('AI-Generated Incident Report - Aura Safe',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              // Use pw.Text and a monospace font because the report is pre-formatted
              pw.Text(
                generatedReportText,
                style: pw.TextStyle( // FIXED: Removed 'const' keyword
                  lineSpacing: 5,
                  font: pw.Font.courier(), // Use a monospace font
                ),
              ),
            ],
          );
        },
      ),
    );

    try {
      // Use the printing package to open the share sheet
      await Printing.sharePdf(
          bytes: await pdf.save(), filename: 'aura_safe_ai_report.pdf');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing PDF: $e')),
        );
      }
    }
  }

  // --- 4. NEW Function for AI-Generated Email (Step 21.3) ---
  static Future<void> sendEmailWithReportText({
    required BuildContext context,
    required String recipientEmail,
    required String generatedReportText,
  }) async {
    
    // ------------------------------------------------------------------
    // ⚠️ IMPORTANT: Use your Gmail username and App Password here
    // ------------------------------------------------------------------
    final String username = 'anusharajeshkumar08@gmail.com'; // Replace
    final String password = 'gnid zblk maur jpfo';          // Replace

    if (username == 'your_gmail_username@gmail.com') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email service is not configured.'), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    final smtpServer = gmail(username, password);
    final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final message = Message()
      ..from = Address(username, 'Aura Safe AI Report')
      ..recipients.add(recipientEmail)
      ..subject = 'AI-Generated Incident Report - $currentDate'
      ..text = generatedReportText; // Use the generated text as the body

    try {
      await send(message, smtpServer);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report sent successfully to $recipientEmail')),
        );
      }
    } on MailerException catch (e) {
      print('Message not sent. MailerException: ${e.toString()}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email: ${e.message}')),
        );
      }
    } catch (e) {
       print('Message not sent. Error: ${e.toString()}');
       if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
       }
    }
  }
}
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class EmailService {
  // Your company's SMTP configuration
  static const String _smtpHost = 'mail.nc-ph-3070.myflexihr.com';
  static const int _smtpPort = 465;
  static const String _username = 'no-reply@myflexihr.com';
  static const String _password = 'e@jRRUFZ%{~7';
  static const String _fromEmail = 'no-reply@myflexihr.com';
  static const String _fromName = 'MEPCO-eSafety';
  static const String _recipientEmail = 'humza.yousaf@hrpsp.net';
  static const List<String> _ccEmails = [
    'muhammad.shaban@hrpsp.net',
    'yousaf@hrpsp.net'
    // Add more CC emails here
  ];
  /// Sends feedback email with error details and complete user information
  static Future<bool> sendFeedbackEmail({
    required String sapCode,
    String? userName,
    String? userEmail,
    String? designation,
    String? department,
    required String errorMessage,
    String? backendError,
    required String userFeedback,
  }) async {
    try {
      // Get App Version Info
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = packageInfo.buildNumber;

      // Configure your company's SMTP server with SSL
      final smtpServer = SmtpServer(
        _smtpHost,
        username: _username,
        password: _password,
        port: _smtpPort,
        ssl: true,
        allowInsecure: false,
      );

      // Helper function to display value or N/A
      String displayValue(String? value) => value?.isNotEmpty == true ? value! : 'N/A';

      // Create the email message
      final message = Message()
        ..from = Address(_fromEmail, _fromName)
        ..recipients.add(_recipientEmail)
        ..ccRecipients.addAll(
            _ccEmails.map((email) => Address(email))
        )
        ..subject = '🔴 PTW Error Feedback - SAP ID: $sapCode'
        ..html = '''
          <!DOCTYPE html>
          <html>
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
            </head>
            <body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f3f4f6;">
              <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f3f4f6; padding: 20px;">
                <tr>
                  <td align="center">
                    <table width="600" cellpadding="0" cellspacing="0" style="background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                      
                      <!-- Header -->
                      <tr>
                        <td style="background: linear-gradient(135deg, #3B82F6 0%, #2563EB 100%); padding: 30px; text-align: center;">
                          <h1 style="color: white; margin: 0; font-size: 24px; font-weight: bold;">
                            🔔 New Error Feedback Received
                          </h1>
                          <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0 0; font-size: 14px;">
                            MEPCO eSafety - PTW System
                          </p>
                        </td>
                      </tr>
                      
                      <!-- Content -->
                      <tr>
                        <td style="padding: 30px;">
                          
                          <!-- User Information -->
                          <h2 style="color: #1f2937; font-size: 18px; margin: 0 0 15px 0; padding-bottom: 10px; border-bottom: 2px solid #3B82F6;">
                            👤 User Information
                          </h2>
                          <table width="100%" cellpadding="8" cellspacing="0" style="margin-bottom: 25px; background-color: #F9FAFB; border-radius: 8px;">
                            <tr>
                              <td style="color: #6b7280; font-size: 14px; width: 140px; padding: 12px;"><strong>SAP ID:</strong></td>
                              <td style="color: #1f2937; font-size: 14px; padding: 12px; font-weight: 600;">$sapCode</td>
                            </tr>
                            <tr style="background-color: white;">
                              <td style="color: #6b7280; font-size: 14px; padding: 12px;"><strong>Name:</strong></td>
                              <td style="color: #1f2937; font-size: 14px; padding: 12px;">${displayValue(userName)}</td>
                            </tr>
                            <tr>
                              <td style="color: #6b7280; font-size: 14px; padding: 12px;"><strong>Email:</strong></td>
                              <td style="color: #1f2937; font-size: 14px; padding: 12px;">${displayValue(userEmail)}</td>
                            </tr>
                            <tr style="background-color: white;">
                              <td style="color: #6b7280; font-size: 14px; padding: 12px;"><strong>Designation:</strong></td>
                              <td style="color: #1f2937; font-size: 14px; padding: 12px;">${displayValue(designation)}</td>
                            </tr>
                            <tr>
                              <td style="color: #6b7280; font-size: 14px; padding: 12px;"><strong>Department:</strong></td>
                              <td style="color: #1f2937; font-size: 14px; padding: 12px;">${displayValue(department)}</td>
                            </tr>
                            <tr style="background-color: white;">
                              <td style="color: #6b7280; font-size: 14px; padding: 12px;"><strong>App Version:</strong></td>
                              <td style="color: #1f2937; font-size: 14px; padding: 12px;">Version $currentVersion+$currentBuildNumber</td>
                            </tr>
                            <tr>
                              <td style="color: #6b7280; font-size: 14px; padding: 12px;"><strong>Timestamp:</strong></td>
                              <td style="color: #1f2937; font-size: 14px; padding: 12px;">${DateTime.now().toString()}</td>
                            </tr>
                          </table>
                          
                          <!-- Error Details -->
                          <h2 style="color: #1f2937; font-size: 18px; margin: 0 0 15px 0; padding-bottom: 10px; border-bottom: 2px solid #EF4444;">
                            ⚠️ App Error Message
                          </h2>
                          <div style="background-color: #FEF2F2; padding: 20px; border-left: 4px solid #EF4444; border-radius: 6px; margin-bottom: 25px;">
                            <code style="color: #991B1B; font-size: 13px; word-wrap: break-word; white-space: pre-wrap; font-family: 'Courier New', monospace;">$errorMessage</code>
                          </div>

                          ${backendError != null ? '''
                          <!-- Backend Error -->
                          <h2 style="color: #1f2937; font-size: 18px; margin: 0 0 15px 0; padding-bottom: 10px; border-bottom: 2px solid #F59E0B;">
                            ⚙️ Backend / Actual Error
                          </h2>
                          <div style="background-color: #FFFBEB; padding: 20px; border-left: 4px solid #F59E0B; border-radius: 6px; margin-bottom: 25px;">
                            <code style="color: #92400E; font-size: 13px; word-wrap: break-word; white-space: pre-wrap; font-family: 'Courier New', monospace;">$backendError</code>
                          </div>
                          ''' : ''}
                          
                          <!-- User Feedback -->
                          <h2 style="color: #1f2937; font-size: 18px; margin: 0 0 15px 0; padding-bottom: 10px; border-bottom: 2px solid #10B981;">
                            💬 User Feedback
                          </h2>
                          <div style="background-color: #D1FAE5; padding: 20px; border-left: 4px solid #10B981; border-radius: 6px; margin-bottom: 25px;">
                            <p style="color: #065F46; margin: 0; font-size: 14px; line-height: 1.6;">$userFeedback</p>
                          </div>
                          
                        </td>
                      </tr>
                      
                      <!-- Footer -->
                      <tr>
                        <td style="background-color: #f9fafb; padding: 20px; text-align: center; border-top: 1px solid #e5e7eb;">
                          <p style="color: #6b7280; font-size: 12px; margin: 0;">
                            This is an automated message from <strong>MEPCO eSafety PTW System</strong>
                          </p>
                          <p style="color: #9ca3af; font-size: 11px; margin: 10px 0 0 0;">
                            Please do not reply to this email
                          </p>
                        </td>
                      </tr>
                      
                    </table>
                  </td>
                </tr>
              </table>
            </body>
          </html>
        ''';

      // Send the email
      final sendReport = await send(message, smtpServer);
      debugPrint('✅ Email sent successfully: ${sendReport.toString()}');
      debugPrint('📧 Sent to: $_recipientEmail');
      debugPrint('📧 CC: $_ccEmails');
      return true;

    } on MailerException catch (e) {
      debugPrint('❌ Email sending failed (MailerException): ${e.toString()}');
      for (var p in e.problems) {
        debugPrint('Problem: ${p.code}: ${p.msg}');
      }
      return false;

    } catch (e) {
      debugPrint('❌ Unexpected error while sending email: ${e.toString()}');
      return false;
    }
  }
}

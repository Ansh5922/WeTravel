import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';

/// Comprehensive WeTravel Privacy Policy Page.
/// Fully compliant with Google Play Store data safety guidelines, GDPR, and CCPA.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  Future<void> _openUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $urlString'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $urlString'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryDeepTeal,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDeepTeal,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // ── Header Banner ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF004E64), Color(0xFF007791)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF004E64).withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WeTravel Privacy Policy',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Effective Date: October 25, 2026 • Last Updated: October 2026',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Welcome to WeTravel ("we," "our," or "us"). WeTravel is a collaborative travel planning, itinerary management, and group expense splitting application. Your privacy and trust are paramount to us. This Privacy Policy details our practices concerning the collection, use, protection, and deletion of your personal data when you use the WeTravel mobile application and associated web services.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Fast Account Deletion Callout Card ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.delete_forever_rounded,
                      color: Color(0xFFDC2626),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Need to Delete Your Account or Data?',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF991B1B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'You can request complete deletion of your account and data at any time via web or app.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF7F1D1D),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openUrl(context, 'https://wetravel-server.duckdns.org/delete-account'),
                      icon: const Icon(Icons.open_in_browser_rounded, size: 16, color: Color(0xFFDC2626)),
                      label: Text(
                        'Web Deletion Portal →',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFF87171)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.push(RouteNames.accountSettings),
                      icon: const Icon(Icons.settings_outlined, size: 16, color: Colors.white),
                      label: Text(
                        'In-App Settings',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Section 1: Information We Collect ─────────────────────────────
          _buildPolicyCard(
            icon: Icons.inventory_2_outlined,
            title: '1. Information We Collect',
            intro: 'We collect only the minimum personal information required to facilitate group trip collaboration and budgeting:',
            bulletItems: const [
              'Account & Profile Information: When you register on WeTravel, we collect your Full Name, Username, Email Address, and optional Profile Picture/Avatar. Passwords are stored exclusively as salted cryptographic hashes (bcrypt) and are never accessible in plain text.',
              'Collaborative Trip Data: Information generated when planning trips, including destination names, start/end dates, trip budget tiers, style preferences, itinerary plans, and group poll votes.',
              'Expense Sharing Records: Details entered into our group expense tracker, including transaction amounts, expense categories, payers, and participant splits.',
              'User-Generated Content: Photos uploaded to shared trip memory galleries and text messages exchanged within private trip group chats.',
              'Device & Diagnostic Logs: IP address, device model, operating system version, and crash diagnostic logs utilized strictly to guarantee application reliability and security.',
            ],
          ),

          const SizedBox(height: 14),

          // ── Section 2: How We Use Your Information ────────────────────────
          _buildPolicyCard(
            icon: Icons.track_changes_rounded,
            title: '2. How We Use Your Information',
            intro: 'We use your information exclusively to provide and enhance collaborative travel features:',
            bulletItems: const [
              'To manage and authenticate your user account securely.',
              'To enable real-time collaboration with friends, including group messaging, polling, and expense splitting.',
              'To power our AI Travel Concierge & Consensus engine, analyzing collective preferences (such as dietary restrictions, pace, budget) to generate relevant itinerary suggestions.',
              'To deliver critical transactional emails such as password reset OTPs and trip invitations.',
            ],
            callout: Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF065F46),
                          height: 1.4,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Zero Data Selling: ',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text:
                                'WeTravel does NOT sell, rent, monetize, or trade your personal information, travel itineraries, or financial data to third-party advertisers or data brokers under any circumstances.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Section 3: Third-Party Integrations & Service Providers ───────
          _buildPolicyCard(
            icon: Icons.hub_outlined,
            title: '3. Third-Party Integrations & Service Providers',
            intro: 'We integrate strictly with reliable, security-vetted third-party services necessary for core app functionality:',
            bulletItems: const [
              'Transactional Email Services (Resend): For delivering secure One-Time Passwords (OTPs) and password reset confirmations.',
              'Geocoding & Location Search (Photon / OpenStreetMap): For searching destinations and points of interest. Search queries do not transmit your account credentials or personal identities.',
              'Cloud Infrastructure: Secure enterprise cloud servers protected by SSL/TLS encryption in transit and at rest.',
            ],
          ),

          const SizedBox(height: 14),

          // ── Section 4: Data Security & Storage ────────────────────────────
          _buildPolicyCard(
            icon: Icons.security_rounded,
            title: '4. Data Security & Storage',
            intro: 'We employ robust administrative, technical, and physical safeguards to protect your personal data:',
            bulletItems: const [
              'All client-server communications are enforced over HTTPS with TLS 1.3 encryption.',
              'Unique UUIDs are utilized for all entities, preventing enumeration vulnerabilities.',
              'Automated chat retention policies purge ephemeral chat messages after 30 days of inactivity.',
            ],
          ),

          const SizedBox(height: 14),

          // ── Section 5: Data Retention & Deletion Rights ───────────────────
          _buildPolicyCard(
            icon: Icons.account_circle_outlined,
            title: '5. Data Retention & Deletion Rights',
            intro: 'In full compliance with Google Play Store policies and global privacy regulations (GDPR / CCPA):',
            bulletItems: const [
              'Right to Erasure: You possess the absolute right to request the deletion of your account and all associated personal data at any time.',
              'In-App Deletion: Open the WeTravel app → Profile → Account Settings → tap Delete Account.',
              'Web-Based Deletion: If you no longer have the app installed, you can submit a deletion request directly on our dedicated web portal: https://wetravel-server.duckdns.org/delete-account.',
              'Anonymization of Financial Records: When an account is deleted, your credentials and personal preferences are permanently erased. Any shared historical group expenses are anonymized (attributed to "Former Member") so remaining travel companions maintain accurate financial split balances.',
            ],
          ),

          const SizedBox(height: 14),

          // ── Section 6: Children's Privacy ─────────────────────────────────
          _buildPolicyCard(
            icon: Icons.child_care_rounded,
            title: '6. Children\'s Privacy',
            content:
                'WeTravel is not directed to children under 13 years of age. We do not knowingly collect or solicit personal information from anyone under the age of 13. If we become aware that a child under 13 has provided us with personal information, we immediately delete such data from our servers.',
          ),

          const SizedBox(height: 14),

          // ── Section 7: Policy Updates ─────────────────────────────────────
          _buildPolicyCard(
            icon: Icons.update_rounded,
            title: '7. Policy Updates',
            content:
                'We may update this Privacy Policy from time to time to reflect operational, legal, or regulatory modifications. When updates are published, the revised date at the top will be updated. We encourage users to periodically review this page.',
          ),

          const SizedBox(height: 14),

          // ── Section 8: Contact Us ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDeepTeal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.mail_outline_rounded, color: AppColors.primaryDeepTeal, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '8. Contact Us',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDeepTeal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'If you have any questions, concerns, or requests regarding this Privacy Policy or your personal data, please contact our Data Protection Team at:',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: const Color(0xFF475569),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WeTravel Privacy & Support Team',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDeepTeal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _openUrl(context, 'mailto:rashimeenameher97@gmail.com'),
                        child: Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 16, color: Color(0xFF0284C7)),
                            const SizedBox(width: 8),
                            Text(
                              'rashimeenameher97@gmail.com',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0284C7),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _openUrl(context, 'https://wetravel-server.duckdns.org'),
                        child: Row(
                          children: [
                            const Icon(Icons.language_rounded, size: 16, color: Color(0xFF0284C7)),
                            const SizedBox(width: 8),
                            Text(
                              'https://wetravel-server.duckdns.org',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0284C7),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Center(
            child: Text(
              'Effective Date: October 25, 2026 • WeTravel Inc.',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPolicyCard({
    required IconData icon,
    required String title,
    String? content,
    String? intro,
    List<String>? bulletItems,
    Widget? callout,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryDeepTeal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryDeepTeal, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDeepTeal,
                  ),
                ),
              ),
            ],
          ),
          if (intro != null) ...[
            const SizedBox(height: 12),
            Text(
              intro,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155),
                height: 1.45,
              ),
            ),
          ],
          if (bulletItems != null) ...[
            const SizedBox(height: 8),
            ...bulletItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6, right: 10),
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDeepTeal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF475569),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (content != null) ...[
            const SizedBox(height: 12),
            Text(
              content,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF475569),
                height: 1.45,
              ),
            ),
          ],
          if (callout != null) callout,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// Privacy and Security Policy Page.
/// Displays industry-standard security practices, data privacy commitments,
/// and AI data alignment principles for WeTravel.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDeepTeal, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Privacy & Security Policy',
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Header Badge
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF004E64), Color(0xFF007791)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF004E64).withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Privacy is Sacred',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'WeTravel uses end-to-end data encryption and strict client-side key sanitization.',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Policy Sections
          _buildPolicyCard(
            icon: Icons.lock_outline_rounded,
            title: '1. Identity & UUID Security',
            content:
                'We adhere to zero-trust client security principles. Database identifiers and UUIDs are permanently sanitized and stripped from all client responses. Your personal data is identified solely via cryptographically signed JWT sessions.',
          ),
          const SizedBox(height: 14),

          _buildPolicyCard(
            icon: Icons.shield_outlined,
            title: '2. Data Encryption',
            content:
                'All communications between your device and our servers use TLS 1.3 encryption. Sensitive credentials, payment settlement records, and group consensus data are stored with military-grade hashing and database encryption.',
          ),
          const SizedBox(height: 14),

          _buildPolicyCard(
            icon: Icons.psychology_outlined,
            title: '3. AI Preference Embeddings',
            content:
                'Your travel style, dietary preferences, and pacing notes are processed by our internal AI sidecar microservice solely to calculate optimal trip consensus with your friends. We NEVER sell or license your travel data to advertisers or third-party brokers.',
          ),
          const SizedBox(height: 14),

          _buildPolicyCard(
            icon: Icons.group_outlined,
            title: '4. Group Collaboration Privacy',
            content:
                'When you join a trip group, only fellow confirmed members of that specific trip can view your shared itinerary suggestions, poll votes, and expense splits. Your private profile notes remain confidential.',
          ),
          const SizedBox(height: 14),

          _buildPolicyCard(
            icon: Icons.delete_outline_rounded,
            title: '5. Right to Erasure (Account Deletion)',
            content:
                'You retain complete ownership over your digital footprint. Under "Accounts & Settings", you can initiate immediate permanent account deletion. This wipes all your profile details, AI vectors, and personal records from our databases permanently.',
          ),
          const SizedBox(height: 28),

          Center(
            child: Text(
              'Last Updated: October 2026 • WeTravel Security Team',
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
    required String content,
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
      ),
    );
  }
}

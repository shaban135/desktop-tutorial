import 'package:get/get.dart';
import 'package:mepco_esafety_app/bindings/attachments_submission_binding.dart';
import 'package:mepco_esafety_app/bindings/forgot_password_binding.dart';
import 'package:mepco_esafety_app/bindings/hse_field_check_binding.dart';
import 'package:mepco_esafety_app/bindings/login_binding.dart';
import 'package:mepco_esafety_app/bindings/profile_binding.dart';
import 'package:mepco_esafety_app/bindings/ptw_completed_binding.dart';
import 'package:mepco_esafety_app/bindings/ptw_grid_close_binding.dart';
import 'package:mepco_esafety_app/bindings/ptw_list_binding.dart';
import 'package:mepco_esafety_app/bindings/ptw_review_sdo_binding.dart';
import 'package:mepco_esafety_app/routes/app_routes.dart';
import 'package:mepco_esafety_app/screens/hse_field_check_screen.dart';
import 'package:mepco_esafety_app/screens/ls_ptw_execution_screen.dart';
import 'package:mepco_esafety_app/screens/completion_confirmation_screen.dart';
import 'package:mepco_esafety_app/screens/create_new_password_screen.dart';
import 'package:mepco_esafety_app/screens/create_ptw_screen.dart';
import 'package:mepco_esafety_app/screens/edit_profile_screen.dart';
import 'package:mepco_esafety_app/screens/forgot_password_screen.dart';
import 'package:mepco_esafety_app/screens/grid_ptw_issue_checklist_screen.dart';
import 'package:mepco_esafety_app/screens/hazard_identification_screen.dart';
import 'package:mepco_esafety_app/screens/dashboard_screen.dart';
import 'package:mepco_esafety_app/screens/settings_screen.dart';
import 'package:mepco_esafety_app/screens/login_screen.dart';
import 'package:mepco_esafety_app/screens/new_ptw_screen.dart';
import 'package:mepco_esafety_app/screens/password_reset_successful_screen.dart';
import 'package:mepco_esafety_app/screens/pdc_queue_screen.dart';
import 'package:mepco_esafety_app/screens/profile_screen.dart';
import 'package:mepco_esafety_app/screens/ptw_cancel_by_ls_screen.dart';
import 'package:mepco_esafety_app/screens/ptw_completed_screen.dart';
import 'package:mepco_esafety_app/screens/ptw_grid_close_screen.dart';
import 'package:mepco_esafety_app/screens/ptw_issue_grid_incharge_screen.dart';
import 'package:mepco_esafety_app/screens/ptw_issuer_instructions_screen.dart';
import 'package:mepco_esafety_app/screens/ptw_list_screen.dart';
import 'package:mepco_esafety_app/screens/ptw_review_sdo_screen.dart';
import 'package:mepco_esafety_app/screens/safety_checklist_line_load_screen.dart';
import 'package:mepco_esafety_app/screens/signup_screen.dart';
import 'package:mepco_esafety_app/screens/technical_work_details_screen.dart';
import 'package:mepco_esafety_app/screens/verify_identity_screen.dart';
import 'package:mepco_esafety_app/screens/welcome_splash_screen.dart';
import 'package:mepco_esafety_app/screens/work_team_information_screen.dart';
import 'package:mepco_esafety_app/screens/ptw_draft_screen.dart';
import 'package:mepco_esafety_app/screens/notifications_screen.dart';
import 'package:mepco_esafety_app/utils/custome_transition.dart';

class AppPages {
  static final pages = [
    GetPage(
        name: AppRoutes.initial,
        page: () => const WelcomeSplashScreen(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.login,
        page: () => const LoginScreen(),
        binding: LoginBinding(),
         customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.signup,
        page: () => const SignUpScreen(),
        customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.forgotPassword,
        page: () => const ForgotPasswordScreen(),
        binding: ForgotPasswordBinding(),
      customTransition: BottomCustomTransition(),// Added transition
    ),
    GetPage(
        name: AppRoutes.verifyIdentity,
        page: () => const VerifyIdentityScreen(),
        binding: ForgotPasswordBinding(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.createNewPassword,
        page: () => const CreateNewPasswordScreen(),
        binding: ForgotPasswordBinding(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.passwordResetSuccess,
        page: () => const PasswordResetSuccessfulScreen(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.home,
        page: () => const HomeScreen(),
        binding: ProfileBinding(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.completionConfirmation,
        page: () => const CompletionConfirmationScreen(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.profile,
        page: () => const ProfileScreen(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.editProfile,
        page: () => const EditProfileScreen(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.newPtw,
        page: () => const NewPtwScreen(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.workTeamInformation,
        page: () => const WorkTeamInformationScreen(),
      customTransition: BottomCustomTransition(),// Added transition
    ),
    GetPage(
        name: AppRoutes.technicalWorkDetails,
        page: () => const TechnicalWorkDetailsScreen(),
      customTransition: BottomCustomTransition(),// Added transition
    ),
    GetPage(
        name: AppRoutes.safetyChecklistLineLoad,
        page: () => const SafetyChecklistLineLoadScreen(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.hazardIdentification,
        page: () => const HazardIdentificationScreen(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.attachmentsSubmission,
        page: () => const LsPtwExecutionScreen(),
        binding: AttachmentsSubmissionBinding(),
      customTransition: BottomCustomTransition(),// Added transition
    ),
    GetPage(
        name: AppRoutes.ptwReviewSdo,
        page: () => const PtwReviewSdoScreen(),
        binding: PtwReviewSdoBinding(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.ptwIssueGridIncharge,
        page: () => const PtwIssueGridInchargeScreen(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.ptwIssuerInstructions,
        page: () => const PtwIssuerInstructionsScreen(),
        transition: Transition.fade, // Added transition
    ),
    GetPage(
        name: AppRoutes.listBulletedIcon,
        page: () => const SettingsScreen(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.pdcQueue,
        page: () => const PdcQueueScreen(),
       customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.createPtwScreen,
        page: () => const CreatePtwScreen(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.ptwDraft,
        page: () => const PtwDraftScreen(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
    GetPage(
        name: AppRoutes.ptwList,
        page: () => const PtwListScreen(),
        binding: PtwListBinding(),
      customTransition: BottomCustomTransition(), // Added transition
    ),
     GetPage(
        name: AppRoutes.gridPtwIssueChecklist,
        page: () => const GridPtwIssueChecklistScreen(),
       customTransition: BottomCustomTransition(), // Added transition
    ),
      GetPage(
      name: AppRoutes.ptwCompleted,
      page: () => const PtwCompletedScreen(),
      binding: PtwCompletedBinding(),
        customTransition: BottomCustomTransition(),
    ),
    GetPage(
      name: AppRoutes.ptwGridClose,
      page: () => const PtwGridCloseScreen(),
      binding: PtwGridCloseBinding(),
      customTransition: BottomCustomTransition(),
    ),
    GetPage(
      name: AppRoutes.ptwCancelByLs,
      page: () => const PtwCancelByLsScreen(),
      customTransition: BottomCustomTransition(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      customTransition: BottomCustomTransition(),
    ),
    GetPage(
      name: AppRoutes.hseFieldCheck,
      page: () => const HseFieldCheckScreen(),
      binding: HseFieldCheckBinding(),
      customTransition: BottomCustomTransition(),
    ),
    // GetPage(
    //   name: AppRoutes.hseFieldCheck,
    //   page: () => const HSEFieldCheckScreen(),
    //   customTransition: BottomCustomTransition(),
    // ),
  ];
}

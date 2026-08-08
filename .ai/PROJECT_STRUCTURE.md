# Project Structure

```text
defaultapp
├── .agent/
└── rules/
    ├── 00-master.md
    ├── 01-stack-and-bans.md
    ├── 02-architecture-layers.md
    ├── 03-di-and-errors.md
    ├── 04-screen-and-widget-structure.md
    ├── 05-state-management.md
    ├── 06-helpers-utils-reuse.md
    ├── 07-self-review-checklist.md
    └── SETUP-README.md
├── .vscode/
└── launch.json
├── docs/
└── examples/
├── lib/
├── core/
│   ├── cache/
│   │   ├── hive_boxes.dart
│   │   ├── hive_keys.dart
│   │   ├── preferences_storage.dart
│   │   └── preferences_storage_keys.dart
│   ├── constants/
│   │   ├── app_assets.dart
│   │   └── strings.dart
│   ├── di/
│   │   └── services_locator.dart
│   ├── enums/
│   │   └── app_enums.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failure.dart
│   ├── extensions/
│   │   ├── ext.dart
│   │   ├── ext_theme.dart
│   │   ├── go_router_extensions.dart
│   │   ├── request_state.dart
│   │   └── text_style.dart
│   ├── network/
│   │   ├── authorization_interceptor.dart
│   │   ├── endpoints.dart
│   │   └── network_service.dart
│   ├── routes/
│   │   ├── app_routes.dart
│   │   ├── route_observer.dart
│   │   └── route_paths.dart
│   ├── services/
│   │   ├── google_sign_in_service.dart
│   │   ├── notification_refresh_service.dart
│   │   ├── notification_service.dart
│   │   ├── signalr_service.dart
│   │   ├── stripe_service.dart
│   │   └── user_role_service.dart
│   ├── theme/
│   │   ├── dark_colors.dart
│   │   ├── dark_theme.dart
│   │   ├── decorations.dart
│   │   ├── dimensions.dart
│   │   ├── light_colors.dart
│   │   ├── light_theme.dart
│   │   ├── styles.dart
│   │   ├── theme_controller.dart
│   │   └── themes.dart
│   ├── utils/
│   │   ├── app_bloc_observer.dart
│   │   ├── app_date_time.dart
│   │   ├── easy_loading.dart
│   │   ├── safe_print.dart
│   │   ├── spacing.dart
│   │   ├── url_launcher_util.dart
│   │   └── validators.dart
│   ├── widgets/
│   │   ├── in_app_notification_popup/
│   │   │   ├── in_app_notification_popup.dart
│   │   │   ├── notification_card.dart
│   │   │   └── notification_style.dart
│   │   ├── app_asset.dart
│   │   ├── app_form_field.dart
│   │   ├── app_image.dart
│   │   ├── app_svg.dart
│   │   ├── bouncing_social_button.dart
│   │   ├── bouncing_widgets.dart
│   │   ├── custom_bottom_navbar.dart
│   │   ├── custom_button.dart
│   │   ├── custom_loading.dart
│   │   ├── custom_nav_bar.dart
│   │   ├── custom_search.dart
│   │   ├── custom_snack_bar.dart
│   │   ├── custom_text.dart
│   │   ├── customer_nav_data.dart
│   │   ├── governorate_dropdown.dart
│   │   ├── location_permission_sheet.dart
│   │   ├── nav_bar_item.dart
│   │   ├── navigation_state.dart
│   │   └── switch_open_gym.dart
│   └── env.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── forget_password_usecase.dart
│   │   │       ├── login_usecase.dart
│   │   │       └── register_usecase.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── auth_cubit.dart
│   │       │   └── auth_state.dart
│   │       └── screens/
│   │           ├── widgets/
│   │           │   ├── forget_password_screen_body.dart
│   │           │   └── login_screen_body.dart
│   │           ├── forget_password_screen.dart
│   │           ├── login_screen.dart
│   │           └── register_screen.dart
│   ├── banking/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── banking_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   ├── bank_account_model.dart
│   │   │   │   ├── banking_statistics_model.dart
│   │   │   │   ├── beneficiary_model.dart
│   │   │   │   ├── bill_model.dart
│   │   │   │   ├── dashboard_data_model.dart
│   │   │   │   └── transaction_model.dart
│   │   │   └── repositories/
│   │   │       └── banking_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── bank_account.dart
│   │   │   │   ├── banking_statistics.dart
│   │   │   │   ├── beneficiary.dart
│   │   │   │   ├── bill.dart
│   │   │   │   ├── dashboard_data.dart
│   │   │   │   └── transaction.dart
│   │   │   ├── repositories/
│   │   │   │   └── banking_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_beneficiary_usecase.dart
│   │   │       ├── get_banking_dashboard_usecase.dart
│   │   │       ├── get_banking_statistics_usecase.dart
│   │   │       ├── get_beneficiaries_usecase.dart
│   │   │       ├── get_bills_usecase.dart
│   │   │       ├── get_transaction_details_usecase.dart
│   │   │       ├── get_transactions_usecase.dart
│   │   │       ├── pay_bill_usecase.dart
│   │   │       └── transfer_money_usecase.dart
│   │   └── presentation/
│   │       ├── cubits/
│   │       │   ├── add_beneficiary/
│   │       │   │   ├── add_beneficiary_cubit.dart
│   │       │   │   └── add_beneficiary_state.dart
│   │       │   ├── banking_dashboard/
│   │       │   │   ├── banking_dashboard_cubit.dart
│   │       │   │   └── banking_dashboard_state.dart
│   │       │   ├── banking_statistics/
│   │       │   │   ├── banking_statistics_cubit.dart
│   │       │   │   └── banking_statistics_state.dart
│   │       │   ├── bills/
│   │       │   │   ├── bills_cubit.dart
│   │       │   │   └── bills_state.dart
│   │       │   ├── transaction_details/
│   │       │   │   ├── transaction_details_cubit.dart
│   │       │   │   └── transaction_details_state.dart
│   │       │   ├── transactions/
│   │       │   │   ├── transactions_cubit.dart
│   │       │   │   └── transactions_state.dart
│   │       │   └── transfer_money/
│   │       │       ├── transfer_money_cubit.dart
│   │       │       └── transfer_money_state.dart
│   │       └── screens/
│   │           ├── widgets/
│   │           │   ├── account_card.dart
│   │           │   ├── banking_dashboard_screen_body.dart
│   │           │   ├── quick_actions_row.dart
│   │           │   └── transaction_item.dart
│   │           ├── add_beneficiary_screen.dart
│   │           ├── banking_dashboard_screen.dart
│   │           ├── banking_statistics_screen.dart
│   │           ├── bills_screen.dart
│   │           ├── transaction_details_screen.dart
│   │           ├── transactions_screen.dart
│   │           └── transfer_money_screen.dart
│   ├── ecommerce_home/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── ecommerce_home_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   ├── category_model.dart
│   │   │   │   ├── ecommerce_home_data_model.dart
│   │   │   │   ├── product_model.dart
│   │   │   │   └── promo_banner_model.dart
│   │   │   └── repositories/
│   │   │       └── ecommerce_home_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── category.dart
│   │   │   │   ├── ecommerce_home_data.dart
│   │   │   │   ├── product.dart
│   │   │   │   └── promo_banner.dart
│   │   │   ├── repositories/
│   │   │   │   └── ecommerce_home_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_ecommerce_home_usecase.dart
│   │   └── presentation/
│   │       ├── cubits/
│   │       │   └── ecommerce_home/
│   │       │       ├── ecommerce_home_cubit.dart
│   │       │       └── ecommerce_home_state.dart
│   │       └── screens/
│   │           ├── widgets/
│   │           │   ├── categories_row.dart
│   │           │   ├── ecommerce_home_screen_body.dart
│   │           │   ├── products_horizontal_list.dart
│   │           │   └── promo_banner_slider.dart
│   │           └── ecommerce_home_screen.dart
│   ├── home/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── home_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── branch_model.dart
│   │   │   └── repositories/
│   │   │       └── home_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── branch.dart
│   │   │   ├── repositories/
│   │   │   │   └── home_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_nearby_branches_usecase.dart
│   │   └── presentation/
│   │       ├── cubits/
│   │       │   └── home/
│   │       │       ├── home_cubit.dart
│   │       │       └── home_state.dart
│   │       └── screens/
│   │           ├── widgets/
│   │           │   └── home_screen_body.dart
│   │           └── home_screen.dart
│   ├── notifications/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── notifications_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── notification_model.dart
│   │   │   └── repositories/
│   │   │       └── notifications_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── app_notification.dart
│   │   │   ├── repositories/
│   │   │   │   └── notifications_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_notifications_usecase.dart
│   │   └── presentation/
│   │       ├── cubits/
│   │       │   └── notifications/
│   │       │       ├── notifications_cubit.dart
│   │       │       └── notifications_state.dart
│   │       └── screens/
│   │           ├── widgets/
│   │           │   └── notifications_screen_body.dart
│   │           └── notifications_screen.dart
│   ├── product_details/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── product_details_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── product_details_model.dart
│   │   │   └── repositories/
│   │   │       └── product_details_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── product_details.dart
│   │   │   ├── repositories/
│   │   │   │   └── product_details_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_product_details_usecase.dart
│   │   └── presentation/
│   │       ├── cubits/
│   │       │   └── product_details/
│   │       │       ├── product_details_cubit.dart
│   │       │       └── product_details_state.dart
│   │       └── screens/
│   │           ├── widgets/
│   │           │   ├── product_actions_bar.dart
│   │           │   ├── product_details_screen_body.dart
│   │           │   ├── product_image_carousel.dart
│   │           │   └── product_info_section.dart
│   │           └── product_details_screen.dart
│   ├── profile/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── profile_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── profile_model.dart
│   │   │   └── repositories/
│   │   │       └── profile_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_profile.dart
│   │   │   ├── repositories/
│   │   │   │   └── profile_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_profile_usecase.dart
│   │   └── presentation/
│   │       ├── cubits/
│   │       │   └── profile/
│   │       │       ├── profile_cubit.dart
│   │       │       └── profile_state.dart
│   │       └── screens/
│   │           ├── widgets/
│   │           │   └── profile_screen_body.dart
│   │           └── profile_screen.dart
│   └── splash/
│       └── presentation/
│           └── screens/
│               └── splash_screen.dart
└── main.dart
├── tools/
├── context/
│   ├── context_cache.dart
│   ├── context_classifier.dart
│   ├── context_engine.dart
│   └── context_loader.dart
├── core/
│   ├── analyzers/
│   │   ├── constant_analyzer.dart
│   │   ├── resource_analyzer.dart
│   │   └── typography_analyzer.dart
│   ├── registry/
│   │   └── resource_registry.dart
│   ├── resources/
│   │   ├── constant_resource.dart
│   │   ├── framework_resource.dart
│   │   └── typography_resource.dart
│   ├── ast_parser.dart
│   ├── dart_parser.dart
│   ├── directory_walker.dart
│   ├── fingerprint_manager.dart
│   ├── project_info.dart
│   └── semantic_model.dart
├── generators/
│   ├── agents_generator.dart
│   ├── ai_generator.dart
│   ├── context_generator.dart
│   ├── conventions_generator.dart
│   ├── decision_log_generator.dart
│   ├── examples_generator.dart
│   ├── framework_generator.dart
│   ├── graph_generator.dart
│   ├── index_generator.dart
│   ├── patterns_generator.dart
│   ├── project_generator.dart
│   ├── stats_generator.dart
│   ├── structure_generator.dart
│   └── validation_generator.dart
├── setup_ai.dart
└── update_ai_context.dart
├── .flutter-plugins-dependencies
├── .gitignore
├── .metadata
├── AI_INDEX.json
├── PROJECT_STRUCTURE.md
├── README.md
├── analysis_options.yaml
├── defaultapp.iml
├── pubspec.lock
├── pubspec.yaml
└── test_regex.dart
```

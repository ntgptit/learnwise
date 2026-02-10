lib/
  main.dart                                     # Điểm khởi động ứng dụng, cấu hình router, theme, l10n, provider scope

  app/                                          # Cấu hình cấp ứng dụng (tương tự @Configuration của Spring Boot)
    config/
      env.dart                                  # Đọc file .env → load ENV (DEV/STG/PROD)
      app_config.dart                           # AppConfig chứa baseUrl, API version, feature flags
      app_const.dart                            # (7) LOGIC CONSTANT → retryCount, pageSize, defaultLanguage...
    router/
      app_router.dart                           # go_router: định nghĩa route, navigation graph chính
      route_names.dart                          # Hằng số tên route → tránh hard-code string
      redirects.dart                             # Guard (AuthGuard) → điều hướng khi hết session / chưa login
    theme/
      app_theme.dart                             # Theme Material 3 + GoogleFonts + merge design tokens
      colors.dart                                # (4) COLOR CONSTANT → palette chính của app
      typography.dart                            # Bộ TextStyle chuẩn toàn hệ thống (Title, Body…)

  core/                                          # Thành phần nền tảng FE (tương tự core/infrastructure của Spring Boot)
    network/
      dio_provider.dart                          # Provider tạo Dio instance + attach interceptors
      api_client.dart                            # Wrapper GET/POST/PUT/DELETE → mọi lỗi đều được map
      interceptors/
        auth_interceptor.dart                    # Gắn token vào Header, xử lý refresh token nếu cần
        logging_interceptor.dart                 # Log request/response (chỉ bật khi debug)
        retry_interceptor.dart                   # Auto retry khi network chập chờn
      api_const.dart                             # (6) API CONSTANT → timeout, headers, base paths, mime types
    error/
      error_code.dart                            # Enum mã lỗi → tương đương ErrorCode trong Spring Boot
      app_exception.dart                         # AppException (BadRequest, Unauthorized, Forbidden…)
      api_error_mapper.dart                      # Convert DioException → AppException (giống @ExceptionHandler)
      global_error_handler.dart                  # Điều phối lỗi toàn app → giống ControllerAdvice
    local/
      secure_storage.dart                        # Lưu JWT/refresh token bằng SecureStorage
      prefs_storage.dart                         # SharedPreferences để lưu cấu hình nhẹ (theme mode, language…)

  common/                                        # Thành phần UI/nền tảng dùng chung như "shared module"
    widgets/
      loading_state_widget.dart                  # Widget loading chuẩn
      error_state_widget.dart                    # Widget hiển thị lỗi + nút Retry
      empty_state_widget.dart                    # Trạng thái rỗng
      primary_button.dart                        # Button theo design system
      app_dialog.dart                            # Dialog chuẩn toàn hệ thống
    styles/
      spacing.dart                               # (2) SPACING CONSTANT → S.xs, S.sm, S.md, S.lg
      radius.dart                                # (3) RADIUS CONSTANT → R.sm, R.md, R.lg
      shadows.dart                               # Shadow chuẩn theo design token
      icons.dart                                 # (5) ICON CONSTANT → IconData & SVG paths
    extensions/
      build_context_x.dart                       # context.showSnackbar(), context.goBack(), context.isDark…
      widget_x.dart                               # Extension kiểu Tailwind: .px(16), .py(12), .rounded(8)
      string_x.dart                               # Helper validate string, capitalize…

  l10n/                                          # (1) TEXT CONSTANT → hệ thống i18n (ARB)
    app_en.arb                                   # Text tiếng Anh
    app_vi.arb                                   # Text tiếng Việt
    app_ko.arb                                   # Text tiếng Hàn

  features/                                      # Mỗi module domain độc lập (tương tự module Spring Boot)
    auth/
      model/
        auth_dto.dart                            # DTO mapping từ API
        session.dart                             # Session model: token, expires, user info
      repository/
        auth_api.dart                             # API: login/logout/refresh
        auth_repository.dart                      # FE logic: login(), logout() — không chứa UI
      viewmodel/
        auth_viewmodel.dart                       # Riverpod @riverpod: xử lý state login & call repository
      view/
        login_screen.dart                         # Màn hình Login
        widgets/
          login_form.dart                         # Form nhập email/password

    learning/
      model/
        vocab_dto.dart                            # DTO raw trả về từ BE
        vocab_item.dart                           # Model tiêu chuẩn dùng UI
        learning_filter.dart                      # Trạng thái filter: search, sort…
        learning_const.dart                       # (7) FEATURE CONSTANT → loại constant riêng của domain Learning
      repository/
        learning_api.dart                         # API: modules/vocabulary list
        learning_repository.dart                  # FE logic chuyển DTO → Model + caching nhẹ
      viewmodel/
        learning_viewmodel.dart                   # State + logic load/refresh/filter modules
      view/
        learning_progress_screen.dart             # Màn hình tiến độ học
        widgets/
          filter_bar.dart                         # Thanh filter
          modules_table.dart                      # Bảng list module
          footer.dart                             # Footer tiến độ
          help_dialog.dart                        # Dialog hướng dẫn học tập

    progress/
      model/
        progress_dto.dart                         # DTO tiến độ từ API
      repository/
        progress_api.dart                          # API: lấy chi tiết tiến độ
        progress_repository.dart                   # FE logic mapping
      viewmodel/
        progress_viewmodel.dart                    # Riverpod state quản lý tiến độ
      view/
        progress_detail_screen.dart               # UI chi tiết tiến độ học tập

======================================================

common/
  widgets/
    layout/
      app_scaffold.dart                   # Scaffold chuẩn (title, padding, safe area, theme)
      section_title.dart                  # Tiêu đề từng section trong màn hình
      spaced_column.dart                  # Column có spacing cố định (thay vì SizedBox rác code)
      spaced_row.dart                     # Row có spacing cố định
      responsive_padding.dart             # Padding tự động theo kích thước màn hình (mobile/tablet)
      scroll_with_header.dart             # Layout scroll + sticky header (dùng cho learning screen)
    
    buttons/
      primary_button.dart                 # Nút chính của toàn app
      secondary_button.dart               # Nút phụ (outline/cancel)
      text_button.dart                    # Nút text
      icon_button.dart                    # Nút icon tùy chỉnh
      circle_button.dart                  # Nút dạng hình tròn (dùng trong flashcard)
      action_button.dart                  # Nút có icon + text (retry/next/prev)

    state/
      loading_state.dart                  # UI loading chung
      error_state.dart                    # UI lỗi với retry callback
      empty_state.dart                    # UI rỗng, tùy chỉnh icon + message
      offline_state.dart                  # Mất mạng, gợi ý bật wifi/4G
      unauthorized_state.dart             # Token hết hạn, yêu cầu login

    card/
      app_card.dart                       # Card nền chung
      flashcard_front.dart                # Flashcard mặt trước
      flashcard_back.dart                 # Flashcard mặt sau
      flashcard_flip.dart                 # Flashcard có hiệu ứng flip (front/back)
      flashcard_stack.dart                # Stack nhiều flashcard (Deck view)
      flashcard_result_chip.dart          # Chip kết quả: Correct / Wrong / Hard

    quiz/
      quiz_option_item.dart               # Item cho lựa chọn quiz (A, B, C, D)
      quiz_progress_bar.dart              # Thanh tiến trình quiz
      quiz_timer.dart                     # Timer đếm ngược
      quiz_question_header.dart           # Header hiển thị câu hỏi
      quiz_result_card.dart               # Kết quả bài quiz

    dialog/
      app_dialog.dart                     # Dialog chuẩn app
      confirm_dialog.dart                 # Xác nhận Yes/No
      info_dialog.dart                    # Dialog thông tin
      bottom_sheet_select.dart            # BottomSheet chọn item (ví dụ: difficulty, tag)
      flashcard_edit_dialog.dart          # Dialog chỉnh sửa flashcard

    list/
      vocab_list_item.dart                # Item từ vựng hiển thị trong danh sách
      module_list_item.dart               # Item module học
      progress_list_item.dart             # Item tiến trình học
      swipeable_list_item.dart            # Item có thể swipe trái/phải (delete/edit)

    audio/
      audio_player_button.dart            # Nút play audio (TTS)
      audio_waveform.dart                 # Hiệu ứng waveform khi phát âm
      audio_speed_selector.dart           # Chọn tốc độ phát âm (0.75x, 1x, 1.25x)

    input/
      app_text_field.dart                 # Input text chuẩn
      search_field.dart                   # Search bar (search vocab)
      number_input.dart                   # Nhập số (ví dụ nhập điểm -> 0–100)
      slider_input.dart                   # Slider (điểm, âm lượng)
      segmented_control.dart              # Switch filter: Hard / Normal / Easy
      tag_input.dart                      # Nhập các tag cho flashcard

    loader/
      shimmer_box.dart                    # Shimmer loading placeholder
      skeleton_list.dart                  # Skeleton list loading

    indicator/
      app_chip.dart                       # Chip tags, difficulty
      app_badge.dart                      # Badge số lượng (ví dụ số từ còn lại)
      circular_progress.dart              # Progress hình tròn
      linear_progress.dart                # Progress thẳng (quiz/progress tracking)

    navigation/
      bottom_nav_bar.dart                 # Bottom navigation bar chung
      tab_bar.dart                        # Tab bar tùy chỉnh (Learn / Review / Progress)
      floating_nav_button.dart            # Floating button điều hướng (Next flashcard)

    animation/
      fade_in.dart                        # Hiệu ứng fade
      scale_in.dart                       # Scale animation khi load
      slide_in.dart                       # Slide animation cho card
      flip_animation.dart                 # Flip animation cho flashcard

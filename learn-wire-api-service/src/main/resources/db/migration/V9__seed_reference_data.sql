-- Reference data seed for folder/deck/flashcard flows.
-- Enable via Flyway placeholder: seed_demo_data=true

INSERT INTO folders (
    id,
    name,
    description,
    color_hex,
    created_by,
    updated_by,
    deleted_by,
    created_at,
    updated_at,
    deleted_at,
    parent_folder_id,
    direct_flashcard_count,
    aggregate_flashcard_count
)
SELECT
    seed.id,
    seed.name,
    seed.description,
    seed.color_hex,
    seed.created_by,
    seed.updated_by,
    seed.deleted_by,
    seed.created_at,
    seed.updated_at,
    seed.deleted_at,
    seed.parent_folder_id,
    seed.direct_flashcard_count,
    seed.aggregate_flashcard_count
FROM (
    SELECT 1001, 'Folder 1', '', '#2563EB', 'flyway', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 22:46:51.402', TIMESTAMP '2026-02-13 13:35:41.251', CAST(NULL AS TIMESTAMP), CAST(NULL AS BIGINT), 0, 15
    UNION ALL SELECT 1002, 'Test', '', '#10B981', 'flyway', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 22:46:51.402', TIMESTAMP '2026-02-13 13:35:18.920', CAST(NULL AS TIMESTAMP), 1001, 15, 15
    UNION ALL SELECT 1101, 'Test 1', '', '#4F46E5', '1', '1', '1', TIMESTAMP '2026-02-13 13:46:22.398', TIMESTAMP '2026-02-14 15:22:12.013', TIMESTAMP '2026-02-14 15:22:12.001', 1001, 0, 0
    UNION ALL SELECT 1102, 'Test 1_1', '', '#4F46E5', '1', '1', '1', TIMESTAMP '2026-02-13 13:46:34.089', TIMESTAMP '2026-02-14 15:22:12.018', TIMESTAMP '2026-02-14 15:22:12.001', 1101, 0, 0
    UNION ALL SELECT 1103, 'Test 1', '', '#4F46E5', '1', '1', '1', TIMESTAMP '2026-02-13 13:46:48.959', TIMESTAMP '2026-02-14 15:22:12.020', TIMESTAMP '2026-02-14 15:22:12.001', 1102, 0, 0
    UNION ALL SELECT 1104, 'đasad', '', '#4F46E5', '1', '1', '1', TIMESTAMP '2026-02-13 14:03:22.303', TIMESTAMP '2026-02-14 15:22:12.022', TIMESTAMP '2026-02-14 15:22:12.001', 1103, 0, 0
    UNION ALL SELECT 1105, 'đâs', '', '#4F46E5', '1', '1', '1', TIMESTAMP '2026-02-13 14:03:38.826', TIMESTAMP '2026-02-14 15:22:12.024', TIMESTAMP '2026-02-14 15:22:12.001', 1104, 0, 0
    UNION ALL SELECT 1106, 'sdsdsa', '', '#4F46E5', '1', '1', '1', TIMESTAMP '2026-02-13 14:26:42.134', TIMESTAMP '2026-02-14 15:22:12.031', TIMESTAMP '2026-02-14 15:22:12.001', 1102, 0, 0
) AS seed (
    id,
    name,
    description,
    color_hex,
    created_by,
    updated_by,
    deleted_by,
    created_at,
    updated_at,
    deleted_at,
    parent_folder_id,
    direct_flashcard_count,
    aggregate_flashcard_count
)
WHERE '${seed_demo_data}' = 'true';

INSERT INTO decks (
    id,
    folder_id,
    name,
    description,
    created_by,
    updated_by,
    deleted_by,
    created_at,
    updated_at,
    deleted_at,
    normalized_name
)
SELECT
    seed.id,
    seed.folder_id,
    seed.name,
    seed.description,
    seed.created_by,
    seed.updated_by,
    seed.deleted_by,
    seed.created_at,
    seed.updated_at,
    seed.deleted_at,
    seed.normalized_name
FROM (
    SELECT 1001, 1002, '한국어 공부', '', '1', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 14:34:31.697', TIMESTAMP '2026-02-13 13:35:00.366', CAST(NULL AS TIMESTAMP), LOWER(TRIM('한국어 공부'))
    UNION ALL SELECT 1002, 1002, 'ahihi', '', '1', '1', '1', TIMESTAMP '2026-02-12 16:58:34.912', TIMESTAMP '2026-02-13 13:34:19.378', TIMESTAMP '2026-02-13 13:34:19.364', CAST(NULL AS VARCHAR(120))
) AS seed (
    id,
    folder_id,
    name,
    description,
    created_by,
    updated_by,
    deleted_by,
    created_at,
    updated_at,
    deleted_at,
    normalized_name
)
WHERE '${seed_demo_data}' = 'true';

INSERT INTO flashcards (
    id,
    front_text,
    back_text,
    created_by,
    updated_by,
    deleted_by,
    created_at,
    updated_at,
    deleted_at,
    deck_id
)
SELECT
    seed.id,
    seed.front_text,
    seed.back_text,
    seed.created_by,
    seed.updated_by,
    seed.deleted_by,
    seed.created_at,
    seed.updated_at,
    seed.deleted_at,
    seed.deck_id
FROM (
    SELECT 10001, '세월', 'Time / Thời gian trôi (Danh từ, chỉ dòng thời gian, hàm ý sâu lắng; âm Hán Việt: Tuế nguyệt; Tuế: năm, Nguyệt: tháng)', '1', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 15:15:04.622', TIMESTAMP '2026-02-12 15:15:04.622', CAST(NULL AS TIMESTAMP), 1001
    UNION ALL SELECT 10002, '다리미', 'Iron / Bàn ủi (Danh từ, thiết bị dùng để làm phẳng quần áo bằng nhiệt)', '1', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 15:15:25.927', TIMESTAMP '2026-02-12 15:15:25.927', CAST(NULL AS TIMESTAMP), 1001
    UNION ALL SELECT 10003, '대여점', 'Rental shop / Cửa hàng cho thuê (Danh từ, nơi cho thuê đồ vật; âm Hán Việt: Đại dư điểm; Đại: cho, Dư: mượn, Điểm: cửa hàng)', '1', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 15:15:39.248', TIMESTAMP '2026-02-12 15:15:39.248', CAST(NULL AS TIMESTAMP), 1001
    UNION ALL SELECT 10004, '분실물 센터', 'Lost and found center / Trung tâm đồ thất lạc (Danh từ, nơi tiếp nhận và lưu giữ đồ bị mất; âm Hán Việt: Phân thất vật + từ mượn tiếng Anh: Center; Phân: mất, Thất: thất lạc, Vật: đồ vật)', '1', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 15:15:54.669', TIMESTAMP '2026-02-12 15:15:54.669', CAST(NULL AS TIMESTAMP), 1001
    UNION ALL SELECT 10005, '공중질서', 'Public order / Trật tự công cộng (Danh từ, nguyên tắc giữ trật tự nơi công cộng; âm Hán Việt: Công chúng trật tự; Công: chung, Chúng: người, Trật: đúng, Tự: thứ tự)', '1', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 15:16:33.431', TIMESTAMP '2026-02-12 15:16:33.431', CAST(NULL AS TIMESTAMP), 1001
    UNION ALL SELECT 10006, '복용하다', 'Take medicine / Uống thuốc (Động từ, hành động dùng thuốc bằng đường uống; âm Hán Việt: Phục dụng; Phục: dùng, Dụng: sử dụng)', '1', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 15:16:48.438', TIMESTAMP '2026-02-12 15:16:48.438', CAST(NULL AS TIMESTAMP), 1001
    UNION ALL SELECT 10007, '상의하다', 'Discuss / Thảo luận, bàn bạc (Động từ, hành động trao đổi để quyết định; âm Hán Việt: Thương nghị; Thương: bàn bạc, Nghị: bàn luận)', '1', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 15:17:10.080', TIMESTAMP '2026-02-12 15:17:10.080', CAST(NULL AS TIMESTAMP), 1001
    UNION ALL SELECT 10008, '접다', 'Fold / Gấp, gập (Động từ, hành động gập một vật mỏng như giấy, vải)', '1', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 15:17:28.650', TIMESTAMP '2026-02-12 15:17:28.650', CAST(NULL AS TIMESTAMP), 1001
    UNION ALL SELECT 10009, '미소', 'Smile / Nụ cười (Danh từ, hành động cong môi thể hiện thiện chí; âm Hán Việt: Vi tiếu; Vi: nhỏ, Tiếu: cười)', '1', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 15:17:39.538', TIMESTAMP '2026-02-12 15:17:39.538', CAST(NULL AS TIMESTAMP), 1001
    UNION ALL SELECT 10010, '사라지다', 'Disappear / Biến mất (Động từ, trạng thái không còn hiện diện)', '1', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 15:18:06.057', TIMESTAMP '2026-02-12 15:18:06.057', CAST(NULL AS TIMESTAMP), 1001
    UNION ALL SELECT 10011, '벗어나다', 'Escape / Thoát khỏi (Động từ, hành động ra khỏi hoàn cảnh hoặc khu vực nào đó)', '1', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 15:18:22.239', TIMESTAMP '2026-02-12 15:18:22.239', CAST(NULL AS TIMESTAMP), 1001
    UNION ALL SELECT 10012, '기부', 'Donation / Quyên góp (Danh từ, hành động tặng tiền hoặc vật phẩm vì mục đích xã hội; âm Hán Việt: Ký phó; Ký: cho, Phó: giao)', '1', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 15:18:49.464', TIMESTAMP '2026-02-12 15:18:49.464', CAST(NULL AS TIMESTAMP), 1001
    UNION ALL SELECT 10013, '구인 광고', 'Job advertisement / Quảng cáo tuyển dụng (Danh từ, nội dung tìm kiếm nhân lực; âm Hán Việt: Cầu nhân quảng cáo; Cầu: tìm, Nhân: người, Quảng cáo: truyền thông)', '1', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 15:19:22.016', TIMESTAMP '2026-02-12 15:19:22.016', CAST(NULL AS TIMESTAMP), 1001
    UNION ALL SELECT 10014, '친근감', 'Sense of closeness / Cảm giác thân thiết, gần gũi (Danh từ, trạng thái dễ tiếp cận, tạo thiện cảm; âm Hán Việt: Thân cận cảm; Thân: thân mật, Cận: gần, Cảm: cảm xúc)', '1', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 15:19:36.443', TIMESTAMP '2026-02-12 15:19:36.443', CAST(NULL AS TIMESTAMP), 1001
    UNION ALL SELECT 10015, '티켓정보', 'Ticket information / Thông tin vé (Danh từ, dữ liệu liên quan đến vé; từ mượn tiếng Anh: Ticket + Information)', '1', '1', CAST(NULL AS VARCHAR(120)), TIMESTAMP '2026-02-12 15:19:49.575', TIMESTAMP '2026-02-12 15:19:49.575', CAST(NULL AS TIMESTAMP), 1001
) AS seed (
    id,
    front_text,
    back_text,
    created_by,
    updated_by,
    deleted_by,
    created_at,
    updated_at,
    deleted_at,
    deck_id
)
WHERE '${seed_demo_data}' = 'true';

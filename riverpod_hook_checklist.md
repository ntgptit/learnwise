# Checklist_Riverpod_Annotation_DI_Hooks.md

# 1. Kiến trúc tổng thể

* Tách **DI**, **providers**, **viewmodel**, **state**, **repository**, **service**, **model**, **widget** thành module rõ ràng.
* Tất cả provider dùng **@Riverpod annotation** để auto-generate → giảm file lộn xộn.
* Toàn bộ logic business → đặt trong **ViewModel** (StateNotifier / AsyncNotifier).
* UI **Stateless** + Hooks làm nhiệm vụ đọc state và render.
* Tuyệt đối **không inject trực tiếp Repository vào Widget**.
* Dùng DI đúng chuẩn:

  * Repository được khai báo ở **provider global**.
  * ViewModel inject repository qua `ref.read(repositoryProvider)`.

---

# 2. Checklist khi sử dụng Riverpod Annotation

## 2.1 Provider naming

* Provider phải được đặt tên theo pattern:

  * `xxxRepositoryProvider`
  * `xxxServiceProvider`
  * `xxxViewModelProvider`
  * `xxxStateProvider`
* Không được đặt tên mơ hồ như `dataProvider`, `controller`, `utils`.

## 2.2 Quy tắc generate

* File phải có:

  ```dart
  part 'xxx.g.dart';
  ```

* Không bao giờ sửa file `.g.dart`.

## 2.3 Các loại provider cần dùng

* `@Riverpod(keepAlive: true)` → cho DI cấp cao (repository/service).
* `@Riverpod(keepAlive: false)` → cho ViewModel màn hình.
* State có IO → dùng `AsyncNotifier`.
* State thuần logic không async → dùng `Notifier`.

## 2.4 Không bao giờ được làm

* Không gọi API trong constructor widget → luôn đặt trong `build()` với hook hoặc viewmodel init.
* Không gọi `ref.read` trong build để trigger action side-effect.
* Không mutate state trực tiếp. Luôn dùng `state = state.copyWith()`.

---

# 3. Checklist khi dùng HookRiverpod

> Đây là phần dễ sai nhất → cần kỷ luật.

## 3.1 Hook được phép dùng

* `useState`
* `useEffect`
* `useMemoized`
* `useTextEditingController`
* `useAnimationController`
* `usePageController`
* `useScrollController`

## 3.2 Hook TUYỆT ĐỐI không được lạm dụng

* Không tạo các logic business trong `useEffect`.
* Không gọi API trong `useEffect` trừ trường hợp *init lần đầu*.
* Không cập nhật state trong hook nếu viewmodel đã quản lý state đó.
* Không lưu state dài hạn bằng `useState` → phải đưa vào ViewModel.

## 3.3 Quy tắc vàng

* **UI → Hook**
* **Logic → ViewModel**
* **Data → Repository**
* **IO → Service**

## 3.4 Rule khi dùng useEffect

* `useEffect(() { ... }, [])` chỉ dùng cho:

  * init fetch
  * subscribe event
  * animation start
* Nếu phụ thuộc state → phải chỉ định dependency rõ ràng.
* Không gọi `setState` style hooks khi state thuộc ViewModel.

## 3.5 Rule khi dùng useMemoized

* Dùng để tạo instance nặng (PageController, ScrollController, AnimationController).
* Không bao giờ khởi tạo Repository hoặc Service trong memoized.

---

# 4. Checklist kết hợp HookRiverpod + Riverpod Annotation

## 4.1 Luồng chuẩn

1. UI đọc:

   ```dart
   final viewModel = ref.watch(xxxViewModelProvider);
   ```

2. UI gọi action:

   ```dart
   ref.read(xxxViewModelProvider.notifier).fetch();
   ```

3. Hook chỉ xử lý UI-state, không đụng logic.

## 4.2 Những lỗi nghiêm trọng cần tránh

* ❌ **Gọi viewmodel action ngay trong build()**
* ❌ **useEffect gọi API liên tục vì dependency sai**
* ❌ **Dùng useState để giữ dữ liệu mà ViewModel đang quản lý**
* ❌ **Tạo repository trong widget → phá DI, khó test**
* ❌ **Tạo state song song (UI giữ state riêng, ViewModel giữ state riêng)**
* ❌ **Gọi notifier trong useEffect không có dependency → loop vô hạn**

## 4.3 Nguyên tắc dependency khi dùng useEffect

* Nếu gọi API trong useEffect:

  ```dart
  useEffect(() {
    ref.read(vm.notifier).fetch();
    return null;
  }, []);
  ```

* Nếu phụ thuộc router params:

  ```dart
  useEffect(() {
    ref.read(vm.notifier).load(id);
    return null;
  }, [id]);
  ```

---

# 5. Checklist khi dùng DI (Dependency Injection)

* DI chỉ ở mức provider, không phải tự tạo injector như Dagger/Koin.
* Tất cả repository phải được override testable.
* Tất cả provider phải chuẩn hóa theo:

  ```dart
  @Riverpod(keepAlive: true)
  XxxRepository xxxRepository(XxxRepositoryRef ref) => XxxRepositoryImpl();
  ```

* Không dùng singleton global (static instance).
* Không truyền context vào ViewModel.

---

# 6. Checklist khi tạo ViewModel

## 6.1 Quy tắc cấu trúc

Thứ tự hàm trong ViewModel:

1. constructor/init
2. public functions
3. internal functions
4. private functions

## 6.2 Quy tắc coding

* Luôn fail-fast: validate sớm, guard clause.
* Không dùng else.
* State phải bất biến.
* Action phải nhỏ, rõ, có 1 nhiệm vụ duy nhất.

## 6.3 Quy tắc AsyncNotifier

* Luôn bắt lỗi:

  ```dart
  try {
    final data = await repo.fetch();
    state = AsyncData(data);
  } catch (e, s) {
    state = AsyncError(e, s);
  }
  ```

* Không swallow exception.
* Không update UI state bằng hook → chỉ update từ ViewModel.

---

# 7. Checklist UI khi dùng Hook + Riverpod

* UI phải stateless, không chứa logic.
* Hook chỉ dùng để:

  * giữ controller
  * listen animation
  * scroll/page
  * local UI state rất nhỏ (toggle, popup…)
* Nếu một state cần dùng lại ở nhiều widget → phải chuyển lên ViewModel.
* Không viết nhiều class trong một file (theo style Java)

---

# 8. Checklist dành cho Page Template / LwPageTemplate

Page Template phải cung cấp:

* AppBar chuẩn
* Loading state
* Error state
* Offline state
* Unauthorized state
* Empty state
* FAB chuẩn
* Bottom navigation (nếu dùng ShellRoute)
* Hàm chuẩn:

  * onRefresh
  * onNavigate
  * onRetry
  * onScrollEnd
  * onFabPressed

---

# 9. Checklist Migration sang HookRiverpod

* Không khó nếu tuân thủ 4 điều:

  1. Tách UI → ViewModel rõ ràng
  2. Hook chỉ cho UI
  3. DI chỉ ở Provider
  4. Không giữ state trong widget

---

# 10. Checklist tổng thể chống sai phạm

## 10.1 TUYỆT ĐỐI KHÔNG

* Không mutate state trực tiếp
* Không tạo repository/service trong widget
* Không gọi API trong build
* Không update state cả UI và viewmodel song song
* Không lạm dụng hook để chứa business logic

## 10.2 PHẢI

* Mọi data-flow đi từ:
  **Service → Repository → ViewModel → UI**
* Mọi screen đều có ViewModel riêng.
* Mọi state đều bất biến.
* Mọi async đều qua AsyncValue.

---

# 11. Cuối cùng: Checklist Best Practices Cốt Lõi

* ViewModel = trung tâm quản lý mọi state.
* Hook = tối ưu UI, không chứa logic.
* Annotation = giúp code sạch, không sai, dễ maintain.
* DI = đảm bảo test được, dễ mở rộng.
* Sống theo nguyên tắc:
  **“UI không được biết logic, logic không được biết UI.”**

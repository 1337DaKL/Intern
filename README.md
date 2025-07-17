<h1> Quá trình thực tập vị trí phân tích mã độc </h1> 

---
Một số lưu ý
---

<h2>Recommend</h2>

- IDE dùng để code WInAPI: Phải sử dụng Visdua Studio(Bản màu tím)
- Lí do phải học: Hầu hết các mã độc tấn công vào hệ điều hành Windows đều code bằng WinAPI.

<h2>Tài liệu</h2>

- Tài liệu về winapi chuẩn từ trang chủ của microsoft: [Document Microsoft](https://learn.microsoft.com/en-us/windows/win32/api/)
- Tài liệu về winapi nhặt được từ trên mạng: [Document Internet](https://github.com/1337DaKL/Intern/blob/main/Basic_Win32_Programming.pdf)
- 3 bài blog hay dễ hiểu nhất mình đọc về cơ bản assembly: [Part 1](https://viblo.asia/p/toi-da-hoc-assembly-32bit-nhu-the-nao-phan-1-V3m5WPPwKO7)    [Part 2](https://viblo.asia/p/toi-da-hoc-assembly-32bit-nhu-the-nao-phan-2-1Je5EmDG5nL)    [Part 3](https://viblo.asia/p/toi-da-hoc-assembly-32bit-nhu-the-nao-phan-3-GrLZDkr2Kk0)

---
Train
---

<h2> Tuần 1. Tìm hiểu cơ bản về các phiên bản hệ điều hành của Windows. Tìm hiểu về các định nghĩa về file, folder, registry, process, thread, service, WinAPI, ... </h2>

Các kiến thức cần chú ý:
- Tìm hiểu kĩ về file, cấu tạo của file, tại sao có thể phân biệt được kiểu dữ liệu của file, ...
- Tìm hiểu về folder, cấu trúc folder, ...
- Tìm hiểu về registry, các key root trong registry, chức năng từng key, khái niệm về key, subkey, cặp name value, và mối quan hệ giữa chúng, ...
- Tìm hiểu về process. Khái niệm, các trạng thái, các bộ nhớ có trong 1 process( program, data, stack, head), ...
- Tìm hiểu về luồng. Khái niệm, so sánh với process, ...
- Tìm hiểu về service các dịch vụ của hệ điều hành như UI( User interface), quản lí file, quản lí bộ nhớ, ...
- Tìm hiểu về WinAPI. Khái niệm, ưu điểm, nhược điểm, ...

Link bài làm: Link bài làm: [Báo cáo](https://github.com/1337DaKL/Intern/blob/main/B%C3%A1o%20c%C3%A1o%20SVTT%202025_Tr%E1%BB%8Bnh%20%C4%90%E1%BA%AFc%20L%C6%B0%E1%BB%A3ng_Tu%E1%BA%A7n%201.pdf)

<h2> Tuần 2. Làm dự án console: Đọc file và in ra màn hình nội dung file, thêm, sửa, xóa file. Sử dụng WinApi. </h2> 

Các kiến thức cần chú ý:
- Kiến thức về file
- Các hàm API sau: ReadConsoleW, ReadConsoleA , WriteConsoleA, WriteConsoleW, CreateFileW, WriteFile, DeleteFileW, ...

Link bài làm: [Console](https://github.com/1337DaKL/Intern/blob/main/console.cpp)

<h2>Tuần 3. Làm dự án console: Thêm, sửa, xóa key trong registry, thêm, sửa value key. Cài đặt chương trình khởi động cùng với máy </h2>

Các kiến thức cần chú ý:
- Kiến thức về registry
- Các hàm API sau: RegOpenKeyExA, RegSetValueExA, RegDeleteValueA, ReadConsoleA, RegCloseKey, RegGetValueA, RegSetValueExA, RegDeleteKeyA, RegCreateKeyExA, ...

Link bài làm: [Registry](https://github.com/1337DaKL/Intern/blob/main/register.cpp)

<h2>Tuần 4. Làm dự án GUI( Graphic User Interface). Code chay giao diện gồm 1 ô input nhập 1 chuỗi string, và 1 checkbox để lật ngược và một nút button. Khi click nút button sẽ chuyển chữ cái hoa thành chữ cái thường và ngược lại, nếu có check lật ngược thì sẽ lật ngược. Ví dụ: abcd -> ABCD nếu có checkbox thì abcd -> DCBA.</h2>

Các kiến thức cần chú ý:
- Hàm WinMain: Hàm này khác với hàm main thông thường sử dụng khi viết giao diện trong WinApi. Chú ý cả phần các tham số đầu vào vì nó sẽ liên quan đến bài sau.
- Hàm Winproc
- Các hàm API: CreateWindowExW, ShowWindow, UpdateWindow, GetMessage, TranslateMessage, DispatchMessage, SendMessage, GetDlgItem, GetWindowTextW, ...

Link bài làm: [GUI Basic](https://github.com/1337DaKL/Intern/blob/main/graphic%20user%20interface.cpp)

<h2> Tuần 5. Làm dự án console. Hiển thị tất cả thông tin các tiến trình đang chạy trong hệ điều hành. Bao gồm các thông tin như: ID, tên, số lượng luồng, ...</h2>

Các kiến thức cần chú ý:
- Kiến thức về process
- Kiến thức về luồng
- Các hàm API sau: CreateToolhelp32Snapshot, Process32First, Process32Next, ...

Link bài làm: [process](https://github.com/1337DaKL/Intern/blob/main/process.cpp)

<h2>Tuần 6: Làm dự án GUI. Làm giao diện sử dụng MFC để kéo thả ra giao diện chọn 1 đường dẫn thư mục và khi click nút bắt đầu thì chương trình sẽ duyệt tất cả các file có trong thư mục đó. Khi click nút kết thúc hoặc duyệt xong thư mục thì sẽ hiển thị ra toàn bộ thông tin của từng file bao gồm: đường dẫn, tên file, chữ kí của file. Ngoài ra còn chỉnh icon và background của phần mềm.</h2>

Các kiến thức cần chú ý:
- Kiến thức về chữ ký của file
- Kiến thức về chia luồng
- Kiến thức về kéo thả MFC
- Các hàm API sau: FindFirstFileW, FindNextFileW, SetItemText, InsertColumn, LoadIcon, ...
- Ngoài ra còn phải hiểu về handle đại diện cho cửa số chính, học kĩ con trỏ nữa(khái niệm này dùng khá nhiều), ...

Link bài làm: [GUI File](https://github.com/1337DaKL/Intern/tree/main/GuiInforFile)

<h2>Tuần 7 + 8: Làm dự án GUI. Sử dụng MFC làm một dự án nhắn tin real time sử dụng socket thư viện winsock. Yêu cầu đăng nhập vào hệ thống bằng tài khoản. Sau đó giao diện sẽ hiển thị toàn bộ người dùng đang online một các real time. Sau đó chọn một người dùng và kết nối nhắn tin real time với họ.</h2>

Các kiến thức cần chú ý:
- Real time là gì? Nó đơn giản là nhận dữ liệu và hiện thị dữ liệu gần như lập tức.
- Kiến thức về mạng máy tính như: Mô hình OSI, mô hình TCP/IP, các tầng trong mô hình và giao thức của từng tầng.
- Quá trình đóng gói vận chuyển một dữ liệu thông qua các nút mạng như nào?
- Các dịch vụ của tầng ứng dụng như DNS, HTTP là gì, ...
- Socket là gì? Sử dụng dịch vụ của tầng vận chuyển nhưng lại dùng IP và PORT để phân biệt.
- Các mô hình máy chủ (Khách chủ, ngang hàng, mô hình lai)
- Quá trình truy cập một tên miền
- Cấu trúc gói tin HTTP Request, HTTP Response.
- Các dịch vụ Email, FTP, ...
- Giao thức UDP, TCP là gì? Quá trình bắt tay 3 bước của TCP.
- Thư viện lập trình WinSock.
- UDP Socket, TCP Socket.
- Các chế độ vào ra( Đồng bộ và bất đồng bộ).
- Các kĩ thuật vào ra trên Winsock(Kĩ thuật đa luồng, Kĩ thuật lựa chọn, kĩ thuật vào ra theo thông báo, kĩ thuật vào ra theo sự kiện, kĩ thuật chồng chập, ...)
- Các hàm của thư viện winsock cần chú ý: WSAStartup, socket, bind, listen, FD_ZERO, FD_ISSET, FD_SET, closesocket, send, accept, select, recv, connect, ...
- Các hàm API cần chú ý: PostMessage, SetWindowTextW.
- Trong bài này cũng khá là khó phần giao diện cần phải học chắc hiểu kĩ cấu trúc của một dự án, dữ liệu đi như nào. Tạo một digalog mới như nào truyền dữ liệu từ digalog cũ qua digalog mới như nào. Ngoài ra còn phải biết các dùng luồng hợp lí.

Link bài làm: [GUI Mess Socket](https://github.com/1337DaKL/Intern/tree/main/MessGUI)

<h2>Tuần 9 + 10: Làm dự án mã độc. Tạo một con keylogger theo dõi thu thập bàn phím người dùng sau đó gửi dữ liệu qua server bằng TCP socket. Nâng cao ẩn giấu tinh vi nhất có thể.</h2>

Các kiến thức cần chú ý:
- Tạo một con server lắng nghe bằng socket( Như bài cũ thôi)
- Kiến thức về Hook
- Tạo luồng mới sử dụng: CreateProcessA và một số hàm API khác

Link bài tập( dự án này có làm thêm và hoàn thành hơn so với bài tập): [Keylloger](https://github.com/1337DaKL/Malware_Keylogger)

<h2>Tuần 11: Chia team</h2>

Chia sinh viên thành 2 team:
- Team Virus: Phân tích mã độc, dịch ngược, phân loại nhãn mã độc và một vài nhiệm vụ khác.
- Team Kernel: Lập trình hệ thống, phát triển phần mềm Bkav Pro.

Sẽ họp và kiểm tra kiến thức sau đó anh quản lí sẽ chia team( Có dựa trên mong muốn của sinh viên nữa).
=> Chọn tean Virus. Vói 2 team này thì quá trình sau đó đào tạo khác nhau.

Trong tuần này có tự tìm hiểu lại một số lí thuyết cơ bản trong lập trình hợp ngữ Assembly x86(32 bit):
- Các dạng biểu diễn dữ liệu: Nhị phân, Thập lục phân, bát phân, thập phân
- Các phép toán nhị phân như: and, or, xor, not, nand, nor
- Phương pháp bù 1, bù 2
- Các kiểu dữ liệu trong ngôn ngữ lập trình c như:  int, short, long long, double, ...
- Kích thước lưu trữ như: bit, byte, word, double word, quar word.
- Các thanh ghi trong CPU: thanh ghi đa năng, thanh ghi con trỏ, thanh ghi chỉ số, thanh ghi điều khiển, thanh ghi đoạn
- Cấu trúc một dòng lệnh trong assembly
- Cấu trúc chương trình assembly

Bài tập tự luyện thêm assembly(Do ngôn ngữ lập trình này khá khó nên học kĩ từng kiến thức một, không nên học qua loa): [Learn assembly](https://github.com/1337DaKL/Assembly)

<h2>Tuần 12: </h2>


#include <windows.h>
#include <string>
#include <iostream>
using namespace std;
int main()
{
    HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
    HANDLE hIn = GetStdHandle(STD_INPUT_HANDLE);
    if (hOut == INVALID_HANDLE_VALUE || hIn == INVALID_HANDLE_VALUE)
        return 1;
    const char *msg = "Hay chon chuc nang ban can\n0. Thoat chuong trinh\n1. Doc file in noi dung len man hinh console\n2. Ghi mot chuoi vao file\n3. Xoa file\nNhap chuc nang ban mong muon:\n";
    DWORD written = 0;
    WriteConsole(hOut, msg, (DWORD)strlen(msg), &written, nullptr);
    while (true)
    {
        wchar_t choose[100];    
        DWORD read_console;
        ReadConsoleW(hIn, choose, 100, &read_console, nullptr);
        int result_choose = *choose - 48;
        if (result_choose == 1){
            HANDLE hFile = CreateFileW(
                L"/home/trinhdacluong/Documents/Intern_BKAV/infor_console.txt",
                GENERIC_READ | GENERIC_WRITE,
                FILE_SHARE_READ,
                NULL,
                OPEN_EXISTING,            
                FILE_ATTRIBUTE_NORMAL,   
                NULL 
            );
            if (hFile == INVALID_HANDLE_VALUE){
                const char *msg_error_read_file = "Khong the doc duoc file hoac khong tim thay file!!";
                DWORD written = 0;
                WriteConsole(hOut, msg_error_read_file, (DWORD)strlen(msg_error_read_file), &written, nullptr);
                return 1;
            }
            const DWORD buffer_size = 1000;
            char buffer[buffer_size];
            DWORD bytes_read;
            BOOL read_file_boolean = ReadFile(
                hFile,
                buffer,
                buffer_size - 1,
                &bytes_read,
                NULL
            );
            if(read_file_boolean == false){
                const char *msg_error_read_file = "Xay ra loi khi doc file";
                DWORD written = 0;
                WriteConsole(hOut, msg_error_read_file, (DWORD)strlen(msg_error_read_file), &written, nullptr);
                return 1;
            }
            buffer[bytes_read] = '\0';
            std::string msg_result_read_file = std::string("Ket qua doc tu file la: \n") + buffer + "\n";
            DWORD written = 0;
            WriteConsole(hOut, msg_result_read_file.c_str(), (DWORD)msg_result_read_file.length(), &written, nullptr);
            return 1;
        }
        else if (result_choose == 2){
            cout << "chon 2\n";
        }
        else if (result_choose == 3){
            cout << "chon 3\n";
        }
        else if (result_choose == 0)
        {
            cout << "Thoat chuong trinh thanh cong\n";
            break;
        }
        else{
            cout << "Vui long chon dung so chuc nang ban can chon\n";
        }
    }
    return 0;
}
// Gui
//  int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
//                  PSTR szCmdLine, int iCmdShow)
//  {
//      MessageBox(NULL, TEXT("Hello, Windows!"), TEXT("HelloMsg"), MB_OK);
//      return 0;
//  }

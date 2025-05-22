#include <windows.h>
#include <string>
#include <locale>
#include <codecvt>
#include <iostream>
using namespace std;
void choose_option();
void repeat_all_functions();
void print_notion(const string &s);
wstring get_name_file()
{
    print_notion("Nhap ten file muon xu li:");
    wchar_t name_file[100];
    DWORD real_name_read;
    HANDLE h_get_name = GetStdHandle(STD_INPUT_HANDLE);
    ReadConsoleW(h_get_name, name_file, 100, &real_name_read, nullptr);
    if (real_name_read >= 2 && name_file[real_name_read - 2] == L'\r')
    {
        name_file[real_name_read - 2] = L'\0';
    }
    else
    {
        name_file[real_name_read] = L'\0';
    }
    return L"/home/trinhdacluong/Documents/Intern_BKAV/WinAPI_Gui_Project/" + wstring(name_file);
}
void print_notion(const string &s)
{
    std::string out = s + "\n";
    HANDLE h_print_notion = GetStdHandle(STD_OUTPUT_HANDLE);
    DWORD read;
    WriteConsoleA(h_print_notion, out.c_str(), (DWORD)out.length(), &read, nullptr);
}

void choose_option()
{
    print_notion("-----------------------------------------------------------------------");
    print_notion("Nhap 0 de dung chuong trinh hoac nhap 1 de quay lai chuong trinh");
    int option_input;
    while (true)
    {
        wchar_t choose_option[100];
        DWORD read_real;
        HANDLE h_in_option = GetStdHandle(STD_INPUT_HANDLE);
        ReadConsoleW(h_in_option, choose_option, 100, &read_real, nullptr);
        option_input = *choose_option - 48;
        if (option_input == 1 || option_input == 0)
            break;
        print_notion("Vui long chi chon 1 hoac 0. Hay nhap lai");
    }
    if (option_input == 1)
    {
        repeat_all_functions();
    }
    return;
}
void repeat_all_functions()
{
    // in thong bao
    HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
    print_notion("--------------------------------------------");
    print_notion("Hay chon chuc nang ban can duoi day:");
    print_notion("0. Thoat chuong trinh");
    print_notion("1. Doc file va in noi dung file len man hinh console");
    print_notion("2. Them noi dung vao file");
    print_notion("3. Xoa file");
    print_notion("Hay nhap chuc nang ban mong muon:");
    // nhap lua chon
    HANDLE hIn = GetStdHandle(STD_INPUT_HANDLE);
    wchar_t choose[100];
    DWORD read_console;
    ReadConsoleW(hIn, choose, 100, &read_console, nullptr);
    int result_choose = *choose - 48;

    // option lua chon
    if (result_choose == 1)
    {
        wstring name_file = get_name_file();
        HANDLE hFile = CreateFileW(
            name_file.c_str(),
            GENERIC_READ | GENERIC_WRITE,
            FILE_SHARE_READ,
            NULL,
            OPEN_EXISTING,
            FILE_ATTRIBUTE_NORMAL,
            NULL);
        if (hFile == INVALID_HANDLE_VALUE)
        {
            print_notion("Khong the doc duoc file hoac khong tim thay file");
            choose_option();
        }
        else
        {
            const DWORD buffer_size = 1000;
            char buffer[buffer_size];
            DWORD bytes_read;
            BOOL read_file_boolean = ReadFile(
                hFile,
                buffer,
                buffer_size - 1,
                &bytes_read,
                NULL);
            if (read_file_boolean == false)
            {
                print_notion("Xay ra loi khi doc file");
                choose_option();
            }
            else
            {
                buffer[bytes_read] = '\0';
                string msg_result_read_file = string("Ket qua doc tu file la: \n\"") + buffer + "\"\n";
                print_notion(msg_result_read_file);
                CloseHandle(hFile);
                choose_option();
            }
        }
    }
    else if (result_choose == 2)
    {
        wstring name_file = get_name_file();
        HANDLE h_file_open_input = CreateFileW(
            name_file.c_str(),
            FILE_APPEND_DATA,
            FILE_SHARE_WRITE,
            NULL,
            OPEN_EXISTING,
            FILE_ATTRIBUTE_NORMAL,
            NULL);
        if (h_file_open_input == INVALID_HANDLE_VALUE)
        {
            print_notion("Duong dan file loi");
            choose_option();
        }
        // tohong t=bao
        print_notion("Vui long nhap noi dung muon them vao file");
        // nhap noi dung
        HANDLE h_in = GetStdHandle(STD_INPUT_HANDLE);
        wchar_t input_in_file[100];
        DWORD read;
        ReadConsoleW(h_in, input_in_file, 100, &read, nullptr);
        if (read >= 2 && input_in_file[read - 2] == L'\r')
        {
            input_in_file[read - 2] = L'\0';
        }
        else
        {
            input_in_file[read] = L'\0';
        }
        wstring_convert<codecvt_utf8<wchar_t>> converter;
        string utf8Str = converter.to_bytes(input_in_file);
        string in_file = utf8Str + "\r\n";
        DWORD bytes_written = 0;
        BOOL push_in_file = WriteFile(
            h_file_open_input,
            in_file.c_str(),
            (DWORD)in_file.length(),
            &bytes_written,
            NULL);
        if (push_in_file == false)
        {
            print_notion("Them noi dung vao file khong thanh cong");
            choose_option();
        }
        else
        {
            print_notion("Them noi dung vua nhap vao file thanh cong");
            CloseHandle(h_file_open_input);
            choose_option();
        }
    }
    else if (result_choose == 3)
    {
        wstring name_file = get_name_file();
        bool deleted_file = DeleteFileW(name_file.c_str());
        if (deleted_file == false)
        {
            print_notion("Xoa file khong thanh cong do file khong ton tai!!");
            choose_option();
        }
        else
        {
            print_notion("Xoa file thanh cong!!");
        }
    }
    else if (result_choose == 0)
    {
        print_notion("Thoat chuong trinh thanh cong!!");
        return;
    }
    else
    {
        print_notion("Vui long chon nhung chuc nang co trong goi y");
        choose_option();
    }
    return;
}
int main()
{
    repeat_all_functions();
}

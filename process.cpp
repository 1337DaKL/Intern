#include <windows.h>
#include <tlhelp32.h>
#include <stdio.h>
#include <string>
using namespace std;
HANDLE h_out = GetStdHandle(STD_OUTPUT_HANDLE);
DWORD real;
HANDLE h_in = GetStdHandle(STD_INPUT_HANDLE);
void print_notion(string s) {
    s += "\n";
    WriteConsoleA(
        h_out,
        s.c_str(),
        (DWORD)size(s),
        &real,
        NULL
    );
}
int main() {
    while (true) {
        HANDLE h_process = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
        PROCESSENTRY32  me32;
        me32.dwSize = sizeof(PROCESSENTRY32);
        COORD pos;
        pos.X = 0;
        pos.Y = 0;
        SetConsoleCursorPosition(h_out, pos);
        Sleep(1000);
        print_notion("Nhung tien trinh dang chay la: ");
        int stt = 1;
        
        if (Process32First(h_process, &me32)) {
            do {
                wstring wname = me32.szExeFile;
                string name(wname.begin(), wname.end());
                string results = "STT: " + to_string(stt++) + " | ID cua tien trinh: " + to_string(me32.th32ProcessID) + + " | So luong su dung cua tien trinh: " +  to_string(me32.cntThreads) + " | Ten cua tien trinh: " + name;
                print_notion(results);
            } while (Process32Next(h_process, &me32));
        }
        else {
            print_notion("Khong co tien trinh nao dang chay");
        }
        Sleep(1000);
    }    
}

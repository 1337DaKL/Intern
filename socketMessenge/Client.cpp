#define _WINSOCK_DEPRECATED_NO_WARNINGS
#include <winsock2.h>  
#include <windows.h>
#include <ws2tcpip.h>
#include <iostream>
#pragma comment(lib, "ws2_32.lib")
using namespace std;
void print_notion(wstring s) {
    s += L"\n";
    HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
    DWORD real_writen;
    WriteConsoleW(hOut, s.c_str(), size(s), &real_writen, NULL);
}
int main() {
    Sleep(1000);
    WSAData wsaData;
    if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) {
        print_notion(L"Khởi tạo Winsock DLL không thành công");
        return 0;
    }
    print_notion(L"Khởi tạo Winsock DLL thành công ...");
    Sleep(1000);
    SOCKET clientSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (clientSocket == INVALID_SOCKET) {
        print_notion(L"Khởi tạo socket client không thành công!!");
        return 0;
    }
    print_notion(L"Khởi tạo socket client thành công ...");
    Sleep(1000);
    sockaddr_in server{};
    server.sin_family = AF_INET;
    server.sin_port = htons(12345);
    InetPton(AF_INET, L"127.0.0.1", &server.sin_addr);
    int resultsConnect = connect(clientSocket, (sockaddr*)&server, sizeof(server));
    if (resultsConnect != 0) {
        print_notion(L"Kết nối không thành công với server!!");
        return 0;
    }
    print_notion(L"Kết nối thành công với server...");
    print_notion(L"Nhập thông tin muốn gửi cho server:");
    HANDLE hIN = GetStdHandle(STD_INPUT_HANDLE);
    char mess[100];
    DWORD readRead;
    ReadConsoleW(hIN, mess, 100, &readRead, NULL);
    send(clientSocket, mess, sizeof(mess), MSG_OOB);
}

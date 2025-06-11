#include <winsock2.h>  
#include <windows.h>
#include <iostream>
#include<string>
#include <locale>
#include <codecvt>
#pragma comment(lib, "ws2_32.lib")
using namespace std;
void print_notion(wstring s) {
    s += L"\n";
    HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
    DWORD real_writen;
    WriteConsoleW(hOut, s.c_str(), size(s) , &real_writen, NULL);
}
int main() {
    Sleep(1000);
    WSAData wsaData;
    if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) {
        print_notion(L"Khởi tạo Winsock DLL không thành công!!");
        return 0;
    }
    print_notion(L"Khởi tạo Winsock DLL thành công ...");
    Sleep(1000);
    SOCKET serverSocket = socket(AF_INET , SOCK_STREAM , IPPROTO_TCP);

    if (serverSocket == INVALID_SOCKET) {
        print_notion(L"Khởi tạo socket không thành công!!");
        return 0;
    }
    print_notion(L"Khởi tạo socket thành công ...");
    Sleep(1000);
    sockaddr_in linkAddress;
    linkAddress.sin_family = AF_INET;
    linkAddress.sin_addr.s_addr = INADDR_ANY;
    linkAddress.sin_port = htons(12345);
    int bindLink = bind(serverSocket, (SOCKADDR*)&linkAddress, sizeof(linkAddress));
    if (bindLink != 0) {
        print_notion(L"Gán địa chỉ và cổng cho bind không thành công!!");
    }
    Sleep(1000);
    print_notion(L"Gán địa chỉ và cổng cho bind thành công ...");
    Sleep(1000);
    listen(serverSocket, SOMAXCONN);
    print_notion(L"Server đang chờ các kết nối ...");
    sockaddr_in clientAddress;
    int clientSize = sizeof(clientAddress);
    SOCKET clientSocket = accept(serverSocket, (SOCKADDR*)&clientAddress, &clientSize);
    if (clientSocket == INVALID_SOCKET ) {
        print_notion(L"Kết nối với máy khách thất bại!!");
        return 0;
    }
    print_notion(L"Kết nối với máy khách thành công. Đang chờ thông điệp từ máy khách...");
    char results[100] = { 0 }; // nhớ khởi tạo 0 để tránh rác
    int recvLen = recv(clientSocket, results, sizeof(results) - 1, 0); // thêm -1 để dành chỗ cho '\0'
    if (recvLen > 0) {
        results[recvLen] = '\0'; 
        std::string message(results);
        cout << results << endl;
    }


}

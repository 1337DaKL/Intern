#include <winsock2.h>  
#include <windows.h>
#include <iostream>
#include <string>
#include <thread> // <-- Thêm thư viện thread
#pragma comment(lib, "ws2_32.lib")
using namespace std;

void print_notion(string s) {
    HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);

    // Lấy vị trí dòng hiện tại
    CONSOLE_SCREEN_BUFFER_INFO csbi;
    GetConsoleScreenBufferInfo(hOut, &csbi);

    COORD coord;
    coord.X = 50; // Cột 50
    coord.Y = csbi.dwCursorPosition.Y; // Dòng hiện tại

    SetConsoleCursorPosition(hOut, coord);

    s += "\n";
    DWORD real_written;
    WriteConsoleA(hOut, s.c_str(), (DWORD)s.size(), &real_written, NULL);
}


string readMessenge() {
    HANDLE hIn = GetStdHandle(STD_INPUT_HANDLE);
    char results[100] = { 0 };
    DWORD readRead = 0;
    ReadConsoleA(hIn, results, 100, &readRead, NULL);

    if (readRead >= 2 && results[readRead - 2] == '\r' && results[readRead - 1] == '\n') {
        results[readRead - 2] = '\0';
    }
    else {
        results[readRead] = '\0';
    }
    return string(results);
}

// ---------- Hàm nhận tin nhắn ----------
void receiveMessages(SOCKET clientSocket) {
    while (true) {
        char buffer[100] = { 0 };
        int recvLen = recv(clientSocket, buffer, sizeof(buffer) - 1, 0);
        if (recvLen > 0) {
            print_notion("Client: " + string(buffer));
        }
        else {
            print_notion("Client ngat ket noi hoac loi xay ra.");
            break;
        }
    }
}

// ---------- Hàm gửi tin nhắn ----------
void sendMessages(SOCKET clientSocket) {
    while (true) {
        string mess = readMessenge();
        send(clientSocket, mess.c_str(), (int)mess.length(), 0); // Không dùng MSG_OOB
    }
}

int main() {
    WSAData wsaData;
    if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) {
        print_notion("Khoi tao Winsock DLL khong thanh cong.");
        return 0;
    }

    SOCKET serverSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (serverSocket == INVALID_SOCKET) {
        print_notion("Khoi tao Socket khong thanh cong!");
        return 0;
    }

    sockaddr_in linkAddress;
    linkAddress.sin_family = AF_INET;
    linkAddress.sin_addr.s_addr = INADDR_ANY;
    linkAddress.sin_port = htons(12345);

    if (bind(serverSocket, (SOCKADDR*)&linkAddress, sizeof(linkAddress)) != 0) {
        print_notion("Bind khong thanh cong.");
        return 0;
    }

    listen(serverSocket, SOMAXCONN);

    sockaddr_in clientAddress;
    int clientSize = sizeof(clientAddress);
    SOCKET clientSocket = accept(serverSocket, (SOCKADDR*)&clientAddress, &clientSize);
    if (clientSocket == INVALID_SOCKET) {
        print_notion("Ket noi voi may khach that bai!");
        return 0;
    }

    print_notion("Ket noi voi may khach thanh cong.");

    // ----- Tạo 2 luồng -----
    thread receiveThread(receiveMessages, clientSocket);
    thread sendThread(sendMessages, clientSocket);

    // Đợi cả 2 luồng kết thúc (sẽ không bao giờ xảy ra trừ khi có lỗi hoặc client thoát)
    receiveThread.join();
    sendThread.join();

    closesocket(clientSocket);
    closesocket(serverSocket);
    WSACleanup();
    return 0;
}

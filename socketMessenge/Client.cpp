#define _WINSOCK_DEPRECATED_NO_WARNINGS
#include <winsock2.h>
#include <windows.h>
#include <ws2tcpip.h>
#include <iostream>
#include <string>
#include <thread>
#pragma comment(lib, "ws2_32.lib")
using namespace std;

string readMessenge() {
    HANDLE hIn = GetStdHandle(STD_INPUT_HANDLE);
    char results[100] = { 0 };
    DWORD readRead;
    ReadConsoleA(hIn, results, 100, &readRead, NULL);
    if (readRead >= 2 && results[readRead - 2] == '\r' && results[readRead - 1] == '\n') {
        results[readRead - 2] = '\0';
    }
    else {
        results[readRead] = '\0';
    }
    return string(results);
}

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


void receiveMessages(SOCKET clientSocket) {
    while (true) {
        char results[100] = { 0 };
        int recvLen = recv(clientSocket, results, sizeof(results) - 1, 0);
        if (recvLen <= 0) {
            print_notion("Server da dong hoac co loi");
            break;
        }
        print_notion("Server: " + string(results));
    }
}

void sendMessages(SOCKET clientSocket) {
    while (true) {
        string messenger = readMessenge();
        send(clientSocket, messenger.c_str(), (int)messenger.length(), 0);
    }
}

int main() {
    WSAData wsaData;
    if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) {
        print_notion("Khoi tao Winsock DLL khong thanh cong.");
        return 0;
    }

    SOCKET clientSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (clientSocket == INVALID_SOCKET) {
        print_notion("Khoi tao Socket khong thanh cong!!");
        return 0;
    }

    sockaddr_in server = {};
    server.sin_family = AF_INET;
    server.sin_port = htons(12345);
    InetPton(AF_INET, L"127.0.0.1", &server.sin_addr);

    if (connect(clientSocket, (sockaddr*)&server, sizeof(server)) != 0) {
        print_notion("Ket noi toi server khong thanh cong!!");
        return 0;
    }


    thread recvThread(receiveMessages, clientSocket);
    thread sendThread(sendMessages, clientSocket);

    recvThread.join();
    sendThread.join();

    closesocket(clientSocket);
    WSACleanup();
    return 0;
}

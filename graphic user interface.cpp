#include <windows.h>
#include <string>
#include<iostream>
using namespace std;
wstring hoanDoi(wstring s) {
    wstring ok = L"";
    for (int i = size(s) - 1; i >= 0; i--) {
        ok += s[i];
    }
    return ok;
}
wstring hoaThuong(wstring s) {
    wstring ok = L"";
    for(auto it : s){ 
        if (iswalpha(it)) {
            if (iswupper(it)) {
                ok += towlower(it);
            }
            else {
                ok += towupper(it);
            }
        }
        else {
            ok += it;
        }
    }
    return ok;
}
LRESULT CALLBACK Wndproc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
        case WM_CREATE:
            return 0;
        case WM_COMMAND: {
            int id = (int)wParam;
            HWND hButton = GetDlgItem(hWnd, 1);
            HWND hInput = GetDlgItem(hWnd, 4);
            HWND hOutput = GetDlgItem(hWnd, 6);
            HWND hCheckbox = GetDlgItem(hWnd, 2);
            if (id == 1) {
                wchar_t results[100];
                GetWindowTextW(hInput, results, 100);
                if (wcslen(results) == 0) {
                    MessageBoxW(hWnd, L"Kí tự không được để trống!! Vui lòng nhập kí tự muốn hoán đổi", NULL, NULL);
                }
                else {
                    if (size(results) > 2) {
                        if (results[size(results) - 1] == '\n' && results[size(results) - 2] == '\r') {
                            results[size(results) - 2] = '\0';
                        }
                    }
                    else {
                        results[size(results)] = '\0';
                    }
                    wstring result_ouput = hoanDoi(wstring(results));
                    LRESULT status = SendMessage(hCheckbox, BM_GETCHECK, NULL, NULL);
                    if (status == BST_CHECKED) {
                        result_ouput = hoaThuong(result_ouput);
                    }
                    SetWindowTextW(hOutput, result_ouput.c_str());
                }
                return 0;
            }
            else if (id == 2) {
                LRESULT status = SendMessage(hCheckbox, BM_GETCHECK, NULL, NULL);
                if (status == BST_CHECKED) {
                    SendMessage(hCheckbox, BM_SETCHECK, BST_UNCHECKED, NULL);
                }
                else {
                    SendMessage(hCheckbox, BM_SETCHECK, BST_CHECKED, NULL);
                }
            }
            return 0;
        }
        case WM_DESTROY:
            PostQuitMessage(0);
            return 0;

        default:
            return DefWindowProc(hWnd, uMsg, wParam, lParam);
    }
}


int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE, LPSTR, int nCmdShow) {
    WNDCLASSW wc = { 0 };
    wc.style = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc = Wndproc;
    wc.hInstance = hInstance;
    wc.hIcon = LoadIcon(NULL, IDI_ERROR);
    wc.hCursor = LoadCursor(NULL, IDC_HAND);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    wc.lpszMenuName = NULL;
    wc.lpszClassName = L"MyWindowClass";

    RegisterClassW(&wc);

    HWND hwnd = CreateWindowExW(
        0,
        L"MyWindowClass",
        L"Hoán đổi kí tự",
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT,
        CW_USEDEFAULT,
        500, 300,
        NULL, NULL,
        hInstance,
        NULL
    );
    HWND hButton = CreateWindowExW(
        0,
        L"BUTTON",
        L"Hoán đổi",
        WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,
        380,
        220,
        80,
        25,
        hwnd,
        (HMENU)1,
        hInstance,
        NULL

    );
    HWND hCheckbox = CreateWindowExW(
        0,
        L"BUTTON",
        L"Hoán đổi hoa/ thường",
        WS_CHILD | WS_VISIBLE | BS_CHECKBOX,
        20,
        180,
        180,
        20,
        hwnd,
        (HMENU) 2,
        hInstance,
        NULL
    );
    HWND hText = CreateWindowExW(
        0,
        L"STATIC",
        L"NHẬP KÍ TỰ MUỐN THỰC HIỆN HOÁN ĐỔI",
        WS_CHILD | WS_VISIBLE | SS_LEFT,
        90,
        0,
        290,
        20,
        hwnd,
        (HMENU) 3,
        hInstance,
        NULL
    );
    HWND hInput = CreateWindowExW(
        0,
        L"EDIT",
        NULL,
        WS_CHILD | WS_VISIBLE | WS_BORDER | ES_LEFT,
        0,
        30,
        484,
        40,
        hwnd,
        (HMENU) 4,
        hInstance,
        NULL
    );
    HWND hNotionOutput = CreateWindowExW(
        0,
        L"STATIC",
        L"KẾT QUẢ CỦA HOÁN ĐỔI LÀ",
        WS_CHILD | WS_VISIBLE | ES_LEFT,
        120,
        85,
        200,
        20,
        hwnd,
        (HMENU) 5,
        hInstance,
        NULL
    );
    HWND hOutut = CreateWindowExW(
        0,
        L"STATIC",
        NULL,
        WS_CHILD | WS_VISIBLE | WS_BORDER | ES_LEFT,
        0,
        120,
        484,
        40,
        hwnd,
        (HMENU)6,
        hInstance,
        NULL
    );
    if (!hwnd) {
        MessageBoxA(NULL, "Failed to create window", "Error", MB_ICONERROR);
        
        return 0;
    }
    ShowWindow(hwnd, nCmdShow);
    UpdateWindow(hwnd);

    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return (int)msg.wParam;
}

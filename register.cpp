#include <windows.h>
#include <tlhelp32.h>
#include <stdio.h>
#include <string>
#include <winreg.h>
#include<iostream>
using namespace std;
HANDLE h_in = GetStdHandle(STD_INPUT_HANDLE);
HANDLE h_out = GetStdHandle(STD_OUTPUT_HANDLE);
DWORD real;
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
int select_option() {
	char option[100];
	ReadConsoleA(
		h_in,
		option,
		100,
		&real,
		NULL
	);
	return atoi(option);
}
HKEY select_key_root(string s) {
	print_notion("Chon mot trong nhung key root sau de thuc hien " + s);
	print_notion("1. HKEY_CLASSES_ROOT");
	print_notion("2. HKEY_CURRENT_USER");
	print_notion("3. HKEY_LOCAL_MACHINE");
	print_notion("4. HKEY_USERS");
	print_notion("5. HKEY_CURRENT_CONFIG");
	print_notion("Chon Key Root:");
	int option = select_option();
	if (option == 1) {
		return HKEY_CLASSES_ROOT;
	}
	if (option == 2) {
		return HKEY_CURRENT_USER;
	}
	if (option == 3) {
		return HKEY_LOCAL_MACHINE;
	}
	if (option == 4) {
		return HKEY_USERS;
	}
	if (option == 5) {
		return HKEY_CURRENT_CONFIG;
	}
	print_notion("Vui long chon mot trong nhung root tren!! Chon 1 de thuc hien lai hoac chon 0 de thoat khoi chuong trinh.");
	int option_second = select_option();
	if (option_second == 1) {
		select_key_root(s);
	}
	else {
		return NULL;
	}
}
HKEY create_key(HKEY h_key, const char* name_key) {
	HKEY result_key;
	DWORD exits;
	LONG res = RegCreateKeyExA(
		h_key,
		name_key,
		0,
		NULL,
		REG_OPTION_NON_VOLATILE,
		KEY_ALL_ACCESS,
		NULL,
		&result_key,
		&exits
	);
	if (res == ERROR_SUCCESS) {
		if (exits == REG_CREATED_NEW_KEY) {
			print_notion("Them key thanh cong!!");
			return result_key;
		}
		print_notion("Key da ton tai");
		return NULL;
	}
	else {
		print_notion("Tao key that bai. Ma loi: " + to_string(res));
		return NULL;
	}
}

void for_loop() {
	system("cls");
	print_notion("------------------------");
	print_notion("===MENU===");
	print_notion("1. Them key");
	print_notion("2. Doc value key");
	print_notion("3. Sua value key");
	print_notion("4. Xoa key");
	print_notion("5. Thoat chuong trinh");
	print_notion("Nhap lua chon ban mong muon:");
	int option = select_option();
	if (option == 1) {
		HKEY option_key = select_key_root("them key");
		if (option_key == NULL) {
			print_notion("Thoat chuong trinh thanh cong");
			return;
		}
		//main
		print_notion("Nhap ten key ban muon thuc hien chuc nang:");
		char name_key[100];
		ReadConsoleA(h_in, name_key, 100, &real, NULL);
		if (real >= 2 && name_key[real - 2] == '\r' && name_key[real - 1] == '\n') {
			name_key[real - 2] = '\0';
		}
		else {
			name_key[real] = '\0';
		}
		HKEY h_key = create_key(option_key, name_key);
		RegCloseKey(option_key);
		Sleep(10000);
		for_loop();
	}
	if (option == 2) {
		HKEY option_key = select_key_root("doc value key");
		if (option_key == NULL) {
			print_notion("Thoat chuong trinh thanh cong");
			return;
		}
		//main
	}
	if (option == 3) {
		HKEY option_key = select_key_root("Sua value key");
		if (option_key == NULL) {
			print_notion("Thoat chuong trinh thanh cong");
			return;
		}
		//main
	}
	
	if (option == 4) {
		HKEY option_key = select_key_root("xoa key");
		if (option_key == NULL) {
			print_notion("Thoat chuong trinh thanh cong");
			return;
		}
		//main
	}
	if (option == 5) {
		print_notion("Thoat chuong trinh thanh cong");
		return;
	}
	print_notion("Vui long chon 1 trong cac lua chon tren! Nhap 1 de thuc hien lai hoac nhap 0 de thoat chuong trinh.");
	int option_second = select_option();
	if (option_second == 1) {
		for_loop();
	}
	else {
		print_notion("Thoat chuong trinh thanh cong");
		return;
	}
}

int main() {
	for_loop();
}

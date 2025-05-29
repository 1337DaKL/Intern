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
void print_notion(string s)	 {
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
	system("cls");
	print_notion("Chon mot trong nhung key root sau de thuc hien " + s);
	print_notion("1. HKEY_CLASSES_ROOT");
	print_notion("2. HKEY_CURRENT_USER");
	print_notion("3. HKEY_LOCAL_MACHINE");
	print_notion("4. HKEY_USERS");
	print_notion("5. HKEY_CURRENT_CONFIG");
	print_notion("Chon Key Root:");
	int option = select_option();
	//return (option == 1) ? HKEY_CLASSES_ROOT : (option == 2) ? HKEY_CURRENT_USER : (option == 3) ? HKEY_CURRENT_USER : (option == 4) ? HKEY_USERS : (option == 5) ? HKEY_CURRENT_CONFIG :  ;
	if (option == 1) return HKEY_CLASSES_ROOT;
	if (option == 2) return HKEY_CURRENT_USER;
	if (option == 3) return HKEY_LOCAL_MACHINE;
	if (option == 4) return HKEY_USERS;
	if (option == 5) return HKEY_CURRENT_CONFIG;
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
		print_notion("Chon 1 de quay lai hoac chon 0 de thoat khoi chuong trinh.");
		int choose_option = select_option();
		if (choose_option == 1) {
			for_loop();
		}
		else {
			print_notion("Thoat chuong trinh thanh cong");
			return;
		}
	}
	else if (option == 2) {
		HKEY option_key = select_key_root("doc value key");
		if (option_key == NULL) {
			print_notion("Thoat chuong trinh thanh cong");
			return;
		}
		//main
		string value_key;
		DWORD size_value = sizeof(value_key);
		print_notion("Nhap key muon doc neu khong nhap thi se doc tu key root");
		char key[100];
		DWORD real_key;
		ReadConsoleA(
			h_in,
			key,
			100,
			&real_key,
			NULL
		);
		print_notion("Nhap ten value can doc gia tri, neu khong nhap gi thi se doc gia tri default cua key ");
		char value_name[100];
		DWORD real_name_value;
		ReadConsoleA(
			h_in, 
			value_name,
			100,
			&real_name_value,
			NULL
		);
		if (real_key >= 2 && key[real_key - 2] == '\r' && key[real_key - 1] == '\n')
			key[real_key - 2] = '\0';
		else
			key[real_key] = '\0';

		if (real_name_value >= 2 && value_name[real_name_value - 2] == '\r' && value_name[real_name_value - 1] == '\n')
			value_name[real_name_value - 2] = '\0';
		else
			value_name[real_name_value] = '\0';
		const char* key_read = real_key == 0 ? NULL : key;
		const char* name_value_read = real_name_value == 0 ? NULL : value_name;
		DWORD data_size = sizeof(DWORD);
		DWORD data;
		DWORD type;
		LONG results = RegGetValueA(
			option_key,
			key_read,
			name_value_read,
			RRF_RT_ANY,
			&type,
			&data,
			&data_size
		);
		if (results == ERROR_SUCCESS) {
			print_notion("Ket qua value la: " + to_string(data));
			print_notion("Chon 1 de quay lai hoac chon 0 de thoat khoi chuong trinh.");
			int choose_option = select_option();
			if (choose_option == 1) {
				for_loop();
			}
			else {
				print_notion("Thoat chuong trinh thanh cong");
				return;
			}
		}
		print_notion("Khong tim duoc value can doc!! Chon 1 de quay lai hoac chon 0 de thoat khoi chuong trinh.");
		int choose_option = select_option();
		if (choose_option == 1) {
			for_loop();
		}
		else {
			print_notion("Thoat chuong trinh thanh cong");
			return;
		}
	}
	else if (option == 3) {
		HKEY option_key = select_key_root("Sua value key");
		if (option_key == NULL) {
			print_notion("Thoat chuong trinh thanh cong");
			return;
		}
		//main
		print_notion("Nhap key ban muon sua value neu khong nhap se sua value trong keyroot:");
		char key_change[100];
		ReadConsoleA(
			h_in,
			key_change,
			100,
			&real,
			NULL
		);
		
		if (real >= 2 && key_change[real - 2] == '\r' && key_change[real - 1] == '\n') key_change[real - 2] = '\0';
		else key_change[real] = '\0';
		const char* key = (real == 0) ? NULL : key_change;
		HKEY hkey;
		LONG results = RegOpenKeyExA(
			option_key,
			key,
			0,
			KEY_WRITE,
			&hkey
		);
		if (results == ERROR_SUCCESS) {
			print_notion("Nhap value name ban muon sua:");
			char name_value[100];
			ReadConsoleA(
				h_in,
				name_value,
				100,
				&real,
				NULL
			);
			if (real >= 2 && name_value[real - 2] == '\r' && name_value[real - 1] == '\n') name_value[real - 2] = '\0';
			else name_value[real] = '\0';
			print_notion("Nhap gia tri value ban muon sua:");
			char data[100];
			ReadConsoleA(
				h_in ,
				data,
				100,
				&real,
				NULL
			);
			if (real >= 2 && data[real - 2] == '\r' && data[real - 1] == '\n') data[real - 2] = '\0';
			else data[real] = '\0';
			LONG results_in = RegSetValueExA(
				hkey,
				name_value,
				0,
				REG_SZ,
				(LPBYTE)data,
				(DWORD)size(data)
			);
			if (results_in == ERROR_SUCCESS) {
				print_notion("Sua value thanh cong");
				print_notion("Chon 1 de quay lai hoac chon 0 de thoat khoi chuong trinh.");
				int choose_option = select_option();
				if (choose_option == 1) {
					for_loop();
				}
				else {
					print_notion("Thoat chuong trinh thanh cong");
					return;
				}
			}
			else {
				print_notion("Sua value that bai!! Nhap 1 de quay lai chuong trinh hoac nhap 0 de ket thuc chuong trinh");
				int choose_option = select_option();
				if (choose_option == 1) {
					for_loop();
				}
				else {
					print_notion("Thoat chuong trinh thanh cong");
					return;
				}
			}
		}
		else {
			print_notion("Khong tim thay key ban can tim!! Nhap 1 de quay lai chuong trinh nhap 0 de thoat khoi chuong trinh");
			int choose_option = select_option();
			if (choose_option == 1) {
				for_loop();
			}
			else {
				print_notion("Thoat chuong trinh thanh cong");
				return;
			}
		}
	}
	
	else if (option == 4) {
		HKEY option_key = select_key_root("xoa key");
		if (option_key == NULL) {
			print_notion("Thoat chuong trinh thanh cong");
			return;
		}
		//main
		print_notion("Nhap key ban muon xoa:");
		char key_deleted[100];
		ReadConsoleA(
			h_in,
			key_deleted,
			100,
			&real,
			NULL
		);
		if (real == 0) {
			print_notion("Key khong duoc rong!! Nhap 1 de quay lai chuong trinh nhap 0 de thoat khoi chuong trinh");
			int option = select_option();
			if (option == 1) {
				for_loop();
			}
			return;
		}
		if (real >= 2 && key_deleted[real - 2] == '\r' && key_deleted[real - 1] == '\n') {
			key_deleted[real - 2] = '\0';
		}
		else {
			key_deleted[real] = '\0';
		}
		const char* key_del = string(key_deleted).c_str();
		LONG results = RegDeleteKeyA(
			option_key,
			key_deleted
		);
		if (results == ERROR_SUCCESS) {
			print_notion("Xoa key thanh cong");
			print_notion("Chon 1 de quay lai hoac chon 0 de thoat khoi chuong trinh.");
			int choose_option = select_option();
			if (choose_option == 1) {
				for_loop();
			}
			else {
				print_notion("Thoat chuong trinh thanh cong");
				return;
			}
		}
		else {
			print_notion("Xoa key that bai!! Nhap 1 de quay lai chuong trinh nhap 0 de thoat khoi chuong trinh");
			int option = select_option();
			if (option == 1) {
				for_loop();
			}
			return;
		}
	}
	else if (option == 5) {
		print_notion("Thoat chuong trinh thanh cong");
		return;
	}
	else {
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
}

int main() {
	for_loop();
}

// MessDgl.cpp : implementation file
//

#include "pch.h"
#include "Client1.h"
#include "MessDgl.h"
#include "afxdialogex.h"
#include <regex>
#include<thread>
#include<string>
using namespace std;
// MessDgl dialog

IMPLEMENT_DYNAMIC(MessDgl, CDialogEx)

MessDgl::MessDgl(CWnd* pParent /*=nullptr*/)
	: CDialogEx(IDD_DIALOG2, pParent)
{
	

}

MessDgl::~MessDgl()
{
}

void MessDgl::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_BUTTON2, buttonSend);
	DDX_Control(pDX, IDC_EDIT1, inputMess);
	DDX_Control(pDX, IDC_LIST1, listMess);
}


BEGIN_MESSAGE_MAP(MessDgl, CDialogEx)
	ON_BN_CLICKED(IDC_BUTTON2, &MessDgl::OnBnClickedButton2)
	ON_MESSAGE(WM_USER + 10 , &MessDgl::printMess)
END_MESSAGE_MAP()

void getMess(SOCKET clientSocket , MessDgl* messDgl);

BOOL MessDgl::OnInitDialog() {
	CDialogEx::OnInitDialog();
	CString msg;
	msg.Format(L"Bạn đang nhắn tin với %S", this->usernameFinish.c_str());
	this->SetWindowText(msg);
	this->listMess.InsertColumn(0, _T("Da gui"), LVCFMT_LEFT, 265);
	this->listMess.InsertColumn(1, _T("Da nhan"), LVCFMT_RIGHT, 265);
	this->index = 0;
	thread(getMess, this->clientSocket , this).detach();
	return TRUE;
}


LRESULT MessDgl::printMess(WPARAM wParam, LPARAM lParam) {
	const char* mess = reinterpret_cast<const char*>(wParam);
	string messSendServer = string(mess).substr(1);
	regex re("-+");
	sregex_token_iterator it(messSendServer.begin(), messSendServer.end(), re, -1);
	sregex_token_iterator end;
	vector<string> result(it, end);
	string messSend = result[0];
	string messGet = result[1];
	string messResults = "";
	for (int i = 2; i < result.size(); i++) {
		if (i == result.size() - 1) {
			messResults += result[i];
		}
		else {
			messResults += result[i] + "-";
		}
	}
	if (this->username == messGet && this->usernameFinish == messSend) {
		this->listMess.InsertItem(this->index, L"");
		this->listMess.SetItemText(this->index, 1, CString(messResults.c_str()));
		this->index++;
	}
	return 0;
}

void MessDgl::OnBnClickedButton2()
{
	CString inputMessenge;
	this->inputMess.GetWindowTextW(inputMessenge);
	string input = CT2A(inputMessenge);
	if (input.length() == 0) {
		MessageBoxA(this->GetSafeHwnd(), "Tin nhan khong duoc de trong", "notion", MB_OK);
	}
	else {
		string inputReal = this->username + "-" + this->usernameFinish + "-" + input;
		this->listMess.InsertItem(this-> index ++, inputMessenge);
		this->inputMess.SetWindowTextW(L"");
		send(this->clientSocket, inputReal.c_str(), inputReal.length(), 0);
		Sleep(200);
		send(this->clientSocket, inputReal.c_str(), inputReal.length(), 0);

	}
}
void getMess(SOCKET clientSocket , MessDgl* messDgl) {
	while (true) {
		char mess[1000000] = { 0 };
		int results = recv(clientSocket, mess, sizeof(mess), 0);
		if (results != 0) {
			if (mess[0] == '%') {
				string messGet = string(mess);
				char* msg = new char[messGet.size() + 1];
				strcpy_s(msg, messGet.size() + 1, string(mess).c_str());
				::PostMessage(messDgl->GetSafeHwnd(), WM_USER + 10, (WPARAM)msg, 0);
			}
		}
	}
}



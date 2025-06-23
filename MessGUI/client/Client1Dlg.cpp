#include "pch.h"                         
#include "framework.h"
#include "Client1.h"
#include "Client1Dlg.h"
#include "MessDgl.h"
#include "afxdialogex.h"
#include "ViewListUserOnline.h"
#include <winsock2.h>                    
#include <ws2tcpip.h>                    
#include <iostream>
#include <string>
#include <thread>
#include<regex>
#include<set>

#pragma comment(lib, "ws2_32.lib")

SOCKET clientSocket = INVALID_SOCKET;
using namespace std;
#ifdef _DEBUG
#define new DEBUG_NEW
#endif

class CAboutDlg : public CDialogEx
{
public:
	CAboutDlg();

#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_ABOUTBOX };
#endif

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialogEx(IDD_ABOUTBOX)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialogEx)
END_MESSAGE_MAP()

CClient1Dlg::CClient1Dlg(CWnd* pParent /*=nullptr*/)
	: CDialogEx(IDD_CLIENT1_DIALOG, pParent)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CClient1Dlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_EDIT1, userName);
	DDX_Control(pDX, IDC_BUTTON1, buttonLogin);
}

BEGIN_MESSAGE_MAP(CClient1Dlg, CDialogEx)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_EN_CHANGE(IDC_EDIT1, &CClient1Dlg::OnEnChangeEdit1)
	ON_BN_CLICKED(IDC_BUTTON1, &CClient1Dlg::OnBnClickedButton1)
	ON_MESSAGE(WM_USER + 1, &CClient1Dlg::OnUpdateUserList)
	ON_COMMAND_RANGE(1001, 1099, &CClient1Dlg::OnClickButtonUserOnline)
END_MESSAGE_MAP()
BOOL CClient1Dlg::OnInitDialog()
{
	CDialogEx::OnInitDialog();
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != nullptr)
	{
		BOOL bNameValid;
		CString strAboutMenu;
		bNameValid = strAboutMenu.LoadString(IDS_ABOUTBOX);
		ASSERT(bNameValid);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CClient1Dlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialogEx::OnSysCommand(nID, lParam);
	}
}


void CClient1Dlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon); 
	}
	else
	{
		CDialogEx::OnPaint();
	}
}

HCURSOR CClient1Dlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}

void CClient1Dlg::OnEnChangeEdit1()
{
}





void getMesssenger(string username, CClient1Dlg* pDlg) {
	while (true) {
		char mess[100000] = { 0 };
		recv(clientSocket, mess, sizeof(mess), 0);
		if (mess != "") {
			if (string(mess)[0] == '-') {
				regex re("-+");
				string messageStr(mess);
				sregex_token_iterator it(messageStr.begin(), messageStr.end(), re, -1);
				sregex_token_iterator end;
				vector<string> result(it, end);
				set<string> allUsernameOnline;
				for (auto it : result) {
					if (it != username && it != "") {
						allUsernameOnline.insert(it);
					}

				}
				::PostMessage(pDlg->m_hWnd, WM_USER + 1, (WPARAM)new set<string>(allUsernameOnline), 0);
			}
			else if (string(mess)[0] == '*') {
				string userRequest = string(mess).substr(1);
				string notion = "Username: " + userRequest + " dang co yeu cau ket noi";
				int resultsNotion = MessageBoxA(pDlg->GetSafeHwnd(), notion.c_str() , "notion", MB_YESNO);
				if (resultsNotion == IDYES) {
					string responseConnect = "^" + userRequest;
					send(clientSocket, responseConnect.c_str(), sizeof(responseConnect), 0);
					MessDgl messDgl;
					messDgl.pParent = pDlg;
					messDgl.clientSocket = clientSocket;
					messDgl.usernameFinish = userRequest;
					CString username;
					pDlg->userName.GetWindowTextW(username);
					CT2A name(username);
					string usernameStart(name);
					messDgl.username = usernameStart;
					messDgl.DoModal();
				}
				else {
					string responseConnect = "@" + userRequest;
					send(clientSocket, responseConnect.c_str(), sizeof(responseConnect), 0);
				}
			}
			else if (string(mess)[0] == '$') {
				string userFinish = string(mess).substr(1);
				string notion = "Ket noi toi " + userFinish + " thanh cong";
				int resultsNotion = MessageBoxA(pDlg->m_hWnd, notion.c_str(), "notion", MB_OK);
					MessDgl messDgl;
					messDgl.pParent = pDlg;
					messDgl.clientSocket = clientSocket;
					messDgl.usernameFinish = userFinish;
					CString username;
					pDlg->userName.GetWindowTextW(username);
					CT2A name(username);
					string usernameStart(name);
					messDgl.username = usernameStart;
					messDgl.DoModal();
			}
			else if (string(mess)[0] == '@') {
				string userFinish = string(mess).substr(1);
				string notion = "Username: " + userFinish + " khong chap nhan ket noi";
				MessageBoxA(pDlg->m_hWnd, notion.c_str(), "notion", MB_OK);
			}
		}
		Sleep(1000);
	}
}

void CClient1Dlg::OnClickButtonUserOnline(UINT nID)
{
	int index = nID - 1001;
	
	CString name;
	buttons[index]->GetWindowTextW(name);
	CString msg;
	msg.Format(L"Ban co muon ket noi voi username %s", name);
	int resultsConnect = MessageBoxW( msg, L"Thông báo", MB_OKCANCEL);
	if (resultsConnect == IDOK) {
		
		MessDgl messDgl;
		CT2A un(name);
		string usernameFinish(un);
		string messSend = "*" + usernameFinish;
		send(clientSocket, messSend.c_str(), sizeof(messSend), 0);
	}

}

LRESULT CClient1Dlg::OnUpdateUserList(WPARAM wParam, LPARAM lParam) {
	auto userSet = (set<string>*)wParam;
	for (auto btn : buttons) {
		btn->DestroyWindow();
		delete btn;
	}
	buttons.clear();

	int index = 0;
	for (const auto& user : *userSet) {
		CString username;
		username.Format(L"%S", user.c_str());

		CButton* pBtn = new CButton();
		int cols = 4;
		int padding = 10;
		int width = 100;
		int height = 30;

		int col = index % cols;
		int row = index / cols;

		int left = 20 + col * (width + padding);
		int top = 110 + row * (height + padding);
		int right = left + width;
		int bottom = top + height;

		CRect rect(left, top, right, bottom);

		pBtn->Create(username, WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON, rect, this, 1001 + index++);

		buttons.push_back(pBtn);
	}

	delete userSet;
	return 0;
}

void CClient1Dlg::OnBnClickedButton1()
{	
	CString textButton;
	buttonLogin.GetWindowTextW(textButton);

	if (textButton == L"Đăng nhập") {
		CString value;
		userName.GetWindowTextW(value);
		if (value == "") {
			MessageBoxA(this->GetSafeHwnd(), "Vui long nhap username de dang nhap", "notion", MB_OK);
		}
		else {
			WSAData wsaData;
			if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) {

			}

			clientSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
			if (clientSocket == INVALID_SOCKET) {
			}

			sockaddr_in server = {};
			server.sin_family = AF_INET;
			server.sin_port = htons(12345);
			InetPton(AF_INET, _T("127.0.0.1"), &server.sin_addr);
			if (connect(clientSocket, (sockaddr*)&server, sizeof(server)) != 0) {
				MessageBoxA(this->GetSafeHwnd(), "Ket noi server khong thanh cong", "Thong bao", MB_OK);
			}
			else {
				CT2A asciiStr(L"/" + value);
				send(clientSocket, asciiStr, (int)strlen(asciiStr), 0);
				char response[10000] = { 0 };
				while (recv(clientSocket, response, sizeof(response), 0)) {
					if (sizeof(response)) {
						//MessageBoxA(NULL, response, "notion", MB_OK);
						if (strcmp(response, "/e") == 0) {
							MessageBoxA(this->GetSafeHwnd(), "Username da ton tai vui long chon username khac", "notion", MB_OK);
						}
						else if(strcmp(response , "/l") == 0) {
							CT2A un(value);
							string usernameStr(un);
							thread(getMesssenger, usernameStr, this).detach();
							MessageBoxA(this->GetSafeHwnd(), "Dang nhap thanh cong", "notion", MB_OK);
							userName.SetReadOnly(true);
							buttonLogin.SetWindowTextW(L"Đăng xuất");
							
						}
						break;
					}
				}
			
			}
		}
		
	}
	else if(textButton == L"Đăng xuất") {
		int notionLogout = MessageBoxA(this->GetSafeHwnd(), "Ban co muon dang xuat hay khong", "notion", MB_OKCANCEL);
		if (notionLogout == IDOK) {
			userName.SetReadOnly(false);
			userName.SetWindowTextW(L"");
			buttonLogin.SetWindowTextW(L"Đăng nhập");
			closesocket(clientSocket);
			for (auto btn : buttons) {
				btn->DestroyWindow();
				delete btn;
			}
			buttons.clear();
			clientSocket = INVALID_SOCKET;
		}	
	}
}



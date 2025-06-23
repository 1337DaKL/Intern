// MessDgl.cpp : implementation file
//

#include "pch.h"
#include "Client1.h"
#include "MessDgl.h"
#include "afxdialogex.h"


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
}


BEGIN_MESSAGE_MAP(MessDgl, CDialogEx)

	ON_BN_CLICKED(IDC_BUTTON2, &MessDgl::OnBnClickedButton2)
END_MESSAGE_MAP()


// MessDgl message handlers
BOOL MessDgl::OnInitDialog() {
	CDialogEx::OnInitDialog();
	CString msg;
	msg.Format(L"Bạn đang nhắn tin với %S", this->usernameFinish.c_str());
	this->SetWindowText(msg);
	return TRUE;
}

void MessDgl::OnBnClickedButton2()
{
	MessageBoxA(this->GetSafeHwnd(), "Click send", "notion", 0);
}



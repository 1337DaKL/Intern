#include "Client1Dlg.h"
#include<string>
#include<winsock.h>
using namespace std;
#pragma once


// MessDgl dialog

class MessDgl : public CDialogEx
{
	DECLARE_DYNAMIC(MessDgl)

public:
	MessDgl(CWnd* pParent = nullptr);   // standard constructor
	virtual ~MessDgl();
	CClient1Dlg* pParent;
	string username;
	SOCKET clientSocket;
	string usernameFinish;
	virtual BOOL OnInitDialog();
// Dialog Data
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_DIALOG2 };
#endif

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnBnClickedButton2();
};

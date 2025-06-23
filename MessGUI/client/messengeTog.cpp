// messengeTog.cpp : implementation file
//

#include "pch.h"
#include "Client1.h"
#include "messengeTog.h"
#include "afxdialogex.h"


// messengeTog dialog

IMPLEMENT_DYNAMIC(messengeTog, CDialogEx)

messengeTog::messengeTog(CWnd* pParent /*=nullptr*/)
	: CDialogEx(IDD_DIALOG2, pParent)
{

}

messengeTog::~messengeTog()
{
}

void messengeTog::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_EDIT1, inputMess);
	DDX_Control(pDX, IDC_LIST1, viewMess);
	DDX_Control(pDX, IDC_BUTTON2, buttonSend);
}


BEGIN_MESSAGE_MAP(messengeTog, CDialogEx)
END_MESSAGE_MAP()


// messengeTog message handlers

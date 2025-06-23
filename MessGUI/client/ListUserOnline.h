#pragma once


// ListUserOnline dialog

class ListUserOnline : public CDialogEx
{
	DECLARE_DYNAMIC(ListUserOnline)

public:
	ListUserOnline(CWnd* pParent = nullptr);   // standard constructor
	virtual ~ListUserOnline();

// Dialog Data
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_DIALOG1 };
#endif

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	DECLARE_MESSAGE_MAP()
};

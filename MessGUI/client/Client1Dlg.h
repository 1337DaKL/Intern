
// Client1Dlg.h : header file
//
#include<vector>
#pragma once


// CClient1Dlg dialog
class CClient1Dlg : public CDialogEx
{
// Construction
public:
	CClient1Dlg(CWnd* pParent = nullptr);	// standard constructor
// Dialog Data
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_CLIENT1_DIALOG };
#endif

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support


// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg LRESULT OnUpdateUserList(WPARAM wParam, LPARAM lParam);
	afx_msg void OnClickButtonUserOnline(UINT nID);
	//afx_msg void OnClickButtonUserOnline(UINT nID);
	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnEnChangeEdit1();
	afx_msg void OnBnClickedButton1();
	CEdit userName;
	CButton buttonLogin;
	std::vector<CButton*> buttons;
};

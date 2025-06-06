
// GuiInforFileDlg.h : header file
//

#pragma once


// CGuiInforFileDlg dialog
class CGuiInforFileDlg : public CDialogEx
{
// Construction
public:
	CGuiInforFileDlg(CWnd* pParent = nullptr);	// standard constructor

// Dialog Data
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_GUIINFORFILE_DIALOG };
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
	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnLvnItemchangedList1(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnBnClickedButtonStart();
	afx_msg void OnEnChangeMfceditbrowse1();
	// Lay duong dan folder can xu li
	CMFCEditBrowseCtrl folderInput;
	CListCtrl listFolder;
};

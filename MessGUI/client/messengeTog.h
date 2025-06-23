#pragma once


// messengeTog dialog

class messengeTog : public CDialogEx
{
	DECLARE_DYNAMIC(messengeTog)

public:
	messengeTog(CWnd* pParent = nullptr);   // standard constructor
	virtual ~messengeTog();

// Dialog Data
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_DIALOG2 };
#endif

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	DECLARE_MESSAGE_MAP()
public:
	CEdit inputMess;
	CListBox viewMess;
	CButton buttonSend;
	afx_msg void OnBnClickedButton2();
};

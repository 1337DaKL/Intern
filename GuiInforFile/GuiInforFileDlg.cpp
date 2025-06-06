
// GuiInforFileDlg.cpp : implementation file
//

#include "pch.h"
#include "framework.h"
#include "GuiInforFile.h"
#include "GuiInforFileDlg.h"
#include "afxdialogex.h"
#include <windows.h>
#include <iostream>
#include <vector>
#include <string>

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

using namespace ATL;
using namespace std;

// CAboutDlg dialog used for App About

class CAboutDlg : public CDialogEx
{
public:
	CAboutDlg();

// Dialog Data
#ifdef AFX_DESIGN_TIME
	enum { IDD = IDD_ABOUTBOX };
#endif

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);   

// Implementation
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


// CGuiInforFileDlg dialog



CGuiInforFileDlg::CGuiInforFileDlg(CWnd* pParent /*=nullptr*/)
	: CDialogEx(IDD_GUIINFORFILE_DIALOG, pParent)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CGuiInforFileDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_MFCEDITBROWSE1, folderInput);
	DDX_Control(pDX, IDC_LIST1, listFolder);
}

BEGIN_MESSAGE_MAP(CGuiInforFileDlg, CDialogEx)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_NOTIFY(LVN_ITEMCHANGED, IDC_LIST1, &CGuiInforFileDlg::OnLvnItemchangedList1)
	ON_BN_CLICKED(IDC_BUTTON1, &CGuiInforFileDlg::OnBnClickedButtonStart)
	ON_EN_CHANGE(IDC_MFCEDITBROWSE1, &CGuiInforFileDlg::OnEnChangeMfceditbrowse1)
END_MESSAGE_MAP()


// CGuiInforFileDlg message handlers

BOOL CGuiInforFileDlg::OnInitDialog()
{





	CDialogEx::OnInitDialog();
	listFolder.SetExtendedStyle(LVS_EX_FULLROWSELECT | LVS_EX_GRIDLINES | LVS_EX_GRIDLINES);
	listFolder.InsertColumn(0, _T("Tên File/Folder"), LVCFMT_LEFT, 350);
	listFolder.InsertColumn(1, _T("Đường dẫn"), LVCFMT_LEFT, 610);
	listFolder.InsertColumn(2, _T("Loại file"), LVCFMT_LEFT, 200);

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
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

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon



	return TRUE;  
}

void CGuiInforFileDlg::OnSysCommand(UINT nID, LPARAM lParam)
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

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CGuiInforFileDlg::OnPaint()
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

// The system calls this function to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CGuiInforFileDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}



void CGuiInforFileDlg::OnLvnItemchangedList1(NMHDR* pNMHDR, LRESULT* pResult)
{
	LPNMLISTVIEW pNMLV = reinterpret_cast<LPNMLISTVIEW>(pNMHDR);
	// TODO: Add your control notification handler code here
	*pResult = 0;
}



vector<pair<wstring, wstring>> listNameFileAndFolder;
bool getNameFile(wstring rank, wstring path) {
    wstring searchPath = path + L"\\*";

    WIN32_FIND_DATA findData;
    HANDLE hFile = FindFirstFileW(searchPath.c_str(), &findData);

    if (hFile == INVALID_HANDLE_VALUE) {
        wcerr << L"Không mở được folder: " << path << endl;
        return false;
    }

    do {
        wstring fileName = findData.cFileName;

        if (fileName == L"." || fileName == L"..") continue;

        wstring fullPath = path + L"\\" + fileName;
        listNameFileAndFolder.push_back({ rank + fileName, fullPath });

        if (findData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
            getNameFile(rank + L"----", fullPath);
        }
    } while (FindNextFileW(hFile, &findData));

    FindClose(hFile);
    return true;
}

void CGuiInforFileDlg::OnBnClickedButtonStart()
{
	listNameFileAndFolder.clear();
	listFolder.DeleteAllItems();
	CString path;
	folderInput.GetWindowTextW(path);
	if (path.GetLength() == 0) {
		MessageBoxA(NULL, "Enter path please!!", "ERROR", MB_OK);
	}
	else {
		bool check = getNameFile(L"", wstring(path.GetString()));
		if (check == false) {
			MessageBoxA(NULL, "Folder not exits", "ERROR", MB_OK);
		}
		else {
			int index = 0;
			for (const auto& item : listNameFileAndFolder) {
				listFolder.InsertItem(index, item.first.c_str());
				listFolder.SetItemText(index, 1, item.second.c_str());
				DWORD attr = GetFileAttributesW(item.second.c_str());
				if (attr == INVALID_FILE_ATTRIBUTES) {
					listFolder.SetItemText(index, 2, L"Không tồn tại");
				}
				else if (attr & FILE_ATTRIBUTE_DIRECTORY) {
					listFolder.SetItemText(index, 2, L"Folder");
				}
				else {
					HANDLE h_file = CreateFileW(item.second.c_str(), GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
					if (h_file == INVALID_HANDLE_VALUE) {
						listFolder.SetItemText(index, 2, L"File không mở được");
					}
					else {
						BYTE buffer[17] = { 0 }; 
						DWORD bytesRead = 0;
						if (ReadFile(h_file, buffer, 16, &bytesRead, NULL) && bytesRead > 0) {
							CString fileType = L"Unknown";
							if (buffer[0] == 'M' && buffer[1] == 'Z')
								fileType = L"EXE/DLL (PE format)";
							else if (buffer[0] == 0xD0 && buffer[1] == 0xCF)
								fileType = L"Old Office file (DOC/XLS/PPT - binary)";
							else if (buffer[0] == 0x50 && buffer[1] == 0x4B && buffer[2] == 0x03 && buffer[3] == 0x04)
								fileType = L"ZIP or DOCX/XLSX/PPTX";
							else if (buffer[0] == 0xFF && buffer[1] == 0xD8)
								fileType = L"JPEG image";
							else if (buffer[0] == 0x89 && buffer[1] == 0x50)
								fileType = L"PNG image";
							else if (buffer[0] == 0x47 && buffer[1] == 0x49)
								fileType = L"GIF image";
							else if (buffer[0] == 0x42 && buffer[1] == 0x4D)
								fileType = L"BMP image";
							else if (buffer[0] == 0x49 && buffer[1] == 0x49 && buffer[2] == 0x2A && buffer[3] == 0x00)
								fileType = L"TIFF image (Intel)";
							else if (buffer[0] == 0x4D && buffer[1] == 0x4D && buffer[2] == 0x00 && buffer[3] == 0x2A)
								fileType = L"TIFF image (Motorola)";
							else if (buffer[0] == 0x52 && buffer[1] == 0x61 && buffer[2] == 0x72 && buffer[3] == 0x21)
								fileType = L"RAR archive";
							else if (buffer[0] == 0x37 && buffer[1] == 0x7A)
								fileType = L"7-Zip archive";
							else if (buffer[0] == 0x1F && buffer[1] == 0x8B)
								fileType = L"GZIP archive";
							else if (buffer[0] == 0x01 && buffer[1] == 0x0F)
								fileType = L"SQL Server MDF/LDF (tentative)";
							else if (buffer[0] == 0x25 && buffer[1] == 0x50 && buffer[2] == 0x44 && buffer[3] == 0x46)
								fileType = L"PDF document";
							listFolder.SetItemText(index, 2, fileType);
							
						}
						else {
							listFolder.SetItemText(index, 2, L"Không đọc được file");
						}
						CloseHandle(h_file);
					}
				}
				index++;
			}

		}

	}
	
}


void CGuiInforFileDlg::OnEnChangeMfceditbrowse1()
{
	/*MessageBoxA(NULL, "Change Name Folder", "ok", MB_OK);*/
}

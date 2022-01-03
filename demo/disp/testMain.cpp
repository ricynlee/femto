/***************************************************************
 * Name:      testMain.cpp
 * Purpose:   Code for Application Frame
 * Author:     ()
 * Created:   2022-01-03
 * Copyright:  ()
 * License:
 **************************************************************/

#include "testMain.h"
#include <wx/msgdlg.h>

//(*InternalHeaders(testDialog)
#include <wx/font.h>
#include <wx/intl.h>
#include <wx/string.h>
//*)

//helper functions
enum wxbuildinfoformat {
    short_f, long_f };

wxString wxbuildinfo(wxbuildinfoformat format)
{
    wxString wxbuild(wxVERSION_STRING);

    if (format == long_f )
    {
#if defined(__WXMSW__)
        wxbuild << _T("-Windows");
#elif defined(__UNIX__)
        wxbuild << _T("-Linux");
#endif

#if wxUSE_UNICODE
        wxbuild << _T("-Unicode build");
#else
        wxbuild << _T("-ANSI build");
#endif // wxUSE_UNICODE
    }

    return wxbuild;
}

//(*IdInit(testDialog)
const long testDialog::ID_STATICTEXT1 = wxNewId();
const long testDialog::ID_TIMER1 = wxNewId();
//*)

BEGIN_EVENT_TABLE(testDialog,wxDialog)
    //(*EventTable(testDialog)
    //*)
END_EVENT_TABLE()

testDialog::testDialog(wxWindow* parent,wxWindowID id)
{
    extern char* caption;

    //(*Initialize(testDialog)
    Create(parent, id, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxSTAY_ON_TOP|wxDIALOG_NO_PARENT|wxNO_BORDER, _T("id"));
    Move(wxPoint(-1,-1));
    SetBackgroundColour(wxColour(128,128,128));
    SetExtraStyle( GetExtraStyle() | wxWS_EX_BLOCK_EVENTS );
    BoxSizer1 = new wxBoxSizer(wxHORIZONTAL);
    StaticText1 = new wxStaticText(this, ID_STATICTEXT1, _(caption), wxDefaultPosition, wxDefaultSize, 0, _T("ID_STATICTEXT1"));
    StaticText1->SetForegroundColour(wxColour(255,255,0));
    wxFont StaticText1Font(512,wxFONTFAMILY_SWISS,wxFONTSTYLE_NORMAL,wxFONTWEIGHT_NORMAL,false,_T("Tahoma"),wxFONTENCODING_DEFAULT);
    StaticText1->SetFont(StaticText1Font);
    BoxSizer1->Add(StaticText1, 1, wxALL|wxALIGN_CENTER_HORIZONTAL|wxALIGN_CENTER_VERTICAL, 10);
    SetSizer(BoxSizer1);
    Timer1.SetOwner(this, ID_TIMER1);
    Timer1.Start(20, false);
    BoxSizer1->Fit(this);
    BoxSizer1->SetSizeHints(this);

    Connect(ID_TIMER1,wxEVT_TIMER,(wxObjectEventFunction)&testDialog::OnTimer1Trigger);
    Connect(wxID_ANY,wxEVT_INIT_DIALOG,(wxObjectEventFunction)&testDialog::OnInit);
    //*)
}

testDialog::~testDialog()
{
    //(*Destroy(testDialog)
    //*)
}

static int sw, sh, ww, wh;

void testDialog::OnInit(wxInitDialogEvent& event)
{
    HWND hwnd = wxWindow::GetHandle();
    SetWindowLong(hwnd, GWL_EXSTYLE, GetWindowLong(hwnd, GWL_EXSTYLE) | WS_EX_LAYERED | WS_EX_TOOLWINDOW);
    SetLayeredWindowAttributes(hwnd, RGB(128,128,128), 0, LWA_COLORKEY);

    wxDisplaySize(&sw, &sh);
    wxWindow::GetSize(&ww, &wh);
    wxWindow::Move(sw, (sh-wh)/2);
}

void testDialog::OnTimer1Trigger(wxTimerEvent& event)
{
    int x, y;
    wxWindow::GetPosition(&x, &y);
    x-=16;
    wxWindow::Move(x, y);

    if (x<-wh) {
        Close();
    }
}

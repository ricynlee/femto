/***************************************************************
 * Name:      testMain.h
 * Purpose:   Defines Application Frame
 * Author:     ()
 * Created:   2022-01-03
 * Copyright:  ()
 * License:
 **************************************************************/

#ifndef TESTMAIN_H
#define TESTMAIN_H

//(*Headers(testDialog)
#include <wx/dialog.h>
#include <wx/sizer.h>
#include <wx/stattext.h>
#include <wx/timer.h>
//*)

class testDialog: public wxDialog
{
    public:

        testDialog(wxWindow* parent,wxWindowID id = -1);
        virtual ~testDialog();

    private:

        //(*Handlers(testDialog)
        void OnInit(wxInitDialogEvent& event);
        void OnTimer1Trigger(wxTimerEvent& event);
        //*)

        //(*Identifiers(testDialog)
        static const long ID_STATICTEXT1;
        static const long ID_TIMER1;
        //*)

        //(*Declarations(testDialog)
        wxBoxSizer* BoxSizer1;
        wxStaticText* StaticText1;
        wxTimer Timer1;
        //*)

        DECLARE_EVENT_TABLE()
};

#endif // TESTMAIN_H

/***************************************************************
 * Name:      testApp.cpp
 * Purpose:   Code for Application Class
 * Author:     ()
 * Created:   2022-01-03
 * Copyright:  ()
 * License:
 **************************************************************/

#include "testApp.h"

//(*AppHeaders
#include "testMain.h"
#include <wx/image.h>
//*)

IMPLEMENT_APP(testApp);

char* caption;

bool testApp::OnInit()
{
    if (argc==1)
        Exit();
    else
        caption = argv[1];

    //(*AppInitialize
    bool wxsOK = true;
    wxInitAllImageHandlers();
    if ( wxsOK )
    {
    	testDialog Dlg(0);
    	SetTopWindow(&Dlg);
    	Dlg.ShowModal();
    	wxsOK = false;
    }
    //*)

    return wxsOK;
}



function test_POC
    BFCom = bfcom;
    BFCom.Tag = 'testetst';
%     Mitm = mitm
    mw1 = main_window;
    mw1.BFCom = BFCom;
%     mw1.Mitm = Mitm
    disp(BFCom.Tag)
    disp(mw1.BFCom.Tag)
    
    mw1.test_bfcom('hoitt')
    
    disp(BFCom.Tag)
    phoneID = 'ID1';
    
    BFCom.orientationChange(phoneID, 2, 3)
    
    disp(mw1.BFCom.phones)
    
end
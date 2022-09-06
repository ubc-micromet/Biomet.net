'====================================================================
'
'   I N P F I L E
'
'
'   This program is an integral part of MET.M (a Matlab file which
'   does statistics from a file)
'
'
'
DO
    PRINT : PRINT : PRINT
    LOCATE 20, 1: INPUT "File for calculation: ", a$
    Greska = 0
    '
    a$ = UCASE$(a$)
    name$ = DIR$(a$)
    IF name$ <> "" THEN
        IF LEFT$(name$, 1) <= "9" AND LEFT$(name$, 1) >= "0" THEN
            BEEP
            LOCATE 22, 1: PRINT "*** File name cannot start with number ***, Press any key to continue";
            DO
            LOOP UNTIL INKEY$ <> ""
            Greska = 1
        ELSE
            x = INSTR(name$, ".")
            IF x <> 0 THEN
                name1$ = LEFT$(name$, x - 1)
            END IF
            IOnumOut = FREEFILE
            OPEN "\nz\matlab\loadNum.m" FOR OUTPUT AS IOnumOut
            PRINT #IOnumOut, "%========================================================"
            PRINT #IOnumOut, "%"
            PRINT #IOnumOut, "%   LoadNum.m"
            PRINT #IOnumOut, "%"
            PRINT #IOnumOut, "%   This m-file is written by InpFile.exe"
            PRINT #IOnumOut, "%"
            PRINT #IOnumOut, "%   This procedure reads a file transfered from"
            PRINT #IOnumOut, "%   MET.BAS"
            PRINT #IOnumOut, "%"
            PRINT #IOnumOut, "%========================================================"
            PRINT #IOnumOut, "load "; a$; "   % change the file name"
            PRINT #IOnumOut, "NumInt = "; name1$; " ;"
            PRINT #IOnumOut, "clear "; name1$
            PRINT #IOnumOut, "%------------------------ End of file ------------------"
            Greska = 0
        END IF
        PRINT : PRINT : PRINT
    ELSE
        BEEP
        LOCATE 22, 1: PRINT "*** File doesn't exist ***, Press any key to continue";
        DO
        LOOP UNTIL INKEY$ <> ""
        Greska = 1
    END IF
LOOP UNTIL Greska = 0
CLOSE
END


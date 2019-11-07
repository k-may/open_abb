MODULE DRIVER

!////////////////
!GLOBAL VARIABLES
!////////////////

PERS num params{10};
PERS num nParams;
PERS num instructionCode;
	
!////////////////
!LOCAL METHODS
!////////////////

!//Method to parse the message received from a PC
!// If correct message, loads values on:
!// - instructionCode.
!// - nParams: Number of received parameters.
!// - params{nParams}: Vector of received params.
PROC ParseMsg(string msg)
    !//Local variables
    VAR bool auxOk;
    VAR num ind:=1;
    VAR num newInd;
    VAR num length;
    VAR num indParam:=1;
    VAR string subString;
    VAR bool end := FALSE;
	
    !//Find the end character
    length := StrMatch(msg,1,"#");
    IF length > StrLen(msg) THEN
        !//Corrupt message
        nParams := -1;
    ELSE
        !//Read Instruction code
        newInd := StrMatch(msg,ind," ") + 1;
        subString := StrPart(msg,ind,newInd - ind - 1);
        auxOk:= StrToVal(subString, instructionCode);
        IF auxOk = FALSE THEN
            !//Impossible to read instruction code
            nParams := -1;
        ELSE
            ind := newInd;
            !//Read all instruction parameters (maximum of 8)
            WHILE end = FALSE DO
                newInd := StrMatch(msg,ind," ") + 1;
                IF newInd > length THEN
                    end := TRUE;
                ELSE
                    subString := StrPart(msg,ind,newInd - ind - 1);
                    auxOk := StrToVal(subString, params{indParam});
                    indParam := indParam + 1;
                    ind := newInd;
                ENDIF	   
            ENDWHILE
            nParams:= indParam - 1;
        ENDIF
    ENDIF
ENDPROC

!////////////////////////
!//DRIVER: Main procedure
!////////////////////////
PROC main()
    !//Local variables
    VAR bool connected;          !//Client connected
    VAR bool reconnected;        !//Drop and reconnection happened during serving a command

    !//Socket connection
    connected:=FALSE;
    ServerCreateAndConnect ipController,serverPort;
    connected:=TRUE;
    VAR bool stopExecution:=FALSE;

    !//Server Loop
    WHILE TRUE DO
        !//Initialization of program flow variables
        ok:=SERVER_OK;              !//Correctness of executed instruction.
        reconnected:=FALSE;         !//Has communication dropped after receiving a command?
        addString := "";


        VAR action currentAction;
        VAR bool stopExecution:=FALSE;

        WHILE stopExecution=FALSE DO

            !//Wait for a command
            SocketReceive clientSocket \Str:=receivedString \Time:=WAIT_MAX;
            ParseMsg receivedString;

            TEST instructionCode
                CASE 0: !Ping
                    !IF nParams = 0 THEN
                    !    ok := SERVER_OK;
                    !ELSE
                    !    ok := SERVER_BAD_MSG;
                    !ENDIF
                DEFAULT :
                     ! force main module to reset
                     SetDO doAbortMotion,0;

        ENDWHILE

ENDPROC

ENDMODULE
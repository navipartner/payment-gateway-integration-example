codeunit 50000 "PSP Integration" implements "NPR IPaymentGateway"
{
    var
        EnvironmentUnknownErr: Label 'The specified environment "%1" is not known', Comment = '%1 = the given environment';

    procedure Capture(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    var
        Setup: Record "PSP Integration Setup";
        OpsLogEntry: Record "PSP Integration Ops Log Entry";
    begin
        Setup.Get(Request."Payment Gateway Code");

        if (not (Setup.Environment in [Enum::"PSP Integration Environment"::Test, Enum::"PSP Integration Environment"::Production])) then
            Error(EnvironmentUnknownErr, Setup.Environment);

        OpsLogEntry.Init();
        OpsLogEntry."Entry No." := 0;
        OpsLogEntry."Transaction ID" := Request."Transaction ID";
        OpsLogEntry.Environment := Setup.Environment;
        OpsLogEntry.Description := CopyStr(StrSubstNo('Capturing total amount %1 on transaction %2 from merchant %3', Request."Request Amount", Request."Transaction ID", Setup."Merchant Name"), 1, MaxStrLen(OpsLogEntry.Description));
        OpsLogEntry.Insert(true);

        Request.AddBody(Format(OpsLogEntry));

        Response."Response Success" := true;
        Response."Response Operation Id" := Format(OpsLogEntry."Entry No.", 0, 9);
        Response.AddResponse(Format(OpsLogEntry));
    end;

    procedure Refund(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    var
        Setup: Record "PSP Integration Setup";
        OpsLogEntry: Record "PSP Integration Ops Log Entry";
    begin
        Setup.Get(Request."Payment Gateway Code");

        if (not (Setup.Environment in [Enum::"PSP Integration Environment"::Test, Enum::"PSP Integration Environment"::Production])) then
            Error(EnvironmentUnknownErr, Setup.Environment);

        OpsLogEntry.Init();
        OpsLogEntry."Entry No." := 0;
        OpsLogEntry."Transaction ID" := Request."Transaction ID";
        OpsLogEntry.Environment := Setup.Environment;
        OpsLogEntry.Description := CopyStr(StrSubstNo('Refunding total amount %1 on transaction %2 from merchant %3', Request."Request Amount", Request."Transaction ID", Setup."Merchant Name"), 1, MaxStrLen(OpsLogEntry.Description));
        OpsLogEntry.Insert(true);

        Request.AddBody(Format(OpsLogEntry));

        Response."Response Success" := true;
        Response."Response Operation Id" := Format(OpsLogEntry."Entry No.", 0, 9);
        Response.AddResponse(Format(OpsLogEntry));
    end;

    procedure Cancel(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    var
        Setup: Record "PSP Integration Setup";
        OpsLogEntry: Record "PSP Integration Ops Log Entry";
    begin
        Setup.Get(Request."Payment Gateway Code");

        if (not (Setup.Environment in [Enum::"PSP Integration Environment"::Test, Enum::"PSP Integration Environment"::Production])) then
            Error(EnvironmentUnknownErr, Setup.Environment);

        OpsLogEntry.SetRange("Transaction ID", Request."Transaction ID");
        if (not OpsLogEntry.IsEmpty) then
            Error('Cannot cancel transaction operations on it');

        OpsLogEntry.Init();
        OpsLogEntry."Entry No." := 0;
        OpsLogEntry."Transaction ID" := Request."Transaction ID";
        OpsLogEntry.Environment := Setup.Environment;
        OpsLogEntry.Description := CopyStr(StrSubstNo('Cancelling transaction %1 from merchant %2', Request."Transaction ID", Setup."Merchant Name"), 1, MaxStrLen(OpsLogEntry.Description));
        OpsLogEntry.Insert(true);

        Request.AddBody(Format(OpsLogEntry));

        Response."Response Success" := true;
        Response."Response Operation Id" := Format(OpsLogEntry."Entry No.", 0, 9);
        Response.AddResponse(Format(OpsLogEntry));
    end;

    procedure RunSetupCard(PaymentGatewayCode: Code[10]);
    var
        CompanyInfo: Record "Company Information";
        Setup: Record "PSP Integration Setup";
    begin
        if (not Setup.Get(PaymentGatewayCode)) then begin
            CompanyInfo.Get();
            Setup.Init();
            Setup."Gateway Code" := PaymentGatewayCode;
            Setup."Merchant Name" := CompanyInfo.Name;
            Setup.Insert();
            Commit();
        end;

        Setup.SetRecFilter();
        Page.Run(Page::"PSP Integration Setup Card", Setup);
    end;
}
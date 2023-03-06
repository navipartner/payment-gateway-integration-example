enumextension 50000 "PG Integrations Ext" extends "NPR PG Integrations"
{
    value(50000; "PSP Integration")
    {
        Caption = 'PSP Integration';
        Implementation = "NPR IPaymentGateway" = "PSP Integration";
    }
}
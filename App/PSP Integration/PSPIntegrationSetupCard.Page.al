page 50000 "PSP Integration Setup Card"
{
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "PSP Integration Setup";
    PageType = Card;

    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Environment; Rec.Environment)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Merchant Name"; Rec."Merchant Name")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
            }
        }
    }
}
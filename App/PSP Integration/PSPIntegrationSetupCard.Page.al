page 50000 "PSP Integration Setup Card"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "PSP Integration Setup";
    PageType = Card;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Environment; Rec.Environment)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
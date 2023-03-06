table 50000 "PSP Integration Setup"
{
    Description = 'PSP Integration Setup';

    fields
    {
        field(1; "Gateway Code"; Code[10])
        {
            Description = 'Gateway Code';
            DataClassification = CustomerContent;
        }
        field(5; Environment; Enum "PSP Integration Environment")
        {
            Description = 'Environment';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Gateway Code")
        {
            Clustered = true;
        }
    }
}
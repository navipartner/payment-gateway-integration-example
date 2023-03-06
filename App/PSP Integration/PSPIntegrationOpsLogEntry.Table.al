table 50001 "PSP Integration Ops Log Entry"
{
    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Description = 'Entry No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Transaction ID"; Text[250])
        {
            Description = 'Transaction ID';
            DataClassification = CustomerContent;
        }
        field(3; Environment; Enum "PSP Integration Environment")
        {
            Description = 'Environment';
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[250])
        {
            Description = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
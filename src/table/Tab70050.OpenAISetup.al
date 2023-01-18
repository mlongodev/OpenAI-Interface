table 70050 "OpenAI Setup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = ToBeClassified;

        }
        field(5; "Organization ID"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "API Key"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Default Temperature"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 1;
            MinValue = 0;
            MaxValue = 1;
        }

        field(25; "Default Max Token"; Integer)
        {
            DataClassification = ToBeClassified;
        }

    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}
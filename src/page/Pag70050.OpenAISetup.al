page 70050 "OpenAI Setup"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'OpenAI Setup';
    PageType = Card;
    SourceTable = "OpenAI Setup";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Organization ID"; Rec."Organization ID")
                {
                    Caption = 'Organization ID';
                }
                field("API Key"; Rec."API Key")
                {
                    Caption = 'API Key';
                    ExtendedDatatype = Masked;
                }
                field("Default Max Token"; Rec."Default Max Token")
                {
                    Caption = 'Default Max Token';
                }
                field("Default Temperature"; Rec."Default Temperature")
                {
                    Caption = 'Default Temperature';
                }

            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert()
        end;
    end;
}

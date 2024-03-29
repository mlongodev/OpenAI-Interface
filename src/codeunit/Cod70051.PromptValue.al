codeunit 70051 "Prompt Value"
{

    procedure EntityRequestV2(EntityName: text) Messages: Dictionary of [Text, Text]
    var
        System: Label 'You are an assistant for users using Dynamics 365 Business Central. Answer the questions asked by the user in a simple and precise way.';
        User: Label 'What is %1 in Microsoft Dynamics 365 Business Central?';
    begin
        Messages.Add('system', System);
        Messages.Add('user', StrSubstNo(User, EntityName));
    end;

    procedure CustomerInfoV2() Messages: Dictionary of [Text, Text]
    var
        System: Label 'Answer the question based on the dataset in CSV format with semicolon as separator shown below. For any information requested that is not present in the provided dataset please answer "I could not find an answer".';
        User: Label 'I''m from the sales department, and I need your help with some calculations based on our customer data. Here''s the customer data we have in a CSV format: \%1 \My question about data is: ';
    begin
        Messages.Add('system', System);
        Messages.Add('user', StrSubstNo(User, GetCustomerData()));
    end;

    local procedure GetCustomerData(): Text
    var
        LineNo: Integer;
        TempCSVBuffer: Record "CSV Buffer" temporary;
        Customer: Record Customer;
        CSV: Text;
        TempBlob: Codeunit "Temp Blob";
        InStreamCSV: InStream;
    begin
        LineNo := 1;
        TempCSVBuffer.InsertEntry(LineNo, 1, Customer.FieldCaption("No."));
        TempCSVBuffer.InsertEntry(LineNo, 2, Customer.FieldCaption(Name));
        TempCSVBuffer.InsertEntry(LineNo, 3, Customer.FieldCaption(Customer."Sales (LCY)"));
        TempCSVBuffer.InsertEntry(LineNo, 4, Customer.FieldCaption(Customer."Country/Region Code"));
        if Customer.FindSet() then
            repeat
                LineNo += 1;
                TempCSVBuffer.InsertEntry(LineNo, 1, Customer."No.");
                TempCSVBuffer.InsertEntry(LineNo, 2, Customer.Name);
                Customer.CalcFields("Sales (LCY)");
                TempCSVBuffer.InsertEntry(LineNo, 3, Format(Customer."Sales (LCY)", 0, '<Standard Format,1>'));
                TempCSVBuffer.InsertEntry(LineNo, 4, Customer."Country/Region Code");
            until Customer.Next() = 0;
        TempCSVBuffer.SaveDataToBlob(TempBlob, ';');
        TempBlob.CreateInStream(InStreamCSV);
        InStreamCSV.Read(CSV);
        exit(CSV);
    end;
}
pageextension 70051 "CustomerListOpenAIExt" extends "Customer List"
{
    actions
    {
        addafter(ApplyTemplate)
        {
            action(AskCustomersInfo)
            {
                ApplicationArea = All;
                Caption = 'Ask Customers Info';
                Image = Help;

                trigger OnAction()
                var
                    PromptValue: Codeunit "Prompt Value";
                    Response: Text;
                    AskGPT: page "Ask GPT";
                    PageCaption: Label 'Ask ChatGPT for info about your customers';
                begin
                    AskGPT.SetCaption(PageCaption);
                    AskGPT.SetMessagesDict(PromptValue.CustomerInfoV2());
                    AskGPT.RunModal()
                end;
            }
        }

        addafter(ApplyTemplate_Promoted)
        {
            actionref("Ask GPT_Promoted"; AskCustomersInfo)
            {
            }
        }
    }

    var
        myInt: Integer;
}
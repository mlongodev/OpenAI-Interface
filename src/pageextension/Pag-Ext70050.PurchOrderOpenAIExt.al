pageextension 70050 "PurchOrderOpenAIExt" extends "Purchase Order"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addfirst("O&rder")
        {
            action("Ask GPT")
            {
                ApplicationArea = All;
                Caption = 'Ask GPT';
                Image = Help;

                trigger OnAction()
                var
                    OpenAIMgt: Codeunit "OpenAI Management";
                    PromptValue: Codeunit "Prompt Value";
                    Response: Text;
                begin
                    OpenAIMgt.SendDefaultRequest(PromptValue.EntityRequestV2(Rec.TableCaption), Response);
                    Message(Response);
                end;
            }
        }

        addafter("Archive Document_Promoted")
        {
            actionref("Ask GPT_Promoted2"; "Ask GPT")
            {
            }
        }
    }
}
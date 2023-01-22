pageextension 70051 "GenPostSetup" extends "General Posting Setup"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {

        addlast(processing)
        {
            group(ChatGTP)
            {
                action("Ask GPT")
                {
                    ApplicationArea = All;
                    Caption = 'Ask GPT';
                    Image = Help;

                    trigger OnAction()
                    var
                        OpenAIMgt: Codeunit "OpenAI Management";
                        Response: Text;
                    begin
                        OpenAIMgt.SendDefaultRequest(OpenAIMgt.GetTextEntityRequest(Rec.TableCaption), Response);
                        Message(Response);
                    end;
                }
            }
        }




        addafter(SuggestAccounts_Promoted)
        {
            actionref("Ask GPT_Promoted"; "Ask GPT")
            {
            }
        }
    }
}
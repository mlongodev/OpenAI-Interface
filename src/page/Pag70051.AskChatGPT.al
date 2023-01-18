page 70051 "Ask GPT"
{
    ApplicationArea = All;
    Caption = 'Ask GPT';
    PageType = Card;
    UsageCategory = Tasks;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(RequestGroup)
            {
                ShowCaption = true;
                Caption = 'Request';
                field(Request; Request)
                {
                    ShowCaption = false;
                    ApplicationArea = All;
                    MultiLine = true;
                }
            }
            group(ResponseGroup)
            {
                ShowCaption = true;
                Caption = 'Response';
                field(Response; Response)
                {
                    ShowCaption = false;
                    ApplicationArea = All;
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Send)
            {
                Caption = '&Send';
                Image = SendTo;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    OpenAIMgt: Codeunit "OpenAI Management";
                begin
                    Clear(OpenAIMgt);
                    OpenAIMgt.SendDefaultRequest(Request, Response);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        OpenAISetup.Get();

    end;

    var
        Request: Text[250];
        Response: Text;
        OpenAISetup: Record "OpenAI Setup";
}

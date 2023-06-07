page 70051 "Ask GPT"
{
    ApplicationArea = All;
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
                    OpenAIMgt: Codeunit "OpenAI Management V2";
                begin
                    Clear(OpenAIMgt);
                    OpenAIMgt.SendDefaultRequest(GetMessages(Request), Response);
                end;
            }

            action(GetPromptMessage)
            {
                Caption = '&Get Prompt';
                Image = Text;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    OpenAIMgt: Codeunit "OpenAI Management";
                    FinalMessages: Dictionary of [Text, Text];
                    RoleList: List of [Text];
                    Role: Text;
                begin
                    FinalMessages := GetMessages(Request);
                    RoleList := FinalMessages.Keys;
                    foreach Role in RoleList do begin
                        Message(Role + '\' + FinalMessages.Get(Role));
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        OpenAISetup.Get();
        GetPageCaption()
    end;

    local procedure GetPageCaption()
    var
        CaptionDefault: Label 'Ask GPT';
    begin
        if CaptionPage = '' then
            CurrPage.Caption(CaptionDefault)
        else
            CurrPage.Caption(CaptionPage)
    end;

    local procedure GetMessages(Request: Text) ReturnMessDict: Dictionary of [Text, Text]
    var
        RoleList: List of [Text];
        UserValue: Text;
    begin
        RoleList := MainMessagesDict.Keys;
        if not RoleList.Contains('user') then
            MainMessagesDict.Add('user', Request)
        else begin
            UserValue := MainMessagesDict.Get('user');
            MainMessagesDict.Set('user', UserValue + Request);
        end;
        ReturnMessDict := MainMessagesDict;
    end;

    procedure SetCaption(ParPageCaption: Text)
    begin
        CaptionPage := ParPageCaption;
    end;

    procedure SetMessagesDict(ParMainMessagesDict: Dictionary of [Text, Text])
    begin
        MainMessagesDict := ParMainMessagesDict;
    end;

    var
        Request: Text[250];
        Response: Text;
        OpenAISetup: Record "OpenAI Setup";
        MainMessagesDict: Dictionary of [Text, Text];
        CaptionPage: Text;
}

codeunit 70052 "OpenAI Management v2"
{

    procedure GetResponse(): Boolean
    var
        apiUrl: Text;
        apiKey: Text;
        prompt: Text;
        bodyJson: JsonObject;
        requestHeaders: HttpHeaders;
        ResponseText: Text;
        Request: HttpRequestMessage;
        Client: HttpClient;
        Content: HttpContent;
    begin
        SetBody(Content);
        SetHeaders(Content, Request);
        Post(Content, Request, ResponseText);
        ReadResponse(ResponseText);
        exit(GlobalTextResponseValue <> '')
    end;

    local procedure SetHeaders(var Content: HttpContent; var Request: HttpRequestMessage)
    var
        Headers: HttpHeaders;
        AuthorizationValue: Text;
    begin
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        Request.GetHeaders(Headers);
        Headers.Add('OpenAI-Organization', GlobalOrganizationId);
        AuthorizationValue := GetAuthorization(GlobalAPIKey);
        Headers.Add('Authorization', AuthorizationValue);
    end;

    local procedure SetBody(var Content: HttpContent)
    var
        bodyJson: JsonObject;
        JsonData: Text;
    begin
        bodyJson.Add('model', GetDefaultModel);
        //bodyJson.Add('prompt', GlobalPrompt);
        bodyJson.Add('messages', GetMessages());
        bodyJson.Add('max_tokens', GlobalMaxToken);
        bodyJson.Add('temperature', GlobalTemperature);
        bodyJson.WriteTo(JsonData);
        Content.WriteFrom(JsonData);
    end;

    local procedure Post(var Content: HttpContent; var Request: HttpRequestMessage; var ResponseText: Text)
    var
        Client: HttpClient;
        ErrorText: label 'Something Wrong. Please retry.';
        ErrorResponseText: label 'Something Wrong. Error:\ %1';
        Response: HttpResponseMessage;
    begin
        Request.Content := Content;
        Request.SetRequestUri(GetUrl);
        Request.Method := 'POST';

        if not Client.Send(Request, Response) then
            Error(ErrorText);

        Response.Content.ReadAs(ResponseText);
        if not Response.IsSuccessStatusCode then
            Error(ErrorResponseText, ResponseText);
    end;

    local procedure GetMessages() JsonArr: JsonArray
    var
        RoleList: List of [Text];
        Role: Text;
        JsonObj: JsonObject;
    begin
        RoleList := MessagesDict.Keys();
        foreach Role in RoleList do begin
            Clear(JsonObj);
            JsonObj.Add('role', Role);
            JsonObj.Add('content', MessagesDict.Get(Role));
            JsonArr.Add(JsonObj);
        end;
    end;

    local procedure ReadResponse(var Response: Text): Text
    var
        JsonObjResponse: JsonObject;
        JsonTokResponse: JsonToken;
        JsonTokChoices: JsonToken;
        JsonObjChoices: JsonObject;
        JsonObjMessage: JsonObject;
        JsonTokMessage: JsonToken;
        JsonTokTextValue: JsonToken;
        JsonArr: JsonArray;
    begin
        GlobalTextResponseValue := '';
        JsonObjResponse.ReadFrom(Response);
        JsonObjResponse.Get('choices', JsonTokResponse);
        JsonArr := JsonTokResponse.AsArray();
        JsonArr.Get(0, JsonTokChoices);
        JsonObjChoices := JsonTokChoices.AsObject();
        JsonObjChoices.Get('message', JsonTokMessage);
        JsonObjMessage := JsonTokMessage.AsObject();
        JsonObjMessage.Get('content', JsonTokTextValue);
        GlobalTextResponseValue := JsonTokTextValue.AsValue().AsText();
    end;

    procedure SendDefaultRequest(pMessagesDict: Dictionary of [Text, Text]; var Response: Text)
    var
        OpenAISetup: Record "OpenAI Setup";
    begin
        OpenAISetup.Get();
        SetOrganizationId(OpenAISetup."Organization ID");
        SetAPIKey(OpenAISetup."API Key");
        SetMaxToken(OpenAISetup."Default Max Token");
        SetTemperature(OpenAISetup."Default Temperature");
        SetMessages(pMessagesDict);
        if GetResponse() then
            Response := GetResponseTextResponseValue()
    end;

    procedure GetResponseTextResponseValue(): Text
    begin
        exit(GlobalTextResponseValue)
    end;

    local procedure GetAuthorization(ApiKey: text): Text
    begin
        exit('Bearer ' + ApiKey)
    end;

    procedure GetUrl(): Text
    begin
        exit('https://api.openai.com/v1/chat/completions')
    end;

    procedure SetOrganizationId(OrganizationId: Text[50])
    begin
        GlobalOrganizationId := OrganizationId;
    end;

    procedure SetAPIKey(APIKey: Text)
    begin
        GlobalAPIKey := APIKey;
    end;

    procedure SetModel(Model: Text)
    begin
        GlobalModel := Model;
    end;

    procedure SetMaxToken(MaxToken: Integer)
    begin
        GlobalMaxToken := MaxToken;
    end;

    procedure SetTemperature(Temperature: Decimal)
    begin
        GlobalTemperature := Temperature;
    end;

    procedure SetMessages(pMessagesDict: Dictionary of [Text, Text])
    begin
        MessagesDict := pMessagesDict;
    end;

    procedure GetDefaultModel(): Text
    begin
        exit('gpt-3.5-turbo')
    end;

    var
        GlobalOrganizationId: Text[50];
        GlobalAPIKey: Text[100];
        GlobalModel: Text[30];
        GlobalMaxToken: Integer;
        GlobalTemperature: Decimal;
        GlobalPrompt: Text;
        GlobalTextResponseValue: text;
        MessagesDict: Dictionary of [Text, Text];

}
codeunit 70050 "OpenAI Management"
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
        bodyJson.Add('prompt', GlobalPrompt);
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

    local procedure ReadResponse(var Response: Text): Text
    var
        JsonObjResponse: JsonObject;
        JsonTokResponse: JsonToken;
        JsonTokChoices: JsonToken;
        JsonObjChoices: JsonObject;
        JsonTokTextValue: JsonToken;
        JsonArr: JsonArray;
    begin
        GlobalTextResponseValue := '';
        JsonObjResponse.ReadFrom(Response);
        if JsonObjResponse.Get('choices', JsonTokResponse) then begin
            JsonArr := JsonTokResponse.AsArray();
            JsonArr.Get(0, JsonTokChoices);
            JsonObjChoices := JsonTokChoices.AsObject();
            JsonObjChoices.Get('text', JsonTokTextValue);
            GlobalTextResponseValue := JsonTokTextValue.AsValue().AsText();
        end;
    end;

    procedure GetTextEntityRequest(EntityName: text): Text
    var
        FixedText: Label 'What is %1 in Microsoft Dynamics 365 Business Central?';
    begin
        exit(StrSubstNo(FixedText, EntityName))
    end;

    procedure SendDefaultRequest(Request: Text; var Response: Text)
    var
        OpenAISetup: Record "OpenAI Setup";
    begin
        OpenAISetup.Get();
        SetOrganizationId(OpenAISetup."Organization ID");
        SetAPIKey(OpenAISetup."API Key");
        SetMaxToken(OpenAISetup."Default Max Token");
        SetTemperature(OpenAISetup."Default Temperature");
        SetPrompt(Request);
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
        exit('https://api.openai.com/v1/completions')
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

    procedure SetPrompt(Prompt: Text)
    begin
        GlobalPrompt := Prompt
    end;

    procedure GetDefaultModel(): Text
    begin
        exit('text-davinci-003')
    end;

    var
        GlobalOrganizationId: Text[50];
        GlobalAPIKey: Text[100];
        GlobalModel: Text[30];
        GlobalMaxToken: Integer;
        GlobalTemperature: Decimal;
        GlobalPrompt: Text;
        GlobalTextResponseValue: text;

}
*** Settings ***

Resource    ../main.robot

Library    Collections

*** Variables ***
&{logar}
...    DB_HOST=biobots.com.br
...    DB_PORT=3306
...    DB_USER=tm
...    DB_PASSWORD=DuxQ6AVXmnYBH*fqazpGkf8en7hJhL@m
...    DB_NAME=portal
...    DB_TYPE=MySQL
...    url_login=https://biobots.com.br/login
...    card_login=//div[@class="px-10 py-5"]
...    campo_Login=//input[@type="text"]
...    campo_senha=//input[@type="password"]
...    btn_login=//button[@type="submit"]
...    card2FA=//div[@class="mb-5 col col-12"]
...    btn_2FA=(//button[@type="button"])[3]
...    validacao_login=(//li[@class="item"])[1]

*** Keywords ***

Dado um usuário acessando a página de login 
    Open Browser    ${logar.url_login}    firefox    options=add_argument("--headless")

    ${tempo_esperado}    Set Variable    10
    Set Test Variable    ${tempo_esperado}

    ${visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${logar.card_login}    ${tempo_esperado}

    IF    $visible
        Sleep    2
    ELSE
        Fail    1ºPasso: Fail - Página de login não foi visualizada em um tempo de ${tempo_esperado} segundos
    END

    &{fields}=    Create Dictionary
    ...    Campo de Login=${logar.campo_Login}
    ...    Campo de Senha=${logar.campo_senha}
    ...    Botão de Logar=${logar.btn_login}
     
    ${campo_nao_encontrados}    Create List

    FOR    ${field}    IN    @{fields}
        ${visible}=  Run Keyword And Return Status    Element Should Be Visible    ${fields}[${field}]
        IF    $visible == $False
            Append To List    ${campo_nao_encontrados}    ${field}
        END
    END

    IF  ${campo_nao_encontrados} == []
        Log To Console    1ºPasso: Ok - Página de login acessada com sucesso
    ELSE
        Fail    1ºPasso: Fail - Os seguintes campos não foram visualizados ao acessar a página de login: ${campo_nao_encontrados}
    END

E preenchendo o campo de Login e Senha 
    Input Text    ${logar.campo_Login}    ${dados_login.loginAdm}
    Input Text    ${logar.campo_senha}    ${dados_login.senhaAdm}

    &{fields}=    Create Dictionary
    ...    Campo de Login=${logar.campo_Login}
    ...    Campo de Senha=${logar.campo_senha}
     
    ${campos_vazios}    Create List

    FOR    ${field}    IN    @{fields}
        ${valor_campo}    Run Keyword And Return Status    Should Not Be Empty    ${fields}[${field}]
        IF    $valor_campo == $False
            Append To List    ${campos_vazios}    ${field}
        END    
    END

    IF  ${campos_vazios} == []
        Log To Console    2ºPasso: Ok - Campo de Login e senha devidamente preenchidos 
    ELSE
        Fail    2ºPasso: Fail - Os seguintes campo não foram devidamente preenchidos: ${campos_vazios}
    END
Quando ele clicar no botão de Login 
    Click Element    ${logar.btn_login}
    ${visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${logar.card2FA}    ${tempo_esperado}   

    IF    ${visible}
        Click Element    ${logar.btn_2FA}
        Connect To Database  pymysql  ${dados_banco.DB_NAME}  ${dados_banco.DB_USER}  ${dados_banco.DB_PASSWORD}  ${dados_banco.DB_HOST}  ${dados_banco.DB_PORT}

        # Realiza a consulta SQL correta
        ${resultado}=  Query    SELECT two_factor_code FROM users WHERE email='${dados_login.loginAdm}'

         # Extrai o código de dois fatores 
        ${codigo}=  Set Variable  ${resultado[0][0]}

        Log To Console    Codigo=${codigo}

        ${nao_vazio}    Run Keyword And Return Status    Should Not Be Empty    ${codigo}

        IF    $nao_vazio == $False
            Fail    3ºPasso: Fail - O codigo de 2 fatores não pôde ser encontrado
        ELSE
            Log To Console    3ºPasso: Ok - Código de 2 fatores armazenado 
        END

        # Loop para armazenar cada número em uma variável separada e definir como variável de teste
        FOR    ${index}    IN RANGE    0    6
            ${dig}=  Set Variable    ${codigo[${index}]}
            Set Test Variable    ${dig${index+1}}    ${dig}
        END

        Disconnect From All Databases

        FOR    ${index}    IN RANGE    0    6    
            ${campo}    Set Variable    (//input[@type="tel"])[${index+1}]
            Input Text    (//input[@type="tel"])[${index+1}]    ${dig${index+1}}
        END
        
        Sleep    10
    ELSE
        Log To Console    3ºPasso: Ok - O botão de login foi clicado 
    END
Então ele terá finalizado o login com sucesso 
    ${visible}    Run Keyword And Return Status    Element Should Be Visible    ${logar.validacao_login}    ${tempo_esperado}
    IF    $visible
        Log To Console    4ºPasso: Ok - Login realizado com sucesso 
    ELSE
        Fail    4ºPasso: Fail - Login não realizado   
    END



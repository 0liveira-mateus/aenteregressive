*** Settings ***

Resource    ../Resources/main.robot

*** Test Cases ***

Realizar login no sistema
    Dado um usuário acessando a página de login 
    E preenchendo o campo de Login e Senha 
    Quando ele clicar no botão de Login     
    Então ele terá finalizado o login com sucesso 
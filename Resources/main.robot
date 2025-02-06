*** Settings ***

Library    SeleniumLibrary
Library    DatabaseLibrary    



### pages

### shared

Resource    Shared/Logar.robot  

### Data 
Resource    Data/dados_banco.robot
Resource    Data/dados_login.robot
*** Settings ***
Documentation     Template robot main suite.
...               This is my first robot.
Library           RPA.Robocorp.Vault
Library           Collections
Library           .\\libraries\\MyLibrary.py
Resource          .\\keywords\\keywords.robot
Variables         .\\variables\\MyVariables.py
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.PDF
Library           RPA.Tables
Library           RPA.Archive
Library    RPA.Desktop
Suite Setup       Set Selenium Implicit Wait    5

*** Variables ***
#${URL}            https://robotsparebinindustries.com/#/robot-order
${datapath}       ${CURDIR}${/}orders.csv
${outpath}        ${CURDIR}${/}output

*** Tasks ***
Order robots
    ${secret}=    Get Secret    credentials
    Download Order File
    Log    ${secret}[url]
    Open RobotOrder Page    ${secret}[url]
    ${orders}=    Read orders from Excel    ${datapath}
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form and Submit the order    ${row}
        Preview the robot
        Submit the order
        Store the receipt as a PDF file    ${row}[Order number]
        Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${outpath}${/}receipt_${row}[Order number].png    ${outpath}${/}receipt_${row}[Order number].pdf
        Order another
    END
    Create a ZIP file of the receipts
    [Teardown]    Close All Browsers

*** Keywords ***
Download Order File
    Download    https://robotsparebinindustries.com/orders.csv   overwrite=True   target_file=${datapath} 

Open RobotOrder Page
    [Arguments]    ${theurl}
    Open Available Browser    ${theurl}
    Wait Until Page Contains    By using this order form

Close the annoying modal
    Click Button    OK
    Wait Until Page Contains Element    id:head

Read orders from Excel
    [Arguments]    ${file}
    ${tables}=    Read table from CSV    ${file}
    [Return]    ${tables}

Fill the form and Submit the order
    [Arguments]    ${data}
    Select From List By Value    head    ${data}[Head]
    Click Element    id:id-body-${data}[Body]
    Input Text    xpath=/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${data}[Legs]
    Input Text    address    ${data}[Address]

Preview the robot
    Click Button    preview
    Wait Until Page Contains    Robotics Vectors by Vecteezy

Submit the order
    Wait Until Page Contains Element    id:order
    Click Button    id:order
    #due to network slow, click order button always take no effection after 3 to 4 loops. try again.
    Sleep   5
    ${pass}=     Run Keyword And Return Status      Page Should Contain Element    id:receipt
    Run Keyword If    ${pass}==False
    ...    Run Keywords    Sleep     15
    ...    AND    Click Button    id:order

Order another
    Wait Until Page Contains Element    order-another
    Click Button    id:order-another

Store the receipt as a PDF file
    [Arguments]    ${rownum}
    Wait Until Page Contains Element     id:receipt
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    ${pdf}=    Html To Pdf    ${receipt}    ${outpath}${/}receipt_${rownum}.pdf
    [Return]    ${pdf}

Take a screenshot of the robot
    [Arguments]    ${rownum}
    ${snp}=    Screenshot    id:receipt    ${outpath}${/}receipt_${rownum}.png
    [Return]    ${snp}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${file}    ${target}
    ${files}=    Create List    ${file}
    Add Files To PDF    ${files}    ${target}    append=True

Create a ZIP file of the receipts
    Archive Folder With Zip    ${outpath}    receipt.zip

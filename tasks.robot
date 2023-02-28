*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying pop-up
        Wait Until Keyword Succeeds    3x    10 sec    Fill the form    ${row}
        ${pdf}=    Store the order receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END


*** Keywords ***
Open the robot order website
    Open Chrome Browser    https://robotsparebinindustries.com/#/robot-order
    Maximize Browser Window
    Wait Until Element Is Visible    css:div.alert-buttons
    Click Button    I guess so...
    Wait Until Element Is Not Visible    css:div.alert-buttons

Close the annoying pop-up
    ${pop_up_exists}=    Is Element Visible    css:div.alert-buttons
    IF    ${pop_up_exists}==${True}    Click Button    I guess so...

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${orders_table}=    Read table from CSV    orders.csv
    RETURN    ${orders_table}

Fill the form
    [Arguments]    ${order_info}
    Wait Until Element Is Visible    order
    Select From List By Value    head    ${order_info}[Head]
    Select Radio Button    body    ${order_info}[Body]
    Input Text    css:input[placeholder="Enter the part number for the legs"]    ${order_info}[Legs]
    Input Text    address    ${order_info}[Address]
    Click Button    preview
    Click Button    order
    Wait Until Element Is Visible    receipt

Store the order receipt as a PDF file
    [Arguments]    ${order_id}
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receipts${/}order_receipt_${order_id}.pdf
    RETURN    ${OUTPUT_DIR}${/}receipts${/}order_receipt_${order_id}.pdf

Take a screenshot of the robot
    [Arguments]    ${order_id}
    Wait Until Element Is Visible    robot-preview-image    10 sec
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}screenshots${/}ordered_robot_${order_id}.png
    RETURN    ${OUTPUT_DIR}${/}screenshots${/}ordered_robot_${order_id}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Switch To Pdf    ${pdf}
    Add Watermark Image To Pdf    ${screenshot}    ${pdf}
    Close Pdf    ${pdf}

Go to order another robot
    Click Button    order-another

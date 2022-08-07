*** Settings ***
Documentation       Template keyword resource.
Variables       ..\\variables\\MyVariables.py

*** Keywords ***
Example keyword
    Log         Today is ${TODAY}

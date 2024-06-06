from openai import OpenAI
client = OpenAI()
import json
import requests
import csv

def classify_isco_occupation(isco_description, isco_definition, isco_tasks, prompt_name):

    prompt_flunky = """Consider the following occupation defined in ISCO Level 3: 
```
Occupation is named "{description}", 
Occupation is defined as "{definition}",
The tasks include the following: "{tasks}".
```
    
Consider the following statement about it:
```People in this occupation mostly perform various repetitive or unqualified tasks.```

Your answer should be a number between 1 and 5 with the following meaning: 
1 - 'Strongly disagree', 
2 - 'Disagree', 
3 - 'Neither agree nor disagree', 
4 - 'Agree', 
5 - 'Strongly agree'

Your answer should be relative to all kinds of occupations listed in ISCO; the 
big categories are the following:
* Managers
* Professionals
* Technicians and Associate Professionals
* Clerical Support Workers
* Service and Sales Workers
* Skilled Agricultural, Forestry and Fishery Workers
* Craft and Related Trades Workers
* Plant and Machine Operators, and Assemblers
* Elementary Occupations
* Armed Forces Occupations

Namely, if the occupation is likely to involve more than average repetitive and/or unqualified tasks, 
you should answer with agree or strongly agree.
"""

    prompt_ducttaper1 = """Consider the following occupation defined in ISCO Level 3: 
```
Occupation is named "{description}", 
Occupation is defined as "{definition}",
The tasks include the following: "{tasks}".
```
    
Consider the following statement about it:
```People in this occupation are busy with tasks that could be automated/streamlined.```

Your answer should be a number between 1 and 5 with the following meaning: 
1 - 'Strongly disagree', 
2 - 'Disagree', 
3 - 'Neither agree nor disagree', 
4 - 'Agree', 
5 - 'Strongly agree'

Your answer should be relative to all kinds of occupations listed in ISCO; the 
big categories are the following:
* Managers
* Professionals
* Technicians and Associate Professionals
* Clerical Support Workers
* Service and Sales Workers
* Skilled Agricultural, Forestry and Fishery Workers
* Craft and Related Trades Workers
* Plant and Machine Operators, and Assemblers
* Elementary Occupations
* Armed Forces Occupations

Namely, if the occupation is likely to involve more than average repetitive and/or unqualified tasks, 
you should answer with agree or strongly agree.
"""


    # occupation duplicate the work already covered by other employees?



    standart_system_message = """
You are a helpful assistant designed to output JSON. JSON should contain one property named 
'likert_scale' with one value from the list [1, 2, 3, 4, 5]"""

    all_prompts = {
        'flunky': prompt_flunky.format(description=isco_description, 
                                       definition=isco_definition, 
                                       tasks=isco_tasks),
        'ducttaper1': prompt_ducttaper1.format(description=isco_description, 
                                       definition=isco_definition, 
                                       tasks=isco_tasks)                                  
    }

    all_system_messages = {
        'flunky': standart_system_message,
        'ducttaper1' : standart_system_message
    }

    succeeded = False
    while not succeeded: 
        response = client.chat.completions.create(
            model="gpt-4-turbo",
            response_format={ "type": "json_object" },
            messages=[
                {"role": "system", "content": all_system_messages[prompt_name]},
                {"role": "user", "content": all_prompts[prompt_name]}
            ]
        )
        data = json.loads(response.choices[0].message.content)
        if prompt_name in ['flunky', 'ducttaper1']:
            if 'likert_scale' in data:
                classification_value = data["likert_scale"]
                succeeded = True
                print('.', end="")
        else:
            classification_value = -1
            succeeded = True
            print('Unsupported prompt type')

    # print(classification_value)
    # print("**********************************")
    return classification_value



def getGoogleSpreadsheet(): # Funkcija, kas iegūst Google Spreadsheet dokumentu ar olimpiāžu uzdevumu datiem
    URL_GOOGLE_SPREADSHEET = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSR5644JoPm08GiQ4Xt8Wu3N-Jg2QwCplTKNf3N1N20N35OpGAI3P618CPuNtqWU-kBXvkYER2mrIpV/pub?gid=1003218431&single=true&output=csv'
    response = requests.get(URL_GOOGLE_SPREADSHEET)
    open("ISCO_codes.csv", "wb").write(response.content)



def main():
    getGoogleSpreadsheet()
    with open('ISCO_codes.csv', 'r',  encoding='utf-8') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        linenum = 0
        for row in csv_reader:
            linenum += 1
            if linenum == 1:
                continue
            # if linenum <= 117:
            #     continue
            code = row[0]
            description = row[1]
            definition = row[2]
            tasks = row[3]
            likert = classify_isco_occupation(description, definition, tasks, 'ducttaper1')
            print(f'{code},{likert}')

            with open("isco_dukttaper1_openai.csv", 'a', encoding='utf-8') as file1:
                file1.write(f'{code},{likert}\n')



if __name__ == "__main__":
    main()
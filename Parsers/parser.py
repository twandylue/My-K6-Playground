import json

# class payload:
#     def __init__(self, type):
#         self.type = type

f = open("../Results/result.json", "r");
data = json.load(f);
list = [];
for item in data:
    if item['type'] == "Point":
        print('time: ' + item['data']['time'])
        print('value: ' + str(item['data']['value']))

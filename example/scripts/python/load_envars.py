import json, os

with open("global_config.json") as json_file:
    data = json.load(json_file)
    os.environ["PATH_VIVADO"] = data['config']['config_vivado']['vivado_path']
    # print(os.environ["VIVADO_PATH"])


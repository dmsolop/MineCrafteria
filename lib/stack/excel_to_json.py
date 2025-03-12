import pandas as pd
import json
import sys
import codecs

def excel_to_json(excel_file_path, json_file_path):
    try:
        # Read the Excel file
        excel_data = pd.read_excel(excel_file_path)

        # Convert the data to a JSON string
        json_data = excel_data.to_json(orient='records').encode().decode("unicode-escape")

        # Write the JSON string to a file
        with open(json_file_path, 'w') as json_file:
            json_file.write(json_data)
        
        print(f"Successfully converted {excel_file_path} to {json_file_path}")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python excel_to_json.py <excel_file_path> <json_file_path>")
    else:
        excel_file_path = sys.argv[1]
        json_file_path = sys.argv[2]
        excel_to_json(excel_file_path, json_file_path)

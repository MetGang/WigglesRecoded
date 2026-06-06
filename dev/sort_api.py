#!/usr/bin/env python3

import json

def main():
    with open('API.json', 'r', encoding = 'utf-8') as ifile:
        data = json.load(ifile)

    sorted_data = sorted(data, key = lambda x: x['name'])

    with open('API.json', 'w', encoding = 'utf-8') as ofile:
        json.dump(sorted_data, ofile, indent = 2)

if __name__ == '__main__':
    main()

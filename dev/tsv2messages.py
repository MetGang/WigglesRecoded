#!/usr/bin/env python3

import csv

def main():
    with open('MESSAGES.tsv', 'r', encoding = 'utf-8') as ifile:
        with open('../data/MESSAGES.TXT', 'w', encoding = 'windows-1250') as ofile:
            reader = csv.reader(ifile, delimiter = '\t', quotechar = '"', quoting = csv.QUOTE_ALL)
            header, *rest = reader
            languages = header[1:]
            for entry in rest:
                key, *translations = entry
                ofile.write(f'## "{key}"\n')
                for l, t in zip(languages, translations):
                    ofile.write(f'{l} "{t}"\n')
                ofile.write('\n')

if __name__ == '__main__':
    main()

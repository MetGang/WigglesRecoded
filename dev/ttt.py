#!/usr/bin/env python3

def main():
    with open('../../../data/Scripts/misc/techtreetunes.tcl', 'r') as file:
        lines = file.read().split('\n')

    start_idx = -1
    end_idx = -1
    blocks = {}

    for i in range(len(lines)):
        line = lines[i].strip()
        if line.startswith('"'):
            start_idx = i
        elif line.startswith('}'):
            end_idx = i
            block = lines[start_idx : end_idx]
            name = block[0].split('"')[1]
            if name == 'Zwerg':
                continue
            block = [ entry.strip() for entry in block[1:] if not (entry.strip().startswith('//') or entry.strip().startswith(';')) ]
            def convert_key(k: str):
                if k.startswith('ttt'):
                    if k.endswith(name) or '$' in k:
                        return k[3:].split('_')[0]
                    else:
                        return k[3:]
            def convert_value(v: str):
                return v.split(';')[0].strip()
            result = { convert_key(key): convert_value(value) for expr in block for _, key, value in [ expr.split(maxsplit = 2) ] }
            blocks.update({ name: result })

    all_keys = set()
    for values in blocks.values():
        all_keys.update(values.keys())
    
    with open('ttt.tsv', 'w') as file:
        file.write('id')
        file.write('\t')
        file.write('\t'.join( all_keys ))
        file.write('\n')
        for k, v in blocks.items():
            file.write(k)
            file.write('\t')
            file.write('\t'.join( v.get(kk, '-') for kk in all_keys ))
            file.write('\n')

if __name__ == '__main__':
    main()

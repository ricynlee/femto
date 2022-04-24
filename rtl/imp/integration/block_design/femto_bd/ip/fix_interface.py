import os, sys, re

root = sys.path[0]

def enum_folders(root, filter=None):
    result = []
    for item in os.listdir(root):
        if os.path.isdir(os.path.join(root, item)):
            result.append(item)
    return result

def enum_files(root, filter=None):
    result = []
    for item in os.listdir(root):
        full_item = os.path.join(root, item)
        if os.path.isfile(full_item):
            if filter==None or filter(full_item):
                result.append(item)
    return result

folders = enum_folders(root)
for folder in folders:
    subroot = os.path.join(root, folder)
    xml = enum_files(subroot, lambda file: True if file.endswith(".xml") else False)
    xml_file = os.path.join(subroot, xml[0])
    snippet = os.path.join(subroot, r"interfaces.xml.snippet")
    if not os.path.isfile(snippet): continue
    with open(xml_file, 'r') as f: xml_content = f.read()
    with open(snippet, 'r') as f: snippet_content = f.read()
    xml_content = re.sub(
        r"</spirit:version>.*?  <spirit:model>",
        "</spirit:version>\n" + snippet_content + "  <spirit:model>",
        xml_content,
        count=1, flags=(re.S|re.M)
    )
    with open(xml_file, 'w') as f: f.write(xml_content)

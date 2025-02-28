import os

def modify_nsswitch():
    path = "/etc/nsswitch.conf"
    
    print(f"Checking {path}...")  # Debug line
    
    # Read the file
    try:
        with open(path, "r") as file:
            lines = file.readlines()
    except Exception as e:
        print(f"Error reading {path}: {e}")
        return
    
    modified = False

    # Process each line
    for i, line in enumerate(lines):
        print(f"Checking line: {line.strip()}")  # Debug line
        if line.startswith("hosts:"):
            # If 'mdns_minimal' is missing, and 'mymachines' is present, add 'mdns_minimal' after 'mymachines'
            if "mymachines" in line and "mdns_minimal" not in line:
                lines[i] = line.replace("mymachines", "mymachines mdns_minimal [NOTFOUND=return]", 1)
                modified = True
                print("Added mdns_minimal after mymachines.")  # Debug line
            # If both 'mymachines' and 'mdns_minimal' are missing, add 'mdns_minimal'
            elif "mymachines" not in line and "mdns_minimal" not in line:
                lines[i] = line.replace("hosts:", "hosts: mdns_minimal [NOTFOUND=return] ", 1)
                modified = True
                print("Added mdns_minimal.")  # Debug line
            break

    # If modified, write back to the file
    if modified:
        try:
            with open(path, "w") as file:
                file.writelines(lines)
            print("Updated /etc/nsswitch.conf")
        except Exception as e:
            print(f"Error writing to {path}: {e}")
    else:
        print("No changes needed.")

if __name__ == "__main__":
    if os.geteuid() != 0:
        print("This script must be run as root.")
    else:
        modify_nsswitch()

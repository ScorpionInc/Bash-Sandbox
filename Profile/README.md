# SI-Profile
This/These file(s) in this directory are automatically added to si profiles if a valid hash signature is provided.

To generate/update a hash file use the following bash code:

> file="EXAMPLE.txt"; sha512sum "$file" | awk '{print $1}' >./"$file".sha512

# powershell-treeview

Converts a list of files from `(Get-ChildItem -Recurse).FullName` to a graphical tree view.

Just run `(Get-ChildItem -Recurse).FullName | Out-Tree`

This is only experimental and the main intention is to allow users to create reports using *additional* cmdlets. For instance, you could run:

    (Get-ChildItem -Recurse).FullName |% {"$_ - $((Get-Acl -Path $_).Access.AccessControlType | Select-Object -Unique)"} | Out-Tree

If you just want to print a tree, you'd be better off with a utility like ... `tree`

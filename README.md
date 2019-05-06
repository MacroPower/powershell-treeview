# powershell-treeview

Converts a list of files (from `Get-ChildItem` or anything else) to a graphical tree view.

Just run `ls -Recurse | Out-Tree`

This is only experimental and the main intention is to allow users to create reports using *additional* cmdlets. For instance, you could run:

    (Get-ChildItem -Recurse).FullName |% {"$_ - " + (Get-Acl $_).AreAccessRulesProtected} | Out-Tree

If you just want to print a tree, you'd be better off with a utility like ... `tree`

## Issues:
- Only supports objects created by Recurse-GCIObject
- Recurse-GCIObject is terrible and very slow

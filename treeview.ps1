function Convert-GCItoObject {
  param(
    [Parameter(Mandatory, ValueFromPipeline, HelpMessage='Items to process')]$InputObject
  )
  process {
    $output = @()
    if($InputObject.GetType().Name -ne 'String') {$InputObject = $InputObject.FullName}
    $InputObject -split '\\' | ForEach-Object { $output += $_ }
    for($i=$output.Count-1; $i -gt 0; $i--){
      $output[$i-1] = [pscustomobject]@{$output[$i-1] = $output[$i]}
    }
    return $output[0]
  }
}

function Recurse-GCIObject {
  param(
    [Parameter(Mandatory, ValueFromPipeline, HelpMessage='Items to process')]$InputObject
  )
  $PipeLine = $Input | ForEach-Object {$_}; If ($PipeLine) {$InputObject = $PipeLine}
  
  $pscustomobject = [pscustomobject]@{}
  $InputObject | Where-Object {$_} | Where-Object {$_.GetType().Name -ne 'String'} | ForEach-Object {$_.psobject.properties.name} | Select-Object -Unique | ForEach-Object {
    if($InputObject.$_) {
      $pscustomobject | Add-Member @{$_ = $(Recurse-GCIObject -InputObject $InputObject.$_) }
    }
  }
  try {
    $pscustomobject | Add-Member -Name Contains -Value ($InputObject | Where-Object {-not $pscustomobject.$_} | ForEach-Object {$_ + ''}) -MemberType NoteProperty -ErrorAction SilentlyContinue
  } catch {
    Write-Verbose 'Empty'
  }
  return $pscustomobject
}

function Render-Tree {
  param(
    [Parameter(Mandatory, ValueFromPipeline, HelpMessage='Items to process')]$InputObject, $lvl = 0
  )
  process {
    if($lvl -gt 1) { $tab = (1..$lvl | ForEach-Object {"|  "}) } else { $tab = " |  "}
    $InputObject | Where-Object {$_} | ForEach-Object {$_.psobject.properties.name} | ForEach-Object {
      if ($_ -ne 'Contains' -and -not [string]::IsNullOrWhiteSpace($_)) {
        if($lvl -eq 0){" +-- $_ "} else {"$tab +-- $_`n"}
        if(-not [string]::IsNullOrWhiteSpace($InputObject.$_)) {
          "$($InputObject.$_ | Render-Tree -lvl ($lvl + 1) )"
        }
      }
    }
    
    $InputObject.Contains | Where-Object {-not [string]::IsNullOrWhiteSpace($_)} | ForEach-Object { "$tab |-- $_`n" }
  }
}

function Out-Tree {
  param(
    [Parameter(Mandatory, ValueFromPipeline, HelpMessage='Items to process')]$InputObject
  )
  $PipeLine = $Input | ForEach-Object {$_}; If ($PipeLine) {$InputObject = $PipeLine}
  $InputObject | Convert-GCItoObject | Recurse-GCIObject | Render-Tree
}

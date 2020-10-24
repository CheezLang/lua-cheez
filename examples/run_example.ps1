[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $example
)

&cheezc $example --modules ./lua ../lua --out bin --int bin --run --print-linker-args
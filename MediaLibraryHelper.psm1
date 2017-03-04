function Get-MediaFiles
{
    [CmdletBinding()]
    Param(
        [string]$Path = {Get-Location | Select-Object -ExpandProperty Path}
        , [Parameter(ParameterSetName="Days")]
        [int]$Days
        , [Parameter(ParameterSetName="ThisMonth")]
        [switch]$ThisMonth
        , [Parameter(ParameterSetName="LastMonth")]
        [switch]$LastMonth

    )

    process
    {
        $fromDate = Get-Date;
        if ($ThisMonth)
        {
            $fromDate = Get-Date -Year $fromDate.Year -Month $fromDate.Month -Date 1;
        }
        if ($LastMonth)
        {
            $fromDate = Get-Date -Year $fromDate.Year -Month $fromDate.Month - 1 -Date 1;
        }

        Get-ChildItem -Path $Path -Recurse -File | Where-Object CreationTime -GE (Get-Date).AddDays(-60) | Sort-Object -Property CreationTime -Descending | Select-Object -Property FullName;

    }
}
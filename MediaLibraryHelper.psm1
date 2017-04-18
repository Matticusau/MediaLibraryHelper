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




function Move-MediaFiles
{
    [CmdLetBinding()]
    Param(
        [string]$sourceDir = 'C:\mediafiles\Complete'
        ,
        [string]$destDir = '\\media\TV_Shows'
    )
    
    
    foreach ($file in (Get-ChildItem -Path $sourceDir -File | Where-Object Extension -In @('.mp4','.mkv','.avi')))
    {
        Write-Host "Processing: $($file.FullName)";

        $result = [Regex]::Matches($file.Name, '(?<Show>.{1,})(\.{1})(?<Season>S{1}\d{2})(?<Episode>E{1}\d{2})');
        if ($null -eq $result) {Write-Host "No regex match"; Continue;}

        [string]$showName = $result[0].Groups['Show'].Value;
        $showName = $showName.Replace('.',' ');

        if ($null -eq $showName) {Write-Host "No show name value"; Continue;}

        [int]$seasonNum = [Regex]::Matches($result[0].Groups['Season'].Value, "\d{2}").Value;

        [int]$episodeNum = [Regex]::Matches($result[0].Groups['Episode'].Value, "\d{2}").Value;

        # can we match the shows dest folder
        $destDirShow = Join-Path -Path $destDir -ChildPath $showName;
        if (-not(Test-Path -Path $destDirShow))
        {
            Write-Host "Cannot find path to tv show: $($destDirShow)";
            Continue;
        }

        # can we match the season folder
        $destDirSeason = Join-Path -Path $destDirShow -ChildPath "Season $($seasonNum)";
        if (-not(Test-Path -Path $destDirSeason))
        {
            Write-Host "Cannot find path to season: $($destDirSeason)";
            Continue;
        }

        # check that the file doesn't already exist
        $destFileName = Join-Path -Path $destDirSeason -ChildPath $file.Name;
        if (-not([System.IO.File]::Exists($destFileName)))
        {
            $file | Copy-Item -Destination $destDirSeason -Verbose;
            Write-Host "Copied file to: $($destFileName)";
        }
        else
        {
            Write-Host "File already exists at destination: $($destFileName)";
        }
    }

}
#requires -Version 5.1
<#
.SYNOPSIS
    Crawl a website and map every PDF leaf node. No installation required:
    runs on the PowerShell that ships with Windows (5.1) and on PowerShell 7+.

.DESCRIPTION
    Breadth-first crawl of one host (optionally restricted to a URL path
    prefix), following <a href> links up to -MaxDepth. Produces:

        <OutPrefix>.md   Markdown tree organised by URL path, PDFs as leaves
        <OutPrefix>.csv  Flat inventory of every PDF found

    Only HTML pages on the same host and under the path prefix are crawled,
    but PDF links are recorded wherever they point (other paths, CDNs, etc.),
    so no leaf is missed.

.PARAMETER StartUrl
    The URL to begin crawling from (e.g. https://intranet/policies/).

.PARAMETER MaxDepth
    Maximum link depth to follow. Default 20.

.PARAMETER NoPrefixRestrict
    Crawl the whole host instead of just the start URL's path.

.PARAMETER Insecure
    Do not validate TLS certificates (for internal/self-signed sites).

.EXAMPLE
    .\PdfSiteMapper.ps1 -StartUrl https://intranet.example/policies/

.EXAMPLE
    .\PdfSiteMapper.ps1 -StartUrl https://intranet.example/policies/ `
        -MaxDepth 12 -OutPrefix policy_map -Insecure
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$StartUrl,
    [int]$MaxDepth = 20,
    [int]$MaxPages = 10000,
    [double]$DelaySeconds = 0.2,
    [int]$TimeoutSec = 30,
    [string]$OutPrefix = 'pdf_site_map',
    [string]$Prefix,
    [switch]$NoPrefixRestrict,
    [switch]$AllowSubdomains,
    [switch]$NoSize,
    [switch]$Insecure,
    [string]$UserAgent = 'pdf-site-mapper/1.0'
)

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'   # large speedup for IWR on 5.1

# --- TLS / certificate handling -------------------------------------------
try {
    [Net.ServicePointManager]::SecurityProtocol =
        [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
} catch {}

$Iwr = @{
    UseBasicParsing = $true
    TimeoutSec      = $TimeoutSec
    UserAgent       = $UserAgent
}
if ($Insecure) {
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        $Iwr['SkipCertificateCheck'] = $true
    } else {
        Add-Type -TypeDefinition @"
using System.Net;
public static class CertBypass {
    public static void Enable() {
        ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
    }
}
"@
        [CertBypass]::Enable()
    }
}

# --- helpers --------------------------------------------------------------
function Format-Size {
    param($Bytes)
    if ($null -eq $Bytes) { return '' }
    $units = 'B', 'KB', 'MB', 'GB', 'TB'; $i = 0; $f = [double]$Bytes
    while ($f -ge 1024 -and $i -lt 4) { $f /= 1024; $i++ }
    if ($i -eq 0) { return ('{0} B' -f [int]$f) }
    return ('{0:N1} {1}' -f $f, $units[$i])
}

function Resolve-Url {
    param([string]$BaseUrl, [string]$Href)
    try {
        $abs = [Uri]::new([Uri]$BaseUrl, $Href)
        if ($abs.Scheme -ne 'http' -and $abs.Scheme -ne 'https') { return $null }
        return $abs.GetLeftPart([System.UriPartial]::Query)   # drops #fragment
    } catch { return $null }
}

function Test-Pdf {
    param([string]$Url)
    try { return ([Uri]$Url).AbsolutePath.ToLower().EndsWith('.pdf') }
    catch { return $false }
}

function Get-Title {
    param([string]$Html)
    $m = [regex]::Match($Html, '(?is)<title[^>]*>(.*?)</title>')
    if ($m.Success) {
        return ([System.Net.WebUtility]::HtmlDecode($m.Groups[1].Value)).Trim()
    }
    return ''
}

function Get-AnchorLinks {
    param([string]$Html)
    $rx = [regex]'(?is)<a\b[^>]*?\bhref\s*=\s*(?:"([^"]*)"|''([^'']*)''|([^\s">]+))[^>]*>(.*?)</a>'
    $out = New-Object System.Collections.ArrayList
    foreach ($m in $rx.Matches($Html)) {
        $href = if ($m.Groups[1].Success) { $m.Groups[1].Value }
                elseif ($m.Groups[2].Success) { $m.Groups[2].Value }
                else { $m.Groups[3].Value }
        $text = [regex]::Replace($m.Groups[4].Value, '(?s)<[^>]+>', '')
        $text = ([System.Net.WebUtility]::HtmlDecode($text)) -replace '\s+', ' '
        [void]$out.Add([pscustomobject]@{ Href = $href.Trim(); Text = $text.Trim() })
    }
    return $out
}

function Invoke-Fetch {
    param([string]$Url)
    try {
        $r  = Invoke-WebRequest -Uri $Url @Iwr
        $ct = ''
        if ($r.Headers -and $r.Headers.ContainsKey('Content-Type')) {
            $ct = [string]$r.Headers['Content-Type']
        }
        return [pscustomobject]@{ Ok = $true; ContentType = $ct; Content = $r.Content }
    } catch {
        return [pscustomobject]@{ Ok = $false; ContentType = ''; Content = $null; Error = $_.Exception.Message }
    }
}

function Get-PdfSize {
    param([string]$Url)
    try {
        $r = Invoke-WebRequest -Uri $Url -Method Head @Iwr
        if ($r.Headers -and $r.Headers.ContainsKey('Content-Length')) {
            return [int64]([string]$r.Headers['Content-Length'])
        }
    } catch {}
    return $null
}

function New-Node { @{ Dirs = @{}; Pdfs = (New-Object System.Collections.ArrayList) } }

function Add-TreeLines {
    param($Node, [int]$Indent)
    foreach ($d in ($Node.Dirs.Keys | Sort-Object)) {
        $script:Lines.Add(('  ' * $Indent) + "- **$d/**")
        Add-TreeLines -Node $Node.Dirs[$d] -Indent ($Indent + 1)
    }
    foreach ($p in ($Node.Pdfs | Sort-Object File)) {
        $label = if ($p.Rec.Title) { $p.Rec.Title } else { $p.File }
        $size  = if ($p.Rec.Size) { " _($(Format-Size $p.Rec.Size))_" } else { '' }
        $script:Lines.Add(('  ' * $Indent) + "- [$($p.File)]($($p.Rec.Url)) - $label$size")
    }
}

# --- set-up ----------------------------------------------------------------
$startResolved = Resolve-Url -BaseUrl $StartUrl -Href $StartUrl
if (-not $startResolved) { throw "Invalid start URL: $StartUrl" }
$startUri = [Uri]$startResolved
$baseHost = $startUri.Host.ToLower()

if ($NoPrefixRestrict) {
    $PathPrefix = '/'
} elseif ($PSBoundParameters.ContainsKey('Prefix')) {
    $PathPrefix = $Prefix
} else {
    $PathPrefix = $startUri.AbsolutePath
    if (-not $PathPrefix) { $PathPrefix = '/' }
}

$visited = New-Object 'System.Collections.Generic.HashSet[string]'
$pdfs    = @{}
$pages   = @{}
$errors  = 0

$queue = New-Object System.Collections.Queue
[void]$queue.Enqueue([pscustomobject]@{ Url = $startResolved; Depth = 0 })
[void]$visited.Add($startResolved)

Write-Host "Crawling $startResolved" -ForegroundColor Cyan
Write-Host "  host + prefix : $baseHost$PathPrefix"
Write-Host "  max depth     : $MaxDepth"
Write-Host "  PowerShell    : $($PSVersionTable.PSVersion)"
Write-Host ''

# --- crawl (breadth-first) -------------------------------------------------
while ($queue.Count -gt 0 -and $visited.Count -le $MaxPages) {
    $item = $queue.Dequeue()
    if ($item.Depth -gt $MaxDepth) { continue }
    if ($DelaySeconds -gt 0) { Start-Sleep -Seconds $DelaySeconds }

    $resp = Invoke-Fetch -Url $item.Url
    if (-not $resp.Ok) { $errors++; Write-Verbose "FAIL $($item.Url): $($resp.Error)"; continue }
    if ($resp.ContentType -and $resp.ContentType -notmatch 'html') { continue }

    $pages[$item.Url] = [pscustomobject]@{ Title = (Get-Title $resp.Content); Depth = $item.Depth }
    Write-Host ("[d{0}] {1}   (pdfs: {2})" -f $item.Depth, $item.Url, $pdfs.Count)

    foreach ($link in (Get-AnchorLinks -Html $resp.Content)) {
        $full = Resolve-Url -BaseUrl $item.Url -Href $link.Href
        if (-not $full) { continue }

        if (Test-Pdf $full) {
            if ($pdfs.ContainsKey($full)) {
                $pdfs[$full].Links++
                if (-not $pdfs[$full].Title -and $link.Text) { $pdfs[$full].Title = $link.Text }
            } else {
                $pdfs[$full] = [pscustomobject]@{
                    Url = $full; Title = $link.Text; FoundOn = $item.Url
                    Depth = $item.Depth + 1; Links = 1; Size = $null
                }
            }
            continue
        }

        if ($visited.Contains($full)) { continue }
        $u = [Uri]$full
        $h = $u.Host.ToLower()
        $sameHost = ($h -eq $baseHost) -or ($AllowSubdomains -and $h.EndsWith('.' + $baseHost))
        if (-not $sameHost) { continue }
        if (-not $u.AbsolutePath.StartsWith($PathPrefix)) { continue }
        if ($visited.Count -gt $MaxPages) { continue }
        [void]$visited.Add($full)
        [void]$queue.Enqueue([pscustomobject]@{ Url = $full; Depth = $item.Depth + 1 })
    }
}

# --- PDF sizes (optional HEAD requests) ------------------------------------
if (-not $NoSize -and $pdfs.Count -gt 0) {
    Write-Host ''
    Write-Host "Fetching sizes for $($pdfs.Count) PDFs ..."
    foreach ($k in @($pdfs.Keys)) { $pdfs[$k].Size = Get-PdfSize -Url $k }
}

# --- write CSV -------------------------------------------------------------
$csvPath = "$OutPrefix.csv"
$pdfs.Values |
    Sort-Object Url |
    Select-Object Url, Title, FoundOn, Depth, Links,
        @{ N = 'SizeBytes'; E = { $_.Size } },
        @{ N = 'SizeHuman'; E = { Format-Size $_.Size } } |
    Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

# --- build path tree and write Markdown ------------------------------------
$root = @{}
foreach ($rec in $pdfs.Values) {
    $u = [Uri]$rec.Url
    if (-not $root.ContainsKey($u.Host)) { $root[$u.Host] = New-Node }
    $node = $root[$u.Host]
    $segments = @($u.AbsolutePath.Trim('/').Split('/') | Where-Object { $_ -ne '' })
    if ($segments.Count -eq 0) { $segments = @($rec.Url) }
    $file = $segments[-1]
    $dirs = if ($segments.Count -gt 1) { $segments[0..($segments.Count - 2)] } else { @() }
    foreach ($d in $dirs) {
        if (-not $node.Dirs.ContainsKey($d)) { $node.Dirs[$d] = New-Node }
        $node = $node.Dirs[$d]
    }
    [void]$node.Pdfs.Add([pscustomobject]@{ File = $file; Rec = $rec })
}

$total = ($pdfs.Values | ForEach-Object { if ($_.Size) { $_.Size } else { 0 } } |
          Measure-Object -Sum).Sum

$script:Lines = New-Object System.Collections.Generic.List[string]
$script:Lines.Add("# PDF site map - $baseHost")
$script:Lines.Add('')
$script:Lines.Add("- **Start URL:** $startResolved")
$script:Lines.Add("- **Pages crawled:** $($pages.Count)")
$script:Lines.Add("- **PDFs found:** $($pdfs.Count)")
if ($total)  { $script:Lines.Add("- **Total PDF size (where known):** $(Format-Size $total)") }
if ($errors) { $script:Lines.Add("- **Pages that failed to load:** $errors") }
$script:Lines.Add('')
$script:Lines.Add('## Catalogue tree')
$script:Lines.Add('')
foreach ($h in ($root.Keys | Sort-Object)) {
    $script:Lines.Add("- **$h**")
    Add-TreeLines -Node $root[$h] -Indent 1
}

$mdPath = "$OutPrefix.md"
Set-Content -Path $mdPath -Value ($script:Lines -join "`n") -Encoding UTF8

# --- summary ---------------------------------------------------------------
Write-Host ''
Write-Host 'Done.' -ForegroundColor Green
Write-Host "  pages crawled : $($pages.Count)"
Write-Host "  PDFs found    : $($pdfs.Count)"
Write-Host "  errors        : $errors"
Write-Host "  wrote         : $mdPath, $csvPath"

param(
    [string]$PackRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$PackRoot = [System.IO.Path]::GetFullPath($PackRoot)
$ModelsDirectory = Join-Path $PackRoot 'assets\minecraft\models\block'
$BlockbenchDirectory = Join-Path $PackRoot 'source\blockbench'
$ZipPath = "$PackRoot.zip"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

[System.IO.Directory]::CreateDirectory($ModelsDirectory) | Out-Null
[System.IO.Directory]::CreateDirectory($BlockbenchDirectory) | Out-Null

$planes = @(
    [ordered]@{ axis = 'z'; offset = 4.0; name = 'row_z_04' },
    [ordered]@{ axis = 'x'; offset = 4.0; name = 'row_x_04' },
    [ordered]@{ axis = 'z'; offset = 12.0; name = 'row_z_12' },
    [ordered]@{ axis = 'x'; offset = 12.0; name = 'row_x_12' },
    [ordered]@{ axis = 'z'; offset = 8.0; name = 'row_z_08' },
    [ordered]@{ axis = 'x'; offset = 8.0; name = 'row_x_08' },
    [ordered]@{ axis = 'z'; offset = 2.0; name = 'row_z_02' },
    [ordered]@{ axis = 'x'; offset = 14.0; name = 'row_x_14' },
    [ordered]@{ axis = 'z'; offset = 14.0; name = 'row_z_14' },
    [ordered]@{ axis = 'x'; offset = 2.0; name = 'row_x_02' },
    [ordered]@{ axis = 'z'; offset = 6.0; name = 'row_z_06' },
    [ordered]@{ axis = 'x'; offset = 6.0; name = 'row_x_06' },
    [ordered]@{ axis = 'z'; offset = 10.0; name = 'row_z_10' }
)
$stageCounts = @(4, 5, 6, 7, 8, 9, 11, 13)

function New-MinecraftElement {
    param([hashtable]$Plane)

    $minimum = $Plane.offset - 0.125
    $maximum = $Plane.offset + 0.125
    if ($Plane.axis -eq 'z') {
        $from = @(0.0, 0.0, $minimum)
        $to = @(16.0, 16.0, $maximum)
        $faces = [ordered]@{
            north = [ordered]@{ uv = @(0, 0, 16, 16); texture = '#crop' }
            south = [ordered]@{ uv = @(0, 0, 16, 16); texture = '#crop' }
        }
    }
    else {
        $from = @($minimum, 0.0, 0.0)
        $to = @($maximum, 16.0, 16.0)
        $faces = [ordered]@{
            east = [ordered]@{ uv = @(0, 0, 16, 16); texture = '#crop' }
            west = [ordered]@{ uv = @(0, 0, 16, 16); texture = '#crop' }
        }
    }

    return [ordered]@{
        name = $Plane.name
        from = $from
        to = $to
        shade = $false
        faces = $faces
    }
}

function New-BlockbenchElement {
    param([hashtable]$Plane, [int]$Index)

    $minecraftElement = New-MinecraftElement -Plane $Plane
    $faces = [ordered]@{}
    foreach ($faceName in $minecraftElement.faces.Keys) {
        $faces[$faceName] = [ordered]@{ uv = @(0, 0, 16, 16); texture = 0 }
    }

    return [ordered]@{
        name = $Plane.name
        box_uv = $false
        rescale = $false
        locked = $false
        from = $minecraftElement.from
        to = $minecraftElement.to
        autouv = 0
        color = ($Index % 8)
        origin = @(8, 8, 8)
        faces = $faces
        type = 'cube'
        uuid = ('00000000-0000-4000-8000-{0:d12}' -f ($Index + 1))
    }
}

for ($stage = 0; $stage -lt 8; $stage++) {
    $elements = @()
    for ($index = 0; $index -lt $stageCounts[$stage]; $index++) {
        $elements += New-MinecraftElement -Plane $planes[$index]
    }

    $model = [ordered]@{
        ambientocclusion = $false
        textures = [ordered]@{
            particle = "minecraft:block/wheat_stage$stage"
            crop = "minecraft:block/wheat_stage$stage"
        }
        elements = $elements
    }
    $modelPath = Join-Path $ModelsDirectory "wheat_stage$stage.json"
    $modelJson = $model | ConvertTo-Json -Depth 12
    [System.IO.File]::WriteAllText($modelPath, $modelJson, $Utf8NoBom)
}

$blockbenchElements = @()
for ($index = 0; $index -lt $planes.Count; $index++) {
    $blockbenchElements += New-BlockbenchElement -Plane $planes[$index] -Index $index
}
$blockbench = [ordered]@{
    meta = [ordered]@{
        format_version = '4.10'
        model_format = 'java_block'
        box_uv = $false
    }
    name = 'NeLegal Endrexon 3D Wheat Stage 7'
    model_identifier = 'minecraft:wheat_stage7'
    resolution = [ordered]@{ width = 16; height = 16 }
    elements = $blockbenchElements
    outliner = @($blockbenchElements | ForEach-Object { $_.uuid })
    textures = @(
        [ordered]@{
            path = 'minecraft:block/wheat_stage7'
            name = 'wheat_stage7'
            namespace = 'minecraft'
            id = '0'
            particle = $true
            render_mode = 'default'
            render_sides = 'auto'
            frame_time = 1
            frame_order_type = 'loop'
            frame_order = ''
        }
    )
}
$blockbenchPath = Join-Path $BlockbenchDirectory 'wheat_stage7.bbmodel'
$blockbenchJson = $blockbench | ConvertTo-Json -Depth 12
[System.IO.File]::WriteAllText($blockbenchPath, $blockbenchJson, $Utf8NoBom)

$jsonFiles = Get-ChildItem -LiteralPath $PackRoot -File -Recurse | Where-Object { $_.Extension -in @('.json', '.mcmeta', '.bbmodel') }
foreach ($file in $jsonFiles) {
    Get-Content -Raw -LiteralPath $file.FullName | ConvertFrom-Json | Out-Null
}

$blockstatePath = Join-Path $PackRoot 'assets\minecraft\blockstates\wheat.json'
$blockstate = Get-Content -Raw -LiteralPath $blockstatePath | ConvertFrom-Json
$totalElements = 0
for ($stage = 0; $stage -lt 8; $stage++) {
    $variantName = "age=$stage"
    $variant = $blockstate.variants.$variantName
    if ($null -eq $variant) { throw "Missing blockstate variant $variantName" }
    $modelPath = Join-Path $ModelsDirectory "wheat_stage$stage.json"
    if (-not (Test-Path -LiteralPath $modelPath -PathType Leaf)) { throw "Missing model $modelPath" }
    $model = Get-Content -Raw -LiteralPath $modelPath | ConvertFrom-Json
    if ($model.elements.Count -ne $stageCounts[$stage]) { throw "Unexpected element count in stage $stage" }
    foreach ($element in $model.elements) {
        foreach ($coordinate in @($element.from) + @($element.to)) {
            if ($coordinate -lt 0 -or $coordinate -gt 16) { throw "Out-of-bounds geometry in stage $stage" }
        }
    }
    $totalElements += $model.elements.Count
}
if ($totalElements -ne 63) { throw "Expected 63 elements, found $totalElements" }

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
if ([System.IO.File]::Exists($ZipPath)) { [System.IO.File]::Delete($ZipPath) }
$archive = [System.IO.Compression.ZipFile]::Open($ZipPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    $packFiles = @(
        Get-Item -LiteralPath (Join-Path $PackRoot 'pack.mcmeta')
        Get-ChildItem -LiteralPath (Join-Path $PackRoot 'assets') -File -Recurse
    )
    foreach ($file in $packFiles) {
        $entryName = $file.FullName.Substring($PackRoot.Length + 1).Replace('\', '/')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $file.FullName, $entryName, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
}
finally {
    $archive.Dispose()
}

$readArchive = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
try {
    $entries = @($readArchive.Entries.FullName)
    if ('pack.mcmeta' -notin $entries) { throw 'Built ZIP has no pack.mcmeta at its root' }
    for ($stage = 0; $stage -lt 8; $stage++) {
        if ("assets/minecraft/models/block/wheat_stage$stage.json" -notin $entries) {
            throw "Built ZIP is missing wheat_stage$stage.json"
        }
    }
}
finally {
    $readArchive.Dispose()
}

$zipHash = (Get-FileHash -LiteralPath $ZipPath -Algorithm SHA256).Hash.ToLowerInvariant()
[ordered]@{
    JsonFilesParsed = $jsonFiles.Count
    Stages = 8
    TotalElements = $totalElements
    ZipPath = $ZipPath
    ZipSha256 = $zipHash
} | ConvertTo-Json

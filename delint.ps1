# Define the target file extension
$targetExtension = "*.py"

# Define the output file
$outputFile = "formatted.txt"

# Install the required Python libraries
Write-Host "Installing required Python libraries..."

# Define the libraries to install
$libraries = @(
    "black",
    "flake8",
    "mypy",
    "pylint",
    "autoflake"
)

# Initialize the progress bar
$totalLibraries = $libraries.Count
$percentCompletePerLibrary = 100 / $totalLibraries

foreach ($library in $libraries) {
    # Update the progress bar for library installation
    $percentComplete = $percentCompletePerLibrary * ($libraries.IndexOf($library) + 1)
    Write-Progress -Activity "Installing $library" -PercentComplete $percentComplete
    # Install the library
    pip install $library -q  # Use -q flag to suppress output
}

# Retrieve .py files from the current directory
$files = Get-ChildItem -Path $PWD -Recurse -Include $targetExtension -File

$totalFiles = $files.Count  # Calculate the total number of files
# Update the output file path to the script's working directory
$outputFile = Join-Path -Path $PWD -ChildPath "formatted.txt"

# Initialize overall progress bar
$currentFileIndex = 0
$overallProgress = 0

# Process each .py file
foreach ($file in $files) {
    $currentFileIndex++
    $fileName = $file.Name
    $filePath = if ($file.DirectoryName -ne $PWD) { Join-Path -Path $file.DirectoryName -ChildPath $fileName } else { $fileName }

    # Change the current working directory to the directory of the file
    Set-Location -Path $file.DirectoryName

    # Update overall progress bar for each file
    $overallProgress = ($currentFileIndex / $totalFiles) * 100
    $currentOperation = "Running commands"

    # Run each command and append output to the file
    Write-Host "Processing file $fileName"

	autoflake --remove-all-unused-imports --remove-unused-variables --in-place $filePath 2>&1 | Tee-Object -FilePath $outputFile -Append
	Write-Progress -Activity "Processing file $fileName" -PercentComplete $overallProgress -Status $currentOperation -CurrentOperation "Running autoflake..."

    black $filePath --quiet 2>&1 | Tee-Object -FilePath $outputFile -Append
	Write-Progress -Activity "Processing file $fileName" -PercentComplete $overallProgress -Status $currentOperation -CurrentOperation "Running black..."

    flake8 $filePath 2>&1 | Tee-Object -FilePath $outputFile -Append
	Write-Progress -Activity "Processing file $fileName" -PercentComplete $overallProgress -Status $currentOperation -CurrentOperation "Running flake8..."

    mypy $filePath 2>&1 | Tee-Object -FilePath $outputFile -Append
    Write-Progress -Activity "Processing file $fileName" -PercentComplete $overallProgress -Status $currentOperation -CurrentOperation "Running mypy..."

    pylint $filePath 2>&1 | Tee-Object -FilePath $outputFile -Append
    Write-Progress -Activity "Processing file $fileName" -PercentComplete $overallProgress -Status $currentOperation -CurrentOperation "Running pylint..."

    # Change the current working directory back to the original directory
    Set-Location -Path $PWD
}

(Get-Content -Path $outputFile) |
    ForEach-Object {
        $_ -replace [regex]::Escape($PWD.Path), ""
    } |
    Where-Object {
        $_ -notmatch '^Your code has been rated at|^-----+|^\*+' -and
        $_ -notmatch 'line too long' -and
        $_ -notmatch '^Success: .*' -and
        $_ -notmatch '^Found \d+.*' -and
        $_.Trim() -ne ''
    } |
    Set-Content -Path "report_log_trimmed.txt"

# Delete the 'formatted.txt' file
Remove-Item -Path $outputFile

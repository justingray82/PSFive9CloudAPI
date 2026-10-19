function Get-Five9CloudJwtClaims ([string]$Token) {
    # Decodes the payload of a JWT access token (no signature validation).
    try {
        $part = $Token.Split('.')[1].Replace('-','+').Replace('_','/')
        switch ($part.Length % 4) { 2 { $part += '==' } 3 { $part += '=' } }
        return ([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($part)) | ConvertFrom-Json)
    } catch { return $null }
}
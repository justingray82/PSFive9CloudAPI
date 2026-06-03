function Get-Five9CloudDomainNumbers {

    Invoke-Five9CloudPagedApi (Set-Five9CloudQueryUri "numbers-svc/v2/domains/$($global:Five9.DomainId)/phone-numbers?sort=numberId&filter=(type%3D%3DPHONE_NUMBER)" $q)
}
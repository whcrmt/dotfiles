function amazon_helper {
    param(
        [Parameter(Mandatory=$true)]
        [string]$account_name
    )

    if (-not $awsAccountMap.ContainsKey($account_name)) {
        Write-Error "Account name '$account_name' is not recognized. Please enter a valid account name."
        return
    }

    echo $awsAccountMap[$account_name]
}

function al {
    param(
        [Parameter(Mandatory=$true)]
        [string]$account_name,
        [Parameter(Mandatory=$true)]
        [string]$role
    )
    $account_number = amazon_helper $account_name
    aws-adfs login --adfs-host $awsSsoHost --role-arn "arn:aws:iam::${account_number}:role/ADFS-${role}" --region eu-west-1 --session-duration 3600 --no-ssl-verification --no-session-cache
}

function ecr_login {
    param(
        [Parameter(Mandatory=$true)]
        [string]$account_name,
        [Parameter(Mandatory=$true)]
        [string]$role
    )
    $account_number = amazon_helper $account_name
    aws-adfs login --adfs-host $awsSsoHost --role-arn "arn:aws:iam::${account_number}:role/ADFS-${role}" --region eu-west-1 --session-duration 3600 --no-ssl-verification --no-session-cache
    aws ecr get-login-password --region "eu-west-1" | docker login --username "AWS" --password-stdin "${account_number}.dkr.ecr.eu-west-1.amazonaws.com"
}
